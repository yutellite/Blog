

1 heap segment row data.
+-----------------------------+
|knl_row_header               | 
|       db_uint32 lock_id     | 
|       db_uint16 size        | 
|       db_uint16 col_count   | 
|       db_uint32 bit_array[1]|
+-----------------------------+

Row header                                 Each column two bits    Row data
+-------+---------+--------------+---------+--------------+------------+------------+----------+------------+
|       |         |              |         |              |            |            |          |            |
|lock_id| row flag| row data size|col_count|size bit array|column1 data|column2 data| ...      |columnN data|
|       |         |              |         |              |            |            |          |            |
+-------+---------+--------------+---------+--------------+------------+------------+----------+------------+    
3B      1B        2B             2B        >=4B

lock Id: as we see in the knl_row_header, it puts 3B lock_id and 1B row flag together in 4B lock_id.
         flag occupy the 4B's highest 1B and the lock id occupy the low 3B.
         The lock Id record the lock index in lock GA.
Row flag:record the flag of the row. such as delete flag or row migrate flag.
row data size: the real size of the row. includes NULL.bitmap
col_count: the column num of the row.
size bit array: use 2bits record one column. 00-null. 01-int32. 10-long64. 11-variable-length.
column data:  1. 01-int32 or 10-long64. just puts the value of the column.
              2. 11-varchar. use two Bytes to record the length of the column, then followed by the real data value.
+-------+------------+                   
|       |            | 
|length | column data| 
|       |            | 
+-------+------------+
2B      length

when do data insert, the cursor need to input the row data size, column num and row data. row data includes 
size array and real column data value.

2 heap segment row flag.

For one row, there will be the following flags.
+--------------------------------------+------------------------------------------+
|#define HEAP_ROW_FLAG_DELETE (0x01)   |record row deleted. but also need to check| 
|                                      |transaction is commited or not.           |
|#define HEAP_ROW_FLAG_ENTRY  (0x2)    |means the entry of the row migrate.       |
|#define HEAP_ROW_FLAG_LINK (0x4)      |means the real data of the row migrate.   |
|#define HEAP_ROW_FLAG_COMPACTING (0x8)|means the compression to the row.         |
+--------------------------------------+------------------------------------------+

2.1 To heap segment, insert a new record, its rowid will change to a new one and it won't reuse the delete old one's rowid.
So for a new insert row record. Its life period is following.
                                                         +------------+
                                                         |new record  |
                                                         |lock action:|
                                                         |insert      |      
                                                /        +------------+       \
                        +---------------+                                             +------------------+          
                        |own transaction|                                             |other transactions|
                        +---------------+                     ..>            ...>     +------------------+
               /                |          .  \                       ...           /         |             \
 select                update      .                   delete  ...        select             update            delete
 +----------+       +-----------------+        +-----------------+    +------------+     +------------+    +------------+
 |fetch     |<----- |keep the state of| -----> |change the flag  |    | unvisible  |     | unvisible  |    | unvisible  |
 |the record| select| flag and action | delete | to delete state |    +------------+     +------------+    +------------+ 
 +----------+       +-----------------+        +-----------------+    
                          \/update              /       |       \
                                           select      update       delete    
                                        +---------+  +---------+  +---------+ 
                                        |unvisible|  |unvisible|  |unvisible| 
                                        +---------+  +---------+  +---------+ 
To heap segment, update and delete.
+------+---------------------------+
|action|rollback                   |
+------+---------------------------+ 
|update|keep the state of the flag.|
|delete|remove the flag of delete  |
+------+---------------------------+     

