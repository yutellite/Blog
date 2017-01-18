```c



tablespace                  
device1                     
1st page                           2st page                         3st page                           4st page                           5st page                           
+-----------------------------+    +-----------------------------+  +-----------------------------+    +-----------------------------+    +-----------------------------+    
|page head    map_page_id     |    |page head    map_page_id     |  |page head    map_page_id     |    |page head    map_page_id     |    |page head    map_page_id     |    
|             map_offset      |    |             map_offset      |  |             map_offset      |    |             map_offset      |    |             map_offset      |    
|             ...             |    |             ...             |  |             ...             |    |             ...             |    |             ...             |    
|                             |    |record data   record data    |  |record data   record data    |    |record data   record data    |    |record data   record data    |    
|device head  page_count      |    |...           ...            |  |...           ...            |    |...           ...            |    |...           ...            |    
|             hwm             |    |                             |  |                             |    |                             |    |                             |    
|             free_page_count |    |record data   record data    |  |record data   record data    |    |record data   record data    |    |record data   record data    |    
|             reserved[64]    |    |...           ...            |  |...           ...            |    |...           ...            |    |...           ...            |    
|                             |    |                             |  |                             |    |                             |    |                             |    
|space head   seg_num         |    |record data   record data    |  |record data   record data    |    |record data   record data    |    |record data   record data    |    
|             free_pages      |    |...           ...            |  |...           ...            |    |...           ...            |    |...           ...            |    
|             reserved[64]    |    |                             |  |                             |    |                             |    |                             |    
|                             |    |                             |  |                             |    |                             |    |                             |    
|record data   record data    |    |record data   record data    |  |record data   record data    |    |record data   record data    |    |record data   record data    |    
|...           ...            |    |...           ...            |  |...           ...            |    |...           ...            |    |...           ...            |    
+-----------------------------+    +-----------------------------+  +-----------------------------+    +-----------------------------+    +-----------------------------+    

page_head                                          device head
+------------------------------------------+       +-----------------------------+
|latch;                                    |       |             page_count      | 
|mutex;                                    |       |             hwm             |
|chg_num;                                  |       |             free_page_count | 
|page_id;                                  |       |             reserved[64]    | 
|obj_id;                                   |       +-----------------------------+ 
|page_create_no;                           |
|seg_type;                                 |       space head
|page_type;                                |       +-----------------------------+
|                                          |       |             seg_num         |
|(map info)                                |       |             free_pages      |
|map_page_id;                              |       |             reserved[64]    |
|map_offset;                               |       +-----------------------------+
|unused[2];                                |
|                                          |
|(page usage info)                         |
|free_begin;                               |
|free_end;                                 |
|del_count;                                |
|data_begin;                               |
|                                          |
|(checkpoint info)                         |
|ckpt_id;                                  |
|mirror_page;                              |
|next_ckpt_page;                           |
|dirty_flag;                               |
|                                          |
|valid_flag;                               |
|                                          |
|(flag info)                               |
|flag;                                     |
|fl_flag;                                  |
|                                          |
|hash_tab_head;                            |
|hash_page_type;                           |
|reserve[15];                              |
+------------------------------------------+
```
