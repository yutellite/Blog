```c
cache_root page                                                       cache_root page                                                       
16777561  4->345                                                      root page(details)    (spc_page_head_t *)
page head                                                             page_head  p *(spc_page_head_t*)(dev_entry[4].mem_entry+345*8192)
page_head  p *(spc_page_head_t*)(dev_entry[4].mem_entry+345*8192)    +----------------------------+
entry map page(segment map page(entry))                              |latch;                      |{spinlock=0,latch_mode=0,latch_cnt=0}
 +-----------------------------+80Bytes                              |mutex;                      |0
 |page head    map_page_id     |                                     |chg_num;                    |3
 |             map_offset      |                                     |page_id;                    |16777561  4->345 
 |            (map info)       |                                     |obj_id;                     |69
 |            map_page_id;     |                                     |page_create_no;             |0
 |            map_offset;      |                                     |seg_type;                   |4
 |            unused[2];       |                                     |page_type;                  |3
 |                             |                                     |                            |
 |            (page usage info)|                                     |(map info)                  |
 |            free_begin;      |+=sizeof(btree_node_head_t)          |map_page_id;                |16777482
 |            free_end;        |                                     |map_offset;                 |78
 |            del_count;       |                                     |unused[2];                  |0
 |            data_begin;      |data_begin=free_begin                |                            |
 |             ...             |                                     |(page usage info)           |
 |btree_node_head(28B) next    |DB_INVALID_ID32                      |free_begin;                 |152
 |                  prev       |DB_INVALID_ID32                      |free_end;                   |8180
 |                 level       |0                                    |del_count;                  |0
 |            slot_count       |0                                    |data_begin;                 |80
 |            reserved[16]     |0...                                 |                            |
 |                             |                                     |(checkpoint info)           |
 | row data1     row data2     |                                     |ckpt_id;                    |475
 | row data3     row data4     |                                     |mirror_page;                |4294967295
 | row data5     row data6     |                                     |next_ckpt_page;             |4294967295
 |   ...           ...         |                                     |dirty_flag;                 |0
 |   -->                       |                                     |                            |
 |                             |                                     |valid_flag;                 |0
 |                             |                                     |                            |
 |                             |                                     |(flag info)                 |
 |                             |                                     |flag;                       |0
 |                       <---- |                                     |fl_flag;                    |1
 |...|slot_offset3|slot_offset2|                                     |                            |
 |slot_offset1|spc_page_tail_t | 8Byte                               |hash_tab_head;              |{used_flag=0,unused=0,page_count=0}
 +-----------------------------+                                     |hash_page_type;             |0
 'spc_page_tail_t' is used to crc valid check for the page           |reserve[15];                |0
BTREE_GET_SLOT_ADDR(page,0)=                                         +----------------------------+
#define BTREE_GET_SLOT_ADDR(page, slot_id)   \                        
    (db_uint16 *)((db_char *)(page) + SPC_PAGE_SIZE -                btree_node_head  *(btree_node_head_t*)(page_addr+80)                                                                                                                                                                                                                                                                                                                                          
    (SPC_PAGE_TAIL_SIZE + ((slot_id) + 1) * sizeof(db_uint16)))      sizeof(heap_node_heat_t)=28                                                                                                             
                                                                     +-----------------------------+                                                                                                                
                                                                     |btree_node_head   next       |4294967295 -- none use                                                                                   
                                                                     |                  prev       |4294967295                                                                                                      
                                                                     |                 level       |2                                                                                                    
                                                                     |            slot_count       |2                                                                                                        
                                                                     |            reserved[16]     |0                                                                                                         
                                                                     +-----------------------------+                                                                                                         
                                                                                                                                                                                                             
                                                                     +-----------------------------+                                                                                                         
                                                                     | row data1                   |                                                                                                         
                                                                     | knl_key_header_t(sizeof=24) |    <-----page_addr+104                                                                                  
                                                                     |             lock_id         |592                                                                                                      
                                                                     |             size            |20                                                                                                       
                                                                     |             col_count       |2                                                                                                        
                                                                     |             bit_array       |13   (int i,varchar(10) s)  Note:the bit_array of the row header is extenedable, see explainaion below.  
                                                                     |01  00  00  00  02  00  32  00    <-----104+12--record(1,'2')---'2' ascii=0x32                                                         
                                                                     |50  02  00  00  14  00  02  00    --02 00 record the length of varchar(10) is 2                                                        
                                                                     |0d  00  00  00               |    here user db_uint16 to count the length of varchar                                                   
                                                                     | row data2                   |    in GMDB, the max varchar is 4000Byte. and the max binary is 32602                                    
                                                                     | knl_key_header_t(sizeof=24) |    <-----page_addr+124                                                                                  
                                                                     |             lock_id         |592                                                                                                      
                                                                     |             size            |20                                                                                                       
                                                                     |             col_count       |2                                                                                                        
                                                                     |             bit_array       |13                                                                                                       
                                                                     |02  00  00  00  02  00  33  00    <-----124+12--record(2,'3')---'3' ascii=0x33                                                         
                                                                     |80  02  00  00  18  00  02  00                                                                                                         
                                                                     |0d  00  00  00               |                                                                                                         
                                                                     | row data3             <---- |    <-----144+12                                                                                         
                                                                     | knl_key_header_t(sizeof=24) |    <-----page_addr+124                                                                                  
                                                                     |             lock_id         |640                                                                                                      
                                                                     |             size            |24                                                                                                       
                                                                     |             col_count       |2                                                                                                        
                                                                     |             bit_array       |13                                                                                                       
                                                                     |00  00  00  00  06  00  68  65    <-----124+12--record(2,'hello')---'3' ascii=0x33                                                     
                                                                     |6c  6c  6f  00  80  02  00  00    --06 00 record the length of varchar(10) is 6                                                        
                                                                     |18  00  02  00  0d  00  00  00                                                                                                         
                                                                     |    ...     |slot_offset3|   |                                                                                                         
                                                                     | |   |108|128|spc_page_tail_t| 8Byte                                                                                                   
                                                                     +-----------------------------+                                                                                                         
                                                                     'slot_offset' record the slot's relative offset to page addr. 
```