2.2 To heap segment, update a old record.
                                                         +------------+
                                                         |old record  |
                                                         |lock action:|
                                                         |update      |
                                                /        +------------+       \ 
                        +---------------+                                             +------------------+                
                        |own transaction|                                             |other transactions|                
                        +---------------+                                 .>      ..> +------------------+                
               /                |              \      .                      ..       /         |             \             
 select                update      .                  delete      ..      select             update            delete    
 +----------+       +-----------------+        +-----------------+    +---------------+     +-------+        +-------+ 
 |fetch     |<----- |keep the state of| -----> |change the flag  |    |fetch from undo|     | wait  |        | wait  | 
 |the record| select| flag and action | delete | to delete state |    +---------------+     +-------+        +-------+ 
 +----------+       +-----------------+        +-----------------+  
                         \/update                 /       |       \ 
                                           select      update       delete
                                        +---------+  +---------+  +---------+
                                        |unvisible|  |unvisible|  |unvisible|
                                        +---------+  +---------+  +---------+
                                                                                     
                                                                                     
To heap segment, update and delete. 
+------------+----------------------------+
|action      |rollback                    |
+------------+----------------------------+
|first update|change the lock's undo.rowid|
|            |used by other transactions  |
|            | to fetch data. undo's value|
|            |  is not available          |
|later update|keep the state of the flag. | 
|delete      |move the flag of delete     | 
+------------+----------------------------+  

2.3 delete an old record.
                                            +------------+
                                            |old record  | 
                                            |lock action:|
                                            |deltete     | 
                                   /        +------------+       \                                                 
                +---------------+                                   +------------------+                      
                |own transaction|                                   |other transactions|                      
                +---------------+                                   +------------------+                      
              /         |              \                          /         |             \                 
select                update           delete         select              update            delete           
+---------+       +---------+        +---------+    +---------------+     +-------+        +-------+          
|unvisible|       |unvisible|        |unvisible|    |fetch from data|     | wait  |        | wait  |          
+---------+       +---------+        +---------+    +---------------+     +-------+        +-------+          
                                                                                                   
To heap segment, delete roolback.    
+------+---------------------------+ 
|action|rollback                   | 
+------+---------------------------+ 
|delete|remove the flag of delete  | 
+------+---------------------------+ 

Generally, combine the lock id and action, we can decide a row record is visable or not.
The principle is:
+---------------+-----------+----------------+-------------------+ 
|row header flag|lock action| own transaction| other transactions| 
+---------------+-----------+----------------+-------------------+ 
|   none        |   none    |    --          |   visiable        |
+---------------+-----------+----------------+-------------------+ 
|   none        |   Insert  |    visiable    |   unvisiable      | 
+---------------+-----------+----------------+-------------------+
|   none        |   Update  |    visiable    |   undo            |  
+---------------+-----------+----------------+-------------------+ 
|   none        |   U-lock  |    --          |   visiable        | 
+---------------+-----------+----------------+-------------------+ 
|   none        |   Delete  |    --          |   visiable        | 
+---------------+-----------+----------------+-------------------+ 
|   Delete      |   none    |    --          |   unvisiable      |
+---------------+-----------+----------------+-------------------+
|   Delete      |   Insert  |    unvisiable  |   unvisiable      | 
+---------------+-----------+----------------+-------------------+ 
|   Delete      |   Update  |    unvisiable  |   undo            | 
+---------------+-----------+----------------+-------------------+ 
|   Delete      |   U-lock  |    --          |   --              | 
+---------------+-----------+----------------+-------------------+
|   Delete      |   Delete  |    unvisiable  |   visiable        |  
+---------------+-----------+----------------+-------------------+

3 row migrate
                                 +------+
row header    row data          /        \    row header    row data              
+------+---------------------------+      \   +------+---------------------------+
|Entry |Migrate row id             |       -> |Link  |Exact row data             |
+------+---------------------------+          +------+---------------------------+ 

                +------+   +------+   +------+   +------+
                |DDL   |   |cursor|   |Index |   |GC    |
                +------+   +------+   +------+   +------+
                    +---------------------------+ 
                    |Migrate row id             | 
                    +---------------------------+ 
               
                +------+   +-------+   +------+   +------+  +------+ +------+
                |page  |   |segment|   |Lock  |   |undo  |  |redo  | |ckpt  |
                +------+   +-------+   +------+   +------+  +------+ +------+
