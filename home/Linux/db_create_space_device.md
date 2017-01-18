```c
 p*def
$36 = {
space_info = {name = "YWX", '\000' <repeats 28 times>, space_type = SPC_PERM_SPACE_TYP}, 
devices = {count = 1,capacity = 256, item_size = 36, extend_size = 256, items = 0x2b89c05e8170}}

typedef struct tagknl_device_t
{
    db_uint32           version;
    db_bool             is_valid;
    db_char             name[DB_MAX_NAME_LEN];
    db_uint32           page_num;  -->device page_num
    db_page_id          entry;
    db_uint16           id;
    db_uint8            space_id;
    db_char             reserve1[1];
    db_char             reserve2[16];
}knl_device_t;

typedef struct tagspc_space_head_t
{
    db_uint32               seg_num;                               /* segment number created in this space */
    cm_chain32_t            free_pages;                            /* all free pages in that chain */
                                count
                                first
                                last
    db_char                 reserved[64];
}spc_space_head_t;

1 spc_create_space

IF spc_device_is_duplicate THEN -->查找on后面的device名字是否有重复名称
    return KNL_ERR_DEVICE_DUPLICATED
FI
IF def->devices.count>128 THEN
    ret TOO_MANY
FI
IF spc_is_exist 
    ->FOR i in SPC_MAX_SPACE(255)
        IF g_db_ctrl_space->spaces[(id)]->name THEN
            ret KNL_ERR_SPACE_EXIST
        FI
THEN
    ret KNL_ERR_SPACE_EXIST
FI
spc_create_disk_files()
    ->IF TEMP or TEMP UNDO or REP SPACE THEN
        ret
      FI
    FOR i in def->devices.count 
        spc_get_perm_space_size
        IF curr_size > 1024*512K 个page_num THEN
            ret EXCEEDED
        FI
    END
    FOR i in def->devices.count 
        spc_dev_is_exist -->find the first free spc_id
        cm_mdb_data  ---->拼接绝对/home/ywx/gmdb/data/ywx.dat
        cm_file_exist
        cm_open_file
        dev_size=dev_def->page_num*page_size
        page_buf=cmalloc(CKPT_FLUSH_BUFF_SIZE->4M)
        FOR i in 4M/page_size -->给4M大小的page_buf，按page_size划分初始化，即对4M/page_size个page进行init
            spc_init_page()---->spc_page_head_t初始化page头部，page_id-->(device_id<<22+curr_page_offset)
        END
        
        spc_format_normal_device
        
        IF count=0&&!is_add_dev THEN -->即tbs第一个device文件的第一个page的page_head之后记录spc_space_head信息,page_head + sizeof (spc_page_head_t) + sizeof(spc_device_head_t) + sizeof(spc_space_head_t));
            spc_init_dev_head(page_head,space_head);
        FI
        
        FOR i in dev_size/4M        -->即按CKPT_FLUSH_BUFF_SIZE即4M大小为一批来初始化
            cm_write_file(fd,page_buf,4M);
            FOR j in 4M/page_size
                spc_init_page(SPC_MAKE_PAGE_ID(dev_id,curr_page_num))-->4M大小内部再初始化page
            END
        END
        
        IF 0！=dev_size%4M THEN
            cm_write_file(page_buf,dev_size%4M)-->剩余的写入，但是不初始化page，估计是弃之不用
        FI
ckpt_begin_atomic_op()        
spc_get_space_ctrl()
    #define SPC_GET_SPACE(id) (&g_db_ctrl_space->spaces[(id)])   --->gmstat -ts取的源地，记录了系统索引表空间，这里要准备init这块地方
    通过space_id在g_db_ctrl_space中找到目标的space
    spc_create_device
----------------(#define SPC_GET_DEVICE(id) (&g_db_ctrl_space->devices[(id)]))
FOR i in def->devices.count 
    spc_create_device
        ->spc_build_mem_device          -------dev_entry记录了device的共享内存对应的入口地址
            ->cm_get_shm                -----创建共享内存
            ->dev_entry[id].mem_entry 
            ->dev_entry[id].mem_latch_entry
            ->spc_format_device
                -->spc_format_normal_device(session, id, dev_entry[id].mem_entry, dev->page_num, space->type)   
                --->这里需要注意的是，对于device文件和device对应的共享内存来说，在第一个device文件第一个page头部之后page_head + sizeof (spc_page_head_t)（80B） + sizeof(spc_device_head_t)（76B） + sizeof(spc_space_head_t))（80B）;
                typedef struct tagspc_device_head_t
                {
                    db_uint32         page_count;         /* page count include device head page */
                    db_uint32         hwm;                /* high water mark */
                    db_uint32         free_page_count;    /* free page count, hash table use it*/
                    db_char           reserved[64];
                }spc_device_head_t;
        IF first_device THEN
            ->spc_init_dev_head
        FI
        spc_open_disk_files
        spc_add_device_to_space
            g_db_ctrl_space->spaces[9]--->全局变量记录的所有的space中的entry为其第一个page的page_id
            $162 = {mutex = 0, is_valid = 1, entry = 37748736, type = SPC_PERM_SPACE_TYP, name = "YWX", '\000' <repeats 28 times>, dev_id = {
                9, 0 <repeats 127 times>}, id = 9 '\t', dev_count = 1 '\001', reserve1 = "\000", reserve2 = '\000' <repeats 31 times>}
    IF need_redo THEN
        rd_write_redo
    FI
    
    ckpt_end_atomic_op
    
    IF need_redo THEN
        rd_write_redo
    FI
    
    knl_save_ctrl_files_tail
END
    

<1033 linux6 [ywx] :/onip/ywx/gmdb/data>gmstat -d
 devices information:

 ID    device name      bytes         file name        table space      create time         
 ----- ---------------- ------------- ---------------- ---------------- ----------------------- 
 0     SYSTEM_DEV       33554432      SYSTEM_DEV       SYSTEM           Sat Jan 14 10:58:04 2017
 1     UNDO_DEV         33554432      UNDO_DEV         UNDO             Sat Jan 14 10:58:04 2017
 2     TEMP_DEV         33554432      TEMP_DEV         TEMP             Sat Jan 14 10:58:04 2017
 3     TEMP_UNDO_DEV    33554432      TEMP_UNDO_DEV    TEMP_UNDO        Sat Jan 14 10:58:04 2017
 4     USER_DEV         33554432      USER_DEV         USER             Sat Jan 14 10:58:04 2017
 5     HASH_DEV         33554432      HASH_DEV         HASH             Sat Jan 14 10:58:04 2017
 6     HASH_TEMP_DEV    33554432      HASH_TEMP_DEV    HASH_TEMP        Sat Jan 14 10:58:04 2017
 7     REP_UNDO_DEV     33554432      REP_UNDO_DEV     REP_UNDO         Sat Jan 14 10:58:04 2017
 8     REP_DEV          33554432      REP_DEV          REP              Sat Jan 14 10:58:04 2017
 9     rep.dat          3221225472    rep.dat          REP              Sat Jan 14 10:58:07 2017
 10    rep_undo.dat     536870912     rep_undo.dat     REP_UNDO         Sat Jan 14 10:58:07 2017
 11    rep.dat1         4294967296    rep.dat1         REP              Sat Jan 14 10:58:11 2017
 12    user.dat1        4294967296    user.dat1        USER             Sat Jan 14 10:58:08 2017
 13    user.dat2        4294967296    user.dat2        USER             Sat Jan 14 10:58:08 2017
 14    undo.dat1        3221225472    undo.dat1        UNDO             Sat Jan 14 10:58:10 2017
 15    ywx.dat          104857600     ywx.dat          YWX              Mon Jan 16 11:20:58 2017
 
 解析ywx.dat文件
 即tbs第一个device文件的第一个page的page_head之后记录spc_space_head信息
 (gdb) p sizeof(spc_page_head_t)
$117 = 80=0x50
(gdb) p sizeof(spc_space_head_t)
$118 = 80=0x50
(gdb) 

spc_space_head_t
    db_uint32               seg_num;                               /* segment number created in this space */
    cm_chain32_t            free_pages;                            /* all free pages in that chain */
                                count  db_uint32
                                first  db_uint32
                                last  db_uint32
    db_char                 reserved[64];
spc_space_head_t

page_num=0(page_size=32K,即每个page地址偏移8000)
000000  00  00  00  00  00  00  00  00  00  00  00  00  00  00  00  00
        \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0
page_id=0(page_id在head的偏移为16个字节)
下面page_id=03c00000-->page_id>>22=15  offset=0
000010  00  00  c0  03  ff  ff  ff  ff  ff  ff  00  00  ff  ff  ff  ff
        \0  \0 300 003 377 377 377 377 377 377  \0  \0 377 377 377 377
000020  ff  ff  00  00  f0  00  f8  7f  00  00  ec  00  00  00  00  00
       377 377  \0  \0 360  \0 370 177  \0  \0 354  \0  \0  \0  \0  \0
000030  ff  ff  ff  ff  ff  ff  ff  ff  00  00  00  00  00  00  00  00
       377 377 377 377 377 377 377 377  \0  \0  \0  \0  \0  \0  \0  \0
000040  00  00  00  00  00  00  00  00  00  00  00  00  00  00  00  00
        \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0
space_head
seg_num=0x00000c80
free_pages= 0x00000001 
first=last=0xffffffff   
reserved[64]=ff   
000050  80  0c  00  00  01  00  00  00  ff  ff  ff  ff  ff  ff  ff  ff
       200  \f  \0  \0 001  \0  \0  \0 377 377 377 377 377 377 377 377
000060  ff  ff  ff  ff  ff  ff  ff  ff  ff  ff  ff  ff  ff  ff  ff  ff
       377 377 377 377 377 377 377 377 377 377 377 377 377 377 377 377
*
000090  ff  ff  ff  ff  ff  ff  ff  ff  ff  ff  ff  ff  00  00  00  00
       377 377 377 377 377 377 377 377 377 377 377 377  \0  \0  \0  \0
0000a0  00  00  00  00  ff  ff  ff  ff  ff  ff  ff  ff  ff  ff  ff  ff
        \0  \0  \0  \0 377 377 377 377 377 377 377 377 377 377 377 377
0000b0  ff  ff  ff  ff  ff  ff  ff  ff  ff  ff  ff  ff  ff  ff  ff  ff
       377 377 377 377 377 377 377 377 377 377 377 377 377 377 377 377
*
007ff0  ff  ff  ff  ff  ff  ff  ff  ff  00  00  00  00  00  00  00  00
       377 377 377 377 377 377 377 377  \0  \0  \0  \0  \0  \0  \0  \0
page_num=1(page_size=32K,即每个page地址偏移8000)
008000  00  00  00  00  00  00  00  00  00  00  00  00  00  00  00  00
        \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0
下面page_id=03c00001-->page_id>>22=15  offset=1
008010  01  00  c0  03  ff  ff  ff  ff  ff  ff  00  01  ff  ff  ff  ff
       001  \0 300 003 377 377 377 377 377 377  \0 001 377 377 377 377
008020  ff  ff  00  00  50  00  f8  7f  00  00  50  00  00  00  00  00
       377 377  \0  \0   P  \0 370 177  \0  \0   P  \0  \0  \0  \0  \0
008030  ff  ff  ff  ff  ff  ff  ff  ff  00  00  00  00  00  00  00  00
       377 377 377 377 377 377 377 377  \0  \0  \0  \0  \0  \0  \0  \0
008040  00  00  00  00  00  00  00  00  00  00  00  00  00  00  00  00
        \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0
008050  ff  ff  ff  ff  ff  ff  ff  ff  ff  ff  ff  ff  ff  ff  ff  ff
       377 377 377 377 377 377 377 377 377 377 377 377 377 377 377 377
*
00fff0  ff  ff  ff  ff  ff  ff  ff  ff  00  00  00  00  00  00  00  00
       377 377 377 377 377 377 377 377  \0  \0  \0  \0  \0  \0  \0  \0
page_num=2(page_size=32K,即每个page地址偏移8000)
010000  00  00  00  00  00  00  00  00  00  00  00  00  00  00  00  00
        \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0
下面page_id=03c00002-->page_id>>22=15  offset=2        
010010  02  00  c0  03  ff  ff  ff  ff  ff  ff  00  03  ff  ff  ff  ff
       002  \0 300 003 377 377 377 377 377 377  \0 003 377 377 377 377
010020  ff  ff  00  00  50  00  f8  7f  00  00  50  00  00  00  00  00
       377 377  \0  \0   P  \0 370 177  \0  \0   P  \0  \0  \0  \0  \0
010030  ff  ff  ff  ff  ff  ff  ff  ff  00  00  00  00  00  00  00  00
       377 377 377 377 377 377 377 377  \0  \0  \0  \0  \0  \0  \0  \0
010040  00  00  00  00  00  00  00  00  00  00  00  00  00  00  00  00
        \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0
010050  ff  ff  ff  ff  ff  ff  ff  ff  ff  ff  ff  ff  ff  ff  ff  ff
       377 377 377 377 377 377 377 377 377 377 377 377 377 377 377 377

(gdb) p dev_entry[15]
$12 = {lock = 0, version = 3, mem_entry = 0x2b7868be2000 "", mem_latch_entry = 0x2b786efe2000 "", disk_entry = 14, is_client = 0}
(gdb) x 0x2b7868be2000       
共享内存中对应的device mem_entry，只有第一个page初始化了信息
(gdb) x/20x 0x2b7868be2000 
0x2b7868be2000: 0x00000000      0x00000000      0x00000000      0x00000000
0x2b7868be2010: 0x03c00000      0xffffffff      0x0000ffff      0xffffffff
0x2b7868be2020: 0x0000ffff      0x7ff800f0      0x00ec0000      0x00000000
0x2b7868be2030: 0xffffffff      0xffffffff      0x00000000      0x00000000
0x2b7868be2040: 0x00000000      0x00000000      0x00000000      0x00000000
(gdb) x/20x 0x2b7868be2000+0x8000
0x2b7868bea000: 0x00000000      0x00000000      0x00000000      0x00000000
0x2b7868bea010: 0x00000000      0x00000000      0x00000000      0x00000000
0x2b7868bea020: 0x00000000      0x00000000      0x00000000      0x00000000
0x2b7868bea030: 0x00000000      0x00000000      0x00000000      0x00000000
0x2b7868bea040: 0x00000000      0x00000000      0x00000000      0x00000000
(gdb) x/x 0x2b7868be2000+0x8000
0x2b7868bea000: 0x00000000
(gdb) x/20x 0x2b7868be2000+0x8000
0x2b7868bea000: 0x00000000      0x00000000      0x00000000      0x00000000
0x2b7868bea010: 0x00000000      0x00000000      0x00000000      0x00000000
0x2b7868bea020: 0x00000000      0x00000000      0x00000000      0x00000000
0x2b7868bea030: 0x00000000      0x00000000      0x00000000      0x00000000
0x2b7868bea040: 0x00000000      0x00000000      0x00000000      0x00000000
(gdb) x/20x 0x2b7868be2000+0x8000*2
0x2b7868bf2000: 0x00000000      0x00000000      0x00000000      0x00000000
0x2b7868bf2010: 0x00000000      0x00000000      0x00000000      0x00000000
0x2b7868bf2020: 0x00000000      0x00000000      0x00000000      0x00000000
0x2b7868bf2030: 0x00000000      0x00000000      0x00000000      0x00000000
0x2b7868bf2040: 0x00000000      0x00000000      0x00000000      0x00000000       
```
