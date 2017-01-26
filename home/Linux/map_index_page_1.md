tbl_id:66                                                                                            
record num:150002                                                                                    
used pages:644                                                                                       
column:  INT 4                                                                                       
         varchar(10)                                                                                 
index:TBL_YWX_I
        primary key(I)                                       

create index
the same as create table, when we first create a index, we create a segment for the index, which includes map pages and index pages. while ,the difference is 
,in tables, we record the first_data_page, so we can find the map pages through the first_data_page. In index, we also have first_data_page. but we get the
index segment though the GA. which the segment's addr is recorded in the table indexes dc.

//create table 
//When we first create a table, we create a segment for the table, which includes mpa pages and data pages, the first map page is the entry of the table.
//When we want to fetch the rows of the table, we first find its segment, the get the entry of the map page, then the first data page in the map page.

given an index, how to get the index page.
1 get index describe through the table handle and index id.
    idx_des = dc_get_index_des(session, tbl_handle, index_id)
2 get the seg_segment_t page through the idx_des->segment in GA pool.
    idx_seg = (seg_segment_t*)SGA_OFFSET2ADDR(iex_des->segment) 
 
//table_entry->segment(entry)->first_data_page
//page_id=dev_id<<22+offset
//page_addr=dev_entry[dev_id]+offset*page_size

entry map page(segment map page(entry))                                       2nd map page                             3rd map page                            Nth map page                   
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
 
 1st index data page                    
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

btree_root_info
+-----------------------+
| uint32      root      |  
| uint16      level     |
|   char      reserve[2]|
|                       |
+-----------------------+

more details.
       
/* index descriptor structure */
typedef struct tagdc_index_des
{
    db_ulong            index_info;     /* index information --> knl_index_t*/
    db_ulong            segment;        /* the data segment offset*/
    db_ulong            ex_segment;     /* hash segment for hash index */
    db_ulong            rebuild_seg;    /* for rebuild index*/
    db_ulong            rebuild_ex_seg;
}dc_index_des_t;                                                    
                                                                                                     
index seg entry（this is the entry table map page and index page）                                    
                                                                                                     
[seg_segment]
p *idx
$12 = {index_info = 376699224, segment = 376664664, ex_segment = 0, rebuild_seg = 0, rebuild_ex_seg = 0}
p *(seg_segment_t*)((db_char*)g_sys_area_addr+376664664)
 
given an index, how to get the index page.
1 get index describe through the table handle and index id.
    idx_des = dc_get_index_des(session, tbl_handle, index_id)
2 get the seg_segment_t page through the idx_des->segment in GA pool.
    idx_seg = (seg_segment_t*)SGA_OFFSET2ADDR(iex_des->segment)
