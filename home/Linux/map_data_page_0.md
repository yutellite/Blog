```c
tbl_name;TBL_YWX                                                                                     
tbl_id:66                                                                                            
record num:150002                                                                                    
used pages:644                                                                                       
column:  INT 4                                                                                       
         varchar(10)                                                                                 
index:no                                                                                             
                                                                                                     
table seg entry（this is the entry table map page and data page）                                    
                                                                                                     
seg_segment                                                                                          
                                                                                                     
+---------------------------------------------------+                                                
|mutex;                                             |0                                               
|struct_latch;                                      |{spinlock = 0, latch_mode = 0, latch_cnt = 0}   
|recycle_latch;                                     |{spinlock = 0, latch_mode = 0, latch_cnt = 0}   
|mutex_vacuum;                                      |0                                               
|mutex_free_size;                                   |0                                               
|fl_mutex[SEG_FREE_LIST_COUNT];                     |{0, 0, 0, 0, 0, 0, 0, 0}                        
|mutex_rb;                                          |0                                               
|is_index_ddl;                                      |0                                               
|                                                   |                            from the entry      
|entry;                                             |37748738  9-> 2            --------------->     
|first_data_page;                                   |37748739  9-> 3                                 
|last_page;                                         |37749384  9-> 648                               
|page_count;                                        |647                                             
|cache_root;                                        |0                                               
|                                                   |                                                
|schema_id;                                         |0--sys                                          
|obj_id;                                            |66--tbl_id                                      
|obj_name[DB_MAX_NAME_LEN];                         |TBL_YWX                                         
|type;                                              |1                                               
|                                                   |                                                
|space_id;                                          |9                                               
|                                                   |                                                
|pct_free;                                          |20                                              
|min_list_id;                                       |2                                               
|                                                   |                                                
|create_no;                                         |0                                               
|free_size;                                         |8080--8192-80-560-xx                            
|del_count;                                         |0                                               
|row_count;                                         |150002                                          
|gc_time;                                           |4319935                                         
|btree_map_flag;                                    |0                                               
|btree_map[MAX_MAP_ROOT_NUM];                       |{0, 0}                                          
|btree_rebuild_on;                                  |0                                               
|btree_map_time;                                    |0                                               
|btree_mem_ctx;                                     |0                                               
|btree_mem_latch;                                   |{spinlock = 0,latch_mode = 0, latch_cnt = 0}    
|                                                   |                                                
|empty_page_count;                                  |0                                               
|stat_last_page_count;                              |0                                               
|last_segment_free_size;                            |0                                               
|session_map[1];                                    |{{flag=0,version=0}}                            
+---------------------------------------------------+                                               
```
