```c
seg_segment_t((seg_segment_t *) 0x2ad53cf73258)                                                                       
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
|entry;                                             |16777246  4->30    USER_DEV   --------------->                   
|first_data_page;                                   |16777247  4->31                                                  
|last_page;                                         |16777737  4->521                                                 
|page_count;                                        |492                                                              
|cache_root;                                        |16777561  4->345                                                 
|                                                   |                                                                 
|schema_id;                                         |0--sys                                                           
|obj_id;                                            |69--index_id                                                     
|obj_name[DB_MAX_NAME_LEN];                         |TBL_YWX_I  (TBL_YWX)                                             
|type;                                              |4                                                                
|                                                   |                                                                 
|space_id;                                          |4                                                                
|                                                   |                                                                 
|pct_free;                                          |20                                                               
|min_list_id;                                       |1                                                                
|                                                   |                                                                 
|create_no;                                         |0                                                                
|free_size;                                         |8054---xx                                                        
|del_count;                                         |0                                                                
|row_count;                                         |149997  (data row count 150002 delete some row after)            
|gc_time;                                           |4697625                                                          
|btree_map_flag;                                    |0                                                                
|btree_map[MAX_MAP_ROOT_NUM];                       |{18446744073709551615, 18446744073709551615} 0xffffffffffffffff  
|btree_rebuild_on;                                  |0                                                                
|btree_map_time;                                    |0                                                                
|btree_mem_ctx;                                     |0                                                                
|btree_mem_latch;                                   |{spinlock = 0,latch_mode = 0, latch_cnt = 0}                     
|                                                   |                                                                 
|empty_page_count;                                  |0                                                                
|stat_last_page_count;                              |486                                                              
|last_segment_free_size;                            |15318                                                            
|session_map[1];                                    |{{flag=0,version=0}}                                             
+---------------------------------------------------+                                                                 
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
                                                                                                                                                                                                     
type                                                                                                                                                                                                 
    SPC_UNUSED_SEG_TYP = 0x00,      //0000 0000                                                                                                                                                      
    SPC_TABLE_SEG_TYP = 0x01,       //0000 0001                                                                                                                                                       
    SPC_UNDO_SEG_TYP  = 0x02,       //0000 0010                                                                                                                                                                                                                                                                            
    SPC_HASH_INDEX_SEG_TYP = 0x03,  //0000 0011                                                                                                                                                                                                                                                                            
    SPC_BTREE_INDEX_SEG_TYP = 0x04, //0000 0100                                                                                                                                                                                                                                                                            
    SPC_HASH_TABLE_SEG_TYP = 0x05,  //0000 0101                                                                                                                                                                                                                                                                            
    SPC_LOB_SEG_TYP = 0x06,         //0000 0110                                                                                                                                                                                                                                                                            
    //if add item ,need to change seg_type_valid()                                                                                                                                                                                                                                                                         
    SPC_SEG_TYPE_BUTT = 0x7F                                                                                                                                                                                                                                                                                               
                                                                                                                                                                                                                                                                                                                           
entry page                                                                                                                                                                                                                                                                                                                 
16777246                                                                                                                                                                                                                                                                                                                   
page head                                                                                                                                                                                                                                                                                                                  
page_head  p *(spc_page_head_t*)(dev_entry[4].mem_entry+30*8192)     page head                                                                                                                                                                                                                                             
entry map page(segment map page(entry))                              +-----------------------------------+                                                                                                                                                                                                                 
+-----------------------------+                                      |latch;                             |{spinlock=0,latch_mode=0,latch_cnt=0}                                                                                                                                                                            
|page head   map_page_id      |80Byte                                |mutex;                             |0                                                                                                                                                                                                                
|            map_offset       |                                      |chg_num;                           |967                                                                                                                                                                                                              
|            (map info)       |                                      |page_id;                           |16777246  4->30                                                                                                                                                                                                  
|            map_page_id;     |                                      |obj_id;                            |69                                                                                                                                                                                                               
|            map_offset;      |                                      |page_create_no;                    |0                                                                                                                                                                                                                
|            unused[2];       |                                      |seg_type;                          |4
|                             |                                      |page_type;                         |2
|            (page usage info)|                                      |                                   |
|            free_begin;      |                                      |(map info)                         |
|            free_end;        |                                      |map_page_id;                       |4294967295
|            del_count;       |                                      |map_offset;                        |65535
|            data_begin;      |->80+560=640                          |unused[2];                         |0
|             ...             |                                      |                                   |
|segment head  type           |560Byte                               |(page usage info)                  |
|             space_id        |                                      |free_begin;                        |640
|             first_data_page | <-- first data page                  |free_end;                          |8184
|             last_page       |                                      |del_count;                         |0
|             page_count      |                                      |data_begin;                        |640
|             free_lists      |                                      |                                   |
|             free_map_list   |                                      |(checkpoint info)                  |
|             ...             |                                      |ckpt_id;                           |475
|seg_map_page_head            | <--- page_addr + page_head.data_begin|mirror_page;                       |4294967295
|             prior           |                                      |next_ckpt_page;                    |4294967295
|             next            | ---> 2nd map page                    |dirty_flag;                        |0
|             map_count       |                                      |                                   |
|             map_capacity    | <--- the map capacity of cur page    |valid_flag;                        |0
|page_map1     page_map2      |                                      |                                   |
|page_map3     page_mapN      | <--- N=map_count                     |(flag info)                        |
|...           ...            |                                      |flag;                              |0
|              spc_page_tail_t| 8Byte                                |fl_flag;                           |0
+-----------------------------+                                      |                                   |
 map_capacity=(8192-80-8-12-560)/32=235                              |hash_tab_head;                     |{used_flag=0,unused=0,page_count=0}
 page_size-head-tail-map_head                                        |hash_page_type;                    |0
 Note: because the size of seg_map is fix 32Byte, so we can          |reserve[15];                       |0
       get the addr of every seg_map by offset plus 32               +-----------------------------------+
       page_map_addr=p *(seg_page_map_t*)(0x2ad55dac6000+640+12+n*32)                                                             
                                                                     seg_segment_head(*(seg_segment_head_t*)(page_addr+80)) 
                                                                     +-----------------------------------+                  
                                                                     |schema_id;                         |0                 
                                                                     |obj_id;                            |69                
                                                                     |obj_name[DB_MAX_NAME_LEN];         |TBL_YWX_I           
                                                                     |create_no;                         |0                 
                                                                     |type;                              |4                 
                                                                     |space_id;                          |4                 
                                                                     |                                   |                  
                                                                     |last_map_page;                     |16777735 4->519   
                                                                     |last_map_page_full;                |0                 
                                                                     |first_data_page;                   |16777247 4->31     
                                                                     |last_page;                         |16777737 9->521   
                                                                     |page_count;                        |492               
                                                                     |free_lists[SEG_FREE_LIST_COUNT];   | 
                                                                     |                                   |                                                       
                                                                     |                                   |
                                                                     |empty_list;                        |
                                                                     |free_map_list;                     |
                                                                     |min_list_id;                       |1                 
                                                                     |pct_free;                          |0                
                                                                     |reserve[2];                        |0                 
                                                                     |reserve2[64];                      |0                 
                                                                     |                                   |                  
                                                                     |child_seg;                         |                   
                                                                     +-----------------------------------+                  
                                                           free_lists={{count=0,first={page_id=4294967295,map_page=4294967295,map_offset=65535,reserved=65535}}..7repeat
                                                                      {count=489,first={page_id=16777737,map_page=16777735,map_offset=1,reserved=65535}}}              
                                                                                                                                                     
                                                           empty_list={{count=0,first={page_id=4294967295,map_page=4294967295,map_offset=65535,reserved=65535}}         
                                                           free_map_list={{count=0,first={page_id=4294967295,map_page=4294967295,map_offset=65535,reserved=65535}}         
                                                           child_seg={btree={root=16777561,first_page={16777247,16777249,16777561,4294967295 <repeats 61 times>},total_level=3,reserve="\000"}

                                                                     seg_map_page_head  *(seg_map_page_head_t*)(page_addr+640)       next_seg = 0}}}                                                      
                                                                     +-----------------------------------+                                                                                                
                                                                     |seg_map_page_head                  |                                                                                                
                                                                     |             prior                 |4294967295                                                                                      
                                                                     |             next                  |16777482(266)                                                                                   
                                                                     |             map_count             |235                                                                                             
                                                                     |             map_capacity          |235                                                                                             
                                                                     +-----------------------------------+                                                                                                
                                                                     page_map (640+12) seg_page_map_t                                                                                                     
                                                                     +-----------------------------------------------------+                                                                                                
                                                                     |page_map  32B                                        |                                                                                                
                                                                     | +------------+          +------------+              |                                                                                                
                                                                     | |page_id;    |16777247  |page_id;    |16777248      |                                                                                                
                                                                     | |list_id;    |7         |list_id;    |7             |                                                                                                
                                                                     | |reserved[3];|0         |reserved[3];|0             |                                                                                                
                                                                     | |            |          |            |              |                                                                                                
                                                                     | |prior;      |          |prior;      |              |   
                                                                     | |next;       |          |next;       |              |   
                                                                     | +------------+          +------------+              |                                                                                                
                                                                     +-----------------------------------------------------+                                                                                                
                                                                    1 prior = {page_id = 16777248(32), map_page = 16777246(30),map_offset = 1, reserved = 65535}    
                                                                      next = {page_id = 4294967295, map_page = 4294967295, map_offset = 65535, reserved = 65535}} 
                                                                    2 prior = {page_id = 16777249(33), map_page = 16777246(30),map_offset = 2, reserved = 65535} 
                                                                      next = {page_id = 16777247(31), map_page = 16777246(30), map_offset = 0, reserved = 65535}
```
