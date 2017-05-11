```c
ckpt_write_page 
    ckpt_flush 
    ckpt_copy_page 
 
 
ckpt_mirror_page 
 
ckpt_flush 
    ckpt_flush_to_device 
 
 
ckpt_prepare 
    ckpt_get_flush_info 
    rd_flush_queue 
 
 
 
ckpt_worker 
    while is_running 
    do 
        ckpt_write_page 
        ckpt_flush 
        ckpt_flush_to_safe_file 
    done 
 
 
ckpt_perform 
    ckpt_prepare 
    IF page_count>0 THEN 
        ckpt_trigger_workers 
    FI 
    IF rd_point_cmp>0 THEN 
        rd_set_rcy_point 
    FI 
    knl_save_ctrl_files 
    rd_point_minus 
 
ckpt_trigger--->trigger to perform checkpoint 
    IF KNL_CKPT_MODE_NOTIFY == ckpt_mode 
        g_database->ckpt_ctx->is_trigger=DB_TRUE 
        return 
    FI 
 
    WHILE g_database->ckpt_ctx->is_trigger 
    do 
        cm_sleep(100) 
    done 
 
    g_database->ckpt_ctx->is_trigger=DB_TRUE 
 
    WHILE g_database->ckpt_ctx->is_trigger 
    do 
        cm_sleep(100) 
    done 
 
 
 
g_instance 
+------------------------------------+ 
|typedef struct tagknl_inst          | 
|{                                   | 
|    db_uint32           latch;      |/*instance concurrency protect latch*/ 
|    db_uint32           version;    | 
|    db_uint32           inst_size;  | 
|    db_uint8            status;     |/* instance status */ 
|    db_uint8            reserved[3];| 
|    session_list_t      session_list|; 
|    knl_database_t      database;   |g_database 
|}knl_inst_t;                        | 
+------------------------------------+ 
 
g_database                                                                                                                  g_database 
+---------------------------------------+                                                                                   +---------------------------------------+ 
|typedef struct tagknl_database         |                                                                                   |typedef struct tagknl_database         | 
|{                                      |                                                                                   |{                                      | 
|    cm_thread_lock_t    ctrl_lock;     |    /*latch it when update and save control space*/                                |    cm_thread_lock_t    ctrl_lock;     | 
|    cm_thread_lock_t    dev_file_lock; |    /* lock it when create/drop space and add device. while creating the disk file |    cm_thread_lock_t    dev_file_lock; | 
|                                       |    itself we need to know the device id to initial each page in the disk. so      |                                       | 
|                                       |    this lock will make sure that device is not used by others. */                 |                                       | 
|    cm_spinlock_t       space_lock;    |                                                                                   |    cm_spinlock_t       space_lock;    | 
|    cm_spinlock_t       tid_lock;      |                                                                                   |    cm_spinlock_t       tid_lock;      | 
|    cm_spinlock_t       rowver_lock;   |    /* lock it when doing DDL or adding row version */                             |    cm_spinlock_t       rowver_lock;   | 
|    db_uint64           global_tid;    |    /* global txn id,here for increment by session */                              |    db_uint64           global_tid;    | 
|    volatile db_bool    is_chg_tail;   |    /*if you change control tail, you must set the variable to true.*/             |    volatile db_bool    is_chg_tail;   | 
|    db_bool             quick_start;   |                                                                                   |    db_bool             quick_start;   | 
|    rd_context_t        redo_ctx;      |                                                                                   |    rd_context_t        redo_ctx;      | 
|    ud_ctx_t            perm_undo_ctx; |                                                                                   |    ud_ctx_t            perm_undo_ctx; | 
|    ud_ctx_t            temp_undo_ctx; |                                                                                   |    ud_ctx_t            temp_undo_ctx; | 
|    ud_ctx_t            rep_undo_ctx;  |                                                                                   |    ud_ctx_t            rep_undo_ctx;  | 
|    ckpt_ctx_t          ckpt_ctx;      | ->mirror_buf==>1024个page缓存                                                     |    ckpt_ctx_t          ckpt_ctx;      | 
|    ckpt_flush_ctx_t    flush_ctx[CM_PA|RAM_MAX_CKPT_WORKER_COUNT];                                                        |    ckpt_flush_ctx_t    flush_ctx[CM_PA|RAM_MAX_CKPT_WORKER_COUNT 
|    db_bool             is_monitor_on; |                                                                                   |    db_bool             is_monitor_on; | 
|    db_bool             is_schema_sync;|                                                                                   |    db_bool             is_schema_sync;| 
|    spc_space_runtime_info_t    spaces[|SPC_MAX_SPACE];                                                                    |    spc_space_runtime_info_t    spaces[|SPC_MAX_SPACE] 
|    db_bool             enable_recycle;|                                                                                   |    db_bool             enable_recycle;| 
|    db_bool             is_rep_swtich; |                                                                                   |    db_bool             is_rep_swtich; | 
|    sr_ctx_t            sr_ctx;        |                                                                                   |    sr_ctx_t            sr_ctx;        | 
|    btree_recycle_stat_t recycle_stat; |                                                                                   |    btree_recycle_stat_t recycle_stat; | 
|    volatile db_bool    gc_worked;     |                                                                                   |    volatile db_bool    gc_worked;     | 
|    db_int32            rebuild_time;  |                                                                                   |    db_int32            rebuild_time;  | 
|    db_uint64           reset_dcn;     |     /*open db roll forward to reset_dcn given by user*/                           |    db_uint64           reset_dcn;     | 
|    volatile db_bool    is_rs_restore; |    /*set to be true when rep-space restore*/                                      |    volatile db_bool    is_rs_restore; | 
|    knl_db_upgrade_type_e  upgrade;    |    /*upgrade systable for schema AR-0000698311*/                                  |    knl_db_upgrade_type_e  upgrade;    | 
|}knl_database_t;                       |                                                                                   |}knl_database_t;                       | 
+---------------------------------------+                                                                                   +---------------------------------------+ 
 
g_database->ckpt_ctx 
+---------------------------------------+           	 
|typedef struct tagckpt_ctx_t           | 
|{                                      | 
|    cm_spinlock_t       atomic_mutex;  | =>0 
|    cm_spinlock_t       queue_mutex;   | =>2 
|    cm_spinlock_t       mirror_mutex;  | =>0                                                                                             	 
|    cm_thread_lock_t    backup_lock;   | =>{__data={__lock=0,__count=0;__owner=0,__nusers=0,__kind=1,__spins=0,__list={__prev=0x0,__next=0x0},__size=0,__align=0} 
|                                       |                                                                                       rcy_point_map[CKPT_MAX_GROUPS]=512k 
|    db_bool             is_working;    | =>0                                                                                   {{file_id = 235, seek_pos = 128997720, dcn = 19961}, 
|    db_bool             is_trigger;    | =>1                                                                                   {file_id = 235, seek_pos = 128998196, dcn = 19962}, 
|                                       |                                                                                       {file_id = 235, seek_pos = 128999228, dcn = 19963}, 
|    db_uint32           active_id;     | =>719                                                                                 {file_id = 236, seek_pos = 96, dcn = 19964}, 
|    db_uint32           curr_id;       | =>720                                                                                 {file_id = 236, seek_pos = 59846340, dcn = 19978}, 
|    db_uint32           curr_get_num;  | =>78241                                                                               {file_id = 236, seek_pos = 117271168, dcn = 19991}, 
|    db_uint32           curr_put_num;  | =>78240                                                                               {file_id = 237, seek_pos = 47073992, dcn = 20005}, 
|    db_uint32           active_get_num;| =>38302                                                                               {file_id = 237, seek_pos = 102317996, dcn = 20018}, 
|    db_uint32           active_put_num;| =>38302                                                                               {file_id = 238, seek_pos = 28768448, dcn = 20032}, 
|                                       |                                                                                       {file_id = 238, seek_pos = 88041576, dcn = 20046}, 
|    db_uint32           active_group;  | =>25                                                                                  {file_id = 239, seek_pos = 12182812, dcn = 20059}, 
|    db_uint32           curr_group;    | =>26                                                                                  {file_id = 239, seek_pos = 71139660, dcn = 20073}, 
|    db_uint32           sub_count;     | =>350                                                                                 {file_id = 239, seek_pos = 132473776,dcn = 20087}, 
|                                       |                                                                                       {file_id = 240, seek_pos = 58401832, dcn = 20100}, 
|    rd_point_t          rcy_point_map[C|KPT_MAX_GROUPS]; =>                                                                    {file_id = 240, seek_pos = 92191936, dcn = 20110}, 
|    rd_point_t          lrp;           | =>lrp = {file_id = 235, seek_pos = 128997720,dcn = 19961}                             {file_id = 240, seek_pos = 131779064, dcn = 20119}, 
|                                       |                                                                                       {file_id = 241, seek_pos = 60977380, dcn = 20133}, 
|    ckpt_page_list_t    page_list;     | =>page_list = {count = 1374, first = 37755467, last = 16778194}                       {file_id = 241, seek_pos = 118252524, dcn = 20146}, 
|    db_page_id          flush_pages[CKP|T_GROUP_SIZE];                                                                         {file_id = 242, seek_pos = 45102016, dcn = 20160}, 
|                                       |                                                                                       {file_id = 242, seek_pos = 101641736, dcn = 20173}, 
|    db_ulong            mirror_buff;   | =>78048992// To be initialized along with g_database. Size is (CKPT_GROUP_SIZE * page_size).    {file_id = 243, seek_pos = 28880872, dcn = 20187}, 
|    db_uint32           mirror_pos;    | =>0                                                                                   {file_id = 243, seek_pos = 85869452, dcn = 20200}, 
|                                       |                                                                                       {file_id = 244, seek_pos = 15992316, dcn = 20214}, 
|    cm_thread_id_t      thread_id;     |                                                                                       {file_id = 244, seek_pos = 71875628, dcn = 20227}, 
|                                       |                                                                                       {file_id = 244, seek_pos = 133605092, dcn = 20241}, 
|    db_uint32           backup_id;     | // used in backup, to wait for the current atomic operations to finish.               {file_id = 245, seek_pos = 54806768, dcn = 20254}, 
|    db_uint32           backup_put_num;|                                                                                       {file_id = 245, seek_pos = 115102640, dcn = 20268}, 
|    db_uint32           check_id;      |                                                                                       {file_id = 0, seek_pos = 0, dcn = 0} <repeats 524261 times>} 
|    db_uint32           check_put_num; | 
|    db_bool             flush_fast;    | //check if control flush speed. 
|                                       | 
|    ckpt_statistic_t    stat;          |                                                                                       flush_pages = {4194314, 4194315, 4194316, 
|    ckpt_worker_ctx_t   ckpt_worker_ctx|[CM_PARAM_MAX_CKPT_WORKER_COUNT];                                                       4194317, 16777865, 16777867, 16777868, 16777869, 16777870, 16777871, 16777872, 16777873, 16777874, 16777876, 16777877, 
|} ckpt_ctx_t;                          |                                                                                        16777878, 16777879, 16777880, 16777881, 16777882, 16777884, 16777885, 16777886, 16777887, 16777888, 16777889, 16777890, 
+---------------------------------------+                                                                                        16777891, 16777893, 16777894, 16777895, 16777896, 16777897, 16777898, 16777899, 16777900, 16777902, 16777903, 16777904, 
                                                                                                                                 16777905, 16777906, 16777907, 16777908, 16777909, 16777911, 16777912, 16777913, 16777914, 37755001, 37755002, 37755003, 
ckpt_perform     ==> perform as a group unit                                                                                     37755004, 37755005, 37755006, 37755007, 37755008, 37755009, 37755010, 37755011, 37755012, 37755013, 37755014, 37755015, 
    ckpt_prepare(session,&page_count,&rcy_point,&lrp,&save_ctrl) prepare the page_count,rcy_point,and lrp point                  37755016, 37755017, 37755018, 37755019, 37755020, 37755021, 37755022, 37755023, 37755024, 37755025, 37755026, 37755027, 
        ckpt_get_flush_info(session, page_count, rcy_point)==> 
            cm_spin_lock(session->sid,&g_database->ckpt_ctx->queue_mutex) 
            IF 0==g_database->ckpt_ctx->page_list.count THEN                                                                      37755028, 37755029, 37755030, 37755031, 37755032, 37755033, 37755034, 37755035, 37755036, 37755037, 37755038, 37755039, 
                ckpt_get_rcy_point(session,rcy_point)                                                                             37755040, 37755041, 37755042, 37755043, 37755044, 37755045, 37755046, 37755047, 37755048, 37755049, 37755050, 37755051, 
                    IF active THEN                                                                                                37755052, 37755053, 37755054, 37755055, 37755056, 37755057, 37755058, 37755059, 37755060, 37755061, 37755062, 37755063, 
                        rcy_point=SESSION_ID_CKPT.redo_ctx->curr_point                                                            37755064, 37755065, 37755066, 37755067, 37755068, 37755069, 37755070, 37755071, 37755072, 37755073, 37755074, 37755075, 
                    ELSE                                                                                                          37755076, 37755077, 37755078, 37755079, 37755080, 37755081, 37755082, 37755083, 37755084, 37755085, 37755086, 37755087, 
                        rcy_point=SESSION_ID_CKPT.redo_ctx->replay_point                                                          37755088, 37755089, 37755090, 37755091, 37755092, 37755093, 37755094, 37755095, 37755096, 37755097, 37755098, 37755099, 
                    FI                                                                                                            37755100, 37755101, 37755102, 37755103, 37755104, 37755105, 37755106, 37755107, 37755108, 37755109, 37755110, 37755111, 
            FI                                                                                                                    37755112, 37755113, 37755114, 37755115, 37755116, 37755117, 37755118, 37755119, 37755120, 37755121, 37755122, 37755123, 
                                                                                                                                  37755124, 37755125, 37755126, 37755127, 37755128, 37755129, 37755130, 37755131, 37755132, 37755133, 37755134, 37755135, 
            IF g_database->ckpt_ctx->page_list.count <= CKPT_GROUP_SIZE THEN (512k)                                               37755136, 37755137, 37755138, 37755139, 37755140, 37755141, 37755142, 37755143, 37755144, 37755145, 37755146, 37755147, 
                // only one group left in ckpt queue, so new recovery point will be the current redo point                        37755148, 37755149, 37755150, 37755151, 37755152...} 
                *page_count=g_database->ckpt_ctx->page_list.count 
                g_database->ckpt_ctx->active_group=g_database->ckpt_ctx->curr_group 
                g_database->ckpt_ctx->curr_group++                                                                                stat = {cost_time = 255649, mark_time = 7619, atomic_time = 15992, redo_time = 793237, copy_time = 202039, flush_time = 4078442, 
                IF CKPT_MAX_GROUPS== g_database->ckpt_ctx->curr_group                                                                 safe_time = 3873775, ctrl_time = 58351, batch_num = 211, redo_byte = 924465096, page_goup = 25, mirror_page = 84, 
                    g_database->ckpt_ctx->curr_group=0                                                                                ckpt_count = 13, series_pages = 20695, flush_pages = 22005, io_count = 1310, wait_atomic = 15} 
                FI 
                                                                                                                                 ckpt_worker_ctx = 
                g_database->ckpt_ctx->sub_count=0                                                                                    {{session = 0x2b9a3c181c58, flush_ctx = 0x2b9a34ab4828, page_idx_begin = 0, page_idx_end = 1024, thread_id = {idx_in_table = 3, os_id = 47942639195904, internal_id = 14}, is_trigger = 0}, 
                ckpt_get_rcy_point(session,rcy_point)                                                                                 {session = 0x0, flush_ctx = 0x0,page_idx_begin = 0, page_idx_end = 0, thread_id = {idx_in_table = 0, os_id = 0, internal_id = 0}, is_trigger = 0}, 
                    IF active THEN                                                                                                    {session = 0x0, flush_ctx = 0x0, page_idx_begin = 0, page_idx_end = 0, thread_id = {idx_in_table = 0, os_id = 0,internal_id = 0}, is_trigger = 0},总共8个数组 
                        rcy_point=SESSION_ID_CKPT.redo_ctx->curr_point 
                    ELSE 
                        rcy_point=SESSION_ID_CKPT.redo_ctx->replay_point 
                    FI 
            ELSE 
                // there are more than one group, so the new recovery point will be the recovery point of the next group 
                *page_count=CKPT_GROUP_SIZE(1024) 
                next_group=g_database->ckpt_ctx->active_group+1 
                IF CKPT_MAX_GROUPS==next_group THEN 
                    next_group=0 
                    *rcy_point=g_database->ckpt_ctx->rcy_point_map[next_group] 
            FI 
 
            g_database->ckpt_ctx->active_group++ 
            IF CKPT_MAX_GROUPS==g_database->ckpt_ctx->active_group 
                g_database->ckpt_ctx->active_group=0 
            FI 
 
           ckpt_mark_flush_pages(session,page_count)            ==>put all the page from page_list to flush_pages 
               page_id=g_database->ckpt_ctx->page_list.first 
               FOR i IN (0,page_count)                          ==>put all the page to 'g_database->ckpt_ctx->flush_pages' list,from the g_database->ckpt_ctx.page_list.first 
               DO 
                  g_database->ckpt_ctx->flush_pages[i]=page_id 
                  page_id=page_head(of_page_id)->next_chkpt_page 
 
               DONE 
               g_database->ckpt_ctx->page_list.count-=page_count  ==>remove the page list to update the ckpt queue, so minus the page_count (ckpt_dirty_page add the g_database->ckpt_ctx->page_list.count) 
               IF 0==g_database->ckpt_ctx->page_list.count THEN                                                                              ckpt_dirty_page(session) 
                   g_database->ckpt_ctx->page_list.first=page_list.last=DB_INVALID_ID32                                                          IF 0==g_database->ckpt_ctx THEN 
               ELSE                                                                                                                                  g_database->ckpt_ctx->page_list.first=SPC_GETA_PAGE_ID(session) 
                   g_database->ckpt_ctx->page_list.first=page_id                                                                                 ELSE 
               FI                                                                                                                                    g_database->ckpt_ctx->page_list.last->next_ckpt_page=SPC_GET_PAGE_ID(session) 
           g_database->ckpt_ctx->stat.page_group++                                                                                               FI 
           cm_spin_unlock(&g_database->ckpt_ctx->queue_mutex)                                                                                    g_database->ckpt_ctx->page_list.last=SPC_GET_PAGE_ID(session) 
       IF 0==*page_count THEN                                                                                                                    g_database->ckpt_ctx->page_list.count++ 
           //some operation don't dirty page, but still write redo. so evnen there is no dirty page, still need to chech whether save ctrl space IF 0==g_database->ckpt_ctx->sub_count THEN 
           IF rd_point_cmp(&g_db_ctrl_space->redo.rcy_point, rcy_point)>=0 THEN                                                                      g_database->ckpt->rcy_point_map[g_database->curr_group]=session->ckpt_ctx.rcy_point 
                *save_ctrl=DB_FALSE                                                                                                                  //This means, this is the first page in the current ckpt group. So the session recovery point will be recovery point of the current group 
                return                                                                                                                           ELSE 
           FI                                                                                                                                       IF rd_point_cmp(&session->ckpt_ctx.rcy_point,&g_database->ckpt_ctx->rcy_point_map[g_database->ckpt_ctx->curr_group]<0) THEN 
       FI                                                                                                                                              g_database->ckpt_ctx->rcy_point_map[g_database->ckpt_ctx->curr_group]=session->ckpt_ctx.rcy_point 
                                                                                                                                                       //This means this is not the first page in the current ckpt group. So the min(session rcy point, current group rcy point) will be the rcy point of the curr group 
       rd_flush_queue(session,lrp)                            ==>flush the latest redo file when do ckpt                                            FI 
                                                                                                                                                 FI 
    IF page_count>0 THEN                                                                                                                         g_database->ckpt_ctx->sub_count++ 
        cm_quick_sort(g_database->ckpt_ctx->flush_pages,page_count) -->flush_pages sort by page_id                                               IF CKPT_GROUP_SIZE == g_database->ckpt_ctx->sub_count 
        ckpt_trigger_workers(page_count)                                                                                                             g_database->ckpt_ctx->sub_count=0 
        cm_spin_lock(session->sid,&g_database->ckpt_ctx->mirror_mutex)                                                                               g_database->ckpt_ctx->curr_group++ 
        g_database->ckpt_ctx->mirror_pos=0                                                                                                           IF CKPT_GROUP_SIZE==g_database->ckpt_ctx->curr_group 
        cm_spin_unlock(&g_database->ckpt_ctx->mirror_mutex)                                                                                              g_database->ckpt_ctx->curr_group=0 
    FI                                                                                                                                               FI 
                                                                                                                                                 FI 
    g_database->ckpt_ctx->is_working=DB_FALSE                                                                                                    cm_spin_unlock(&g_database->ckpt_ctx->queue_mutex) 
    g_database->ckpt_id++ 
 
    IF rd_point_cmp(&rcy_point,&g_database->redo.rcy_point)>0 THEN 
        rd_set_rcy_point(session,&rcy_point) 
        g_database->redo.rcy_point=rcy_point 
    FI 
 
    g_database->redo.lrp=lrp 
 
```
