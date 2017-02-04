```c
tbl_name;TBL_YWX                                                                                                                                             
tbl_id:66                                                                                                                                                    
record num:150002                                                                                                                                            
used pages:644                                                                                                                                               
column:  INT 4                                                                                                                                               
         varchar(10)                                                                                                                                         
index:no                                                                                                                                                     
SQL>set autocommit off;                                                                                                                                      
SQL>select * from tbl where rownum<2;                                                                                                                        
I           S                                                                                                                                                
----------- ----------                                                                                                                                       
0           hello                                                                                                                                            
                                                                                                                                                             
SQL>update tbl set s='hello1' where i=0;update                                                                                                               
                                                                                                                                                             
b heap_get_row_from_undo                                                                                                                                     
SQL>select * from tbl where I=0;                                                                                                                             
undo page                                                   page_head                                                                                        
+-----------------------------+                             +----------------------------+                                                                   
|page head    map_page_id     |                             |latch;                      |{spinlock = 0, latch_mode = 0, latch_cnt = 0}                      
|             map_offset      |                             |mutex;                      |0                                                                  
|            (map info)       |                             |chg_num;                    |606                                                                
|            map_page_id;     |                             |page_id;                    |4194309                                                            
|            map_offset;      |                             |obj_id;                     |1                                                                  
|            unused[2];       |                             |page_create_no;             |46                                                                 
|                             |                             |seg_type;                   |2                                                                  
|            (page usage info)|                             |page_type;                  |3                                                                  
|            free_begin;      |                             |                            |                                                                   
|            free_end;        |                             |(map info)                  |                                                                   
|            del_count;       |                             |map_page_id;                |4194308                                                            
|            data_begin;      |                             |map_offset;                 |0                                                                  
|             ...             |                             |unused[2];                  |0                                                                  
|ud_head_t                    | --> page_addr + data_begin  |                            |                                                                   
|            slot_count       |                             |(page usage info)           |                                                                   
|            reserved[16]     |                             |free_begin;                 |132                                                                
|                             |                             |free_end;                   |32758                                                              
| row data1     row data2     |                             |del_count;                  |0                                                                  
| row data3     row data4     |                             |data_begin;                 |80                                                                 
| row data5     row data6     |                             |                            |                                                                   
|   ...           ...         |                             |(checkpoint info)           |                                                                   
|   -->                       |                             |ckpt_id;                    |15                                                                 
|                             |                             |mirror_page;                |4294967295                                                         
|                             |                             |next_ckpt_page;             |16777223                                                           
|                             |                             |dirty_flag;                 |1                                                                  
|                             |                             |                            |                                                                   
|                       <---- |                             |valid_flag;                 |0                                                                  
|...|slot_offset3|slot_offset2|                             |                            |                                                                   
|slot_offset1|spc_page_tail_t | 8Byte                       |(flag info)                 |                                                                   
+-----------------------------+                             |flag;                       |0                                                                  
                                                            |fl_flag;                    |0                                                                  
                                                            |                            |                                                                   
                                                            |hash_tab_head;              |{used_flag = 0, unused = 0, page_count = 0}                        
                                                            |hash_page_type;             |0                                                                  
                                                            |reserve[15];                |0                                                                  
                                                            +----------------------------+                                                                   
                                                                                                                                                             
                                                            ud_head_t  *(ud_head_t*)(page+data_bigin)(+80)                                                   
                                                            sizeof(ud_head_t)=4                                                                              
                                                            +-----------------------------+                                                                  
                                                            |ud_head_t                    |                                                                  
                                                            |  db_uint16 slot_count       |1                                                                 
                                                            |  db_uint8  reserved[16]     |0                                                                 
                                                            +-----------------------------+                                                                  
slot_addr=((db_uint16 *)((db_char *)(page)+ SPC_PAGE_SIZE  - (SPC_PAGE_TAIL_SIZE + (((0) + 1) * sizeof(db_uint16)))))                                        
                                                                                                                                                             
                                                            ud_row_head_t  *(ud_row_head_t*)(page+84)                                                        
                                                            sizeof(ud_head_t)=24                                                                             
                                                            +-----------------------------+                                                                  
                                                            |ud_row_head_t                |                                                                  
                                                            |  ud_res_t    res            |{row_id = {page_id = 16777223, slot_id = 0, sid_reserve = 65535}, 
                                                            |                             |lock_id = 592, obj_id = 55, seg_entry = 16777222}                 
                                                            |  db_uint16   size           |48                                                                
                                                            |  db_uint8    op_type        |2                                                                 
                                                            |  db_uint8    reserved[1]    |\377                                                              
                                                            +-----------------------------+                                                                  
/* Undo operation type */                                                                                                                                    
typedef enum tagud_op_type_e                                knl_row_header_t  *(knl_row_header_t*)(page+84+24)                                               
{                                                           sizeof(knl_row_header_t)=12                                                                      
    UD_OP_TYPE_HEAP_INSERT          = 0x00,                 +-----------------------------+                                                                  
    UD_OP_TYPE_HEAP_UPDATE          = 0x01,                 |ud_row_head_t                |                                                                  
    UD_OP_TYPE_HEAP_UPDATE_INC      = 0x02,                 |  db_uint32    lock_id       |4294967295                                                        
    UD_OP_TYPE_HEAP_DELETE          = 0x03,                 |  db_uint16   size           |20                                                                
    UD_OP_TYPE_BTREE_INSERT         = 0x04,                 |  db_uint16    col_count     |1                                                                 
    UD_OP_TYPE_BTREE_DELETE         = 0x05,                 |  db_uint32    bit_array[1]  |3                                                                 
    UD_OP_TYPE_HASH_INSERT          = 0x06,                 |                             |                                                                  
    UD_OP_TYPE_HASH_DELETE          = 0x07,                 |06  00  68  65  6c  6c  6f  00 <----record('hello')                                             
    UD_OP_TYPE_BTREE_INSERT_SHADOW  = 0x08,                 |01  00  04  00  00  4c  02  00                                                                  
    UD_OP_TYPE_BTREE_DELETE_SHADOW  = 0x09,                 |00  00  00  11               |                                                                  
    UD_OP_TYPE_HASH_INSERT_SHADOW   = 0x0A,                 |                             |                                                                  
    UD_OP_TYPE_HASH_DELETE_SHADOW   = 0x0B,                 +-----------------------------+                                                                  
    UD_OP_TYPE_CREATE_SEGMENT       = 0x0C,                                                                                                                  
    UD_OP_TYPE_SET_DROP             = 0x0D,                                                                                                                  
    // BEGIN C12-108   liangyuansheng 142695 2012-1-9 ADD ONIP DataGrid V3R2C12                                                                              
    UD_OP_TYPE_LOB_INSERT           = 0x0E,                                                                                                                  
    UD_OP_TYPE_LOB_DELETE           = 0x0F,                                                                                                                  
    // END C12-108   liangyuansheng 142695 2012-1-9 ADD ONIP DataGrid V3R2C12                                                                                
    UD_OP_TYPE_BUTT                 = 0xFF                                                                                                                   
} ud_op_type_e;                                                                                                                                              

```
