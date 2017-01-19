```c





tablespace                  
device1   (all the pages in one device are continuous, so can find all the page if know the first one's page_addr)                  
1st page                           2nd page                         3rd page                           4th page                           Nth page                           
+-----------------------------+    +-----------------------------+  +-----------------------------+    +-----------------------------+    +-----------------------------+    
|page head    map_page_id     |    |page head    map_page_id     |  |page head    map_page_id     |    |page head    map_page_id     |    |page head    map_page_id     |    
|             map_offset      |    |             map_offset      |  |             map_offset      |    |             map_offset      |    |             map_offset      | 
|            (map info)       |    |            (map info)       |  |            (map info)       |    |            (map info)       |    |            (map info)       | 
|            map_page_id;     |    |            map_page_id;     |  |            map_page_id;     |    |            map_page_id;     |    |            map_page_id;     | 
|            map_offset;      |    |            map_offset;      |  |            map_offset;      |    |            map_offset;      |    |            map_offset;      | 
|            unused[2];       |    |            unused[2];       |  |            unused[2];       |    |            unused[2];       |    |            unused[2];       | 
|                             |    |                             |  |                             |    |                             |    |                             | 
|            (page usage info)|    |            (page usage info)|  |            (page usage info)|    |            (page usage info)|    |            (page usage info)| 
|            free_begin;      |    |            free_begin;      |  |            free_begin;      |    |            free_begin;      |    |            free_begin;      | 
|            free_end;        |    |            free_end;        |  |            free_end;        |    |            free_end;        |    |            free_end;        | 
|            del_count;       |    |            del_count;       |  |            del_count;       |    |            del_count;       |    |            del_count;       | 
|            data_begin;      |    |            data_begin;      |  |            data_begin;      |    |            data_begin;      |    |            data_begin;      | 
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
|mutex;                                    |       |             hwm             |--> high water mark(how many pages used)
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


create table 
When we first create a table, we create a segment for the table, which includes mpa pages and data pages, the first map page is the entry of the table.
When we want to fetch the rows of the table, we first find its segment, the get the entry of the map page, then the first data page in the map page.
 
table_entry->segment(entry)->first_data_page
page_id=dev_id<<22+offset
page_addr=dev_entry[dev_id]+offset*page_size

1st map page(segment map page(entry))                                       2nd map page                             3rd map page                            Nth map page                   
+-----------------------------+                                             +-----------------------------+          +-----------------------------+         +-----------------------------+
|page head   map_page_id      |80Byte                                       |page head   map_page_id      |          |page head   map_page_id      |         |page head    map_page_id     |
|            map_offset       |                                             |            map_offset       |          |            map_offset       |         |             map_offset      |
|            (map info)       |                                             |            (map info)       |          |            (map info)       |         |            (map info)       |
|            map_page_id;     |                                             |            map_page_id;     |          |            map_page_id;     |         |            map_page_id;     |
|            map_offset;      |                                             |            map_offset;      |          |            map_offset;      |         |            map_offset;      |
|            unused[2];       |                                             |            unused[2];       |          |            unused[2];       |         |            unused[2];       |
|                             |                                             |                             |          |                             |         |                             |
|            (page usage info)|                                             |            (page usage info)|          |            (page usage info)|         |            (page usage info)|
|            free_begin;      |                                             |            free_begin;      |          |            free_begin;      |         |            free_begin;      |
|            free_end;        |                                             |            free_end;        |          |            free_end;        |         |            free_end;        |
|            del_count;       |                                             |            del_count;       |          |            del_count;       |         |            del_count;       |
|            data_begin;      |->80+560=640                                 |            data_begin;      |          |            data_begin;      |         |            data_begin;      |
|             ...             |                                             |             ...             |          |             ...             |         |             ...             |
|segment head  type           |560Byte                                      |seg_map_page_head            |          |seg_map_page_head            |         |seg_map_page_head            |    page_map            
|             space_id        |                                             |             prior           |          |             prior           |         |             prior           |    +-----------------+ 
|             first_data_page | <-- first data page                         |             next      ------------>    |             next         --------->   |             next            |    |page_id;         | 
|             last_page       |                                             |             map_count       |          |             map_count       |         |             map_count       |    |list_id;         | 
|             page_count      |                                             |             map_capacity    |          |             map_capacity    |         |             map_capacity    |    |reserved[3];     | 
|             free_lists      |                                             |page_map1     page_map2      |          |page_map1     page_map2      |         |page_map1     page_map2      |    |                 | 
|             free_map_list   |                                             |page_map3     page_mapN      |          |page_map3     page_mapN      |         |page_map3     page_mapN      |    |prior;           | 
|             ...             |                                             |...           ...            |          |...           ...            |         |...           ...            |    |next;            | 
|seg_map_page_head            | <--- page_addr + page_head.data_begin       |              spc_page_tail_t| 8Byte    |              spc_page_tail_t| 8Byte   |              spc_page_tail_t|    |                 |
|             prior           |                                             +-----------------------------+          +-----------------------------+         +-----------------------------+    +-----------------+
|             next            | ---> 2nd map page                           map_capacity=(8192-80-8-12)/32=252       map_capacity=(8192-80-8-12)/32=252      map_capacity=(8192-80-8-12)/32=252
|             map_count       |                                             page_size-head-tail-map_head             page_size-head-tail-map_head            page_size-head-tail-map_head      
|             map_capacity    | <--- the map capacity of cur page           
|page_map1     page_map2      |                                             
|page_map3     page_mapN      | <--- N=map_count                            
|...           ...            |                                             
|              spc_page_tail_t| 8Byte
+-----------------------------+                                             
 map_capacity=(8192-80-8-12-560)/32=235 
 page_size-head-tail-map_head                                                                 
                                                                                              

1st data page                    
+-----------------------------+                                                    
|page head    map_page_id     |                                                    
|             map_offset      |                                                    
|            (map info)       |                                                               
|            map_page_id;     |                                                               
|            map_offset;      |                                                               
|            unused[2];       |                                                               
|                             |                                                               
|            (page usage info)|                                                               
|            free_begin;      |                                                               
|            free_end;        |                                                               
|            del_count;       |                                                               
|            data_begin;      |                                                               
|             ...             |                                                               
|node head   next             | --> page_addr + data_begin                                    
|            slot_count       |                                                               
|            free_slot        |                                                               
|            reserved[16]     |                                                               
|                             |                                                               
| row data1     row data2     |                                                               
| row data3     row data4     |                                                               
| row data5     row data6     |                                                               
|   ...           ...         |                                                               
|   -->                       |                                                               
|                             |                                                               
|                             |                                                               
|                             |                                                               
|                             |                                                               
|                       <---- |                                                               
|...|slot_offset3|slot_offset2|
|slot_offset1|spc_page_tail_t | 8Byte                                                              
+-----------------------------+                                                                             
get_slot_addr (db_uint16 *)((db_char *)(0x2b8a2246d000) + (8192) - (8 + ((1) + 1) * sizeof(db_uint16)))                                                            
G#define GMSTAT_GET_SLOT_ADDR(page, slot_id, page_size) = (db_uint16 *)((db_char *)(page) + (page_size) - (SPC_PAGE_TAIL_SIZE + ((slot_id) + 1) * sizeof(db_uint16)))

                                                                                                     
seg_segment_head                                                                                            
+-----------------------------------+                                                                       
|schema_id;                         |                                                                       
|obj_id;                            |                                                     
|obj_name[DB_MAX_NAME_LEN];         |                                                     
|create_no;                         |                                                     
|type;                              |                                                     
|space_id;                          |                                                     
|                                   |                                                     
|last_map_page;                     |                                                     
|last_map_page_full;                |                                                     
|first_data_page;                   |  --- first data page's entry page id                
|last_page;                         |                                                     
|page_count;                        |                                                     
|free_lists[SEG_FREE_LIST_COUNT];   |                                                     
|empty_list;                        |                                                                                 
|free_map_list;                     |
|min_list_id;                       |
|pct_free;                          |
|reserve[2];                        |
|reserve2[64];                      |
|                                   |             
|child_seg;                         |
+-----------------------------------+
```
