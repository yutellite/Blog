```c


srep_instance_t  ==>g_srep_instance                                          lredo_ctx_t==>g_srep_instance->lredo_send                                        lredo_ctx_t==>g_srep_instance->lredo_rend
 +------------------------------------------+                                +------------------------------------------+                                     +-----------------------------------------+
 |   capture_ctx_t           capture;       |                                | cm_spinlock_t           lock;            |                                     |  cm_spinlock_t           lock;          |
 |   lredo_ctx_t             lredo_send;    |                                | cm_thread_id_t          tid;             |                                     |  cm_thread_id_t          tid;           |
 |   lredo_ctx_t             lredo_recv;    |                                | rd_context_t            redo_ctx;        |                                     |  rd_context_t            redo_ctx;      |
 |   load_ctx_t              load;          |                                | knl_database_t          data_base;       |                                     |  knl_database_t          data_base;     |
 |   send_ctx_t              send;          |                                | knl_ctrl_space_t        ctrl_space;      |                                     |  knl_ctrl_space_t        ctrl_space;    |
 |   recv_ctx_t              recv;          |                                | db_uint32               file_num;        |param.SR_PARAM_REDO_FILE_NUM         |  db_uint32               file_num;      |param.SR_PARAM_REDO_FILE_NUM
 |   replay_ctx_t            replay;        |->g_srep_instance->replay       | lredo_trans_t           save_point;      |                                     |  lredo_trans_t           save_point;    |
 |   db_char*                redo_buf;      |// all session redo buffer      | lredo_trans_t           min_point;       |                                     |  lredo_trans_t           min_point;     |
 |   srep_mode_e             mode;          |                                | lredo_trans_t           max_point;       |                                     |  lredo_trans_t           max_point;     |
 |   db_bool                 schema_sync;   |                                | lredo_trans_t           point[KNL_MAX_SES|SIONS_CFG_VALUE];                    |  lredo_trans_t           point[KNL_MAX_S|ESSIONS_CFG_VALUE];
 +------------------------------------------+                                | cm_list_t               trans_sids;      |                                     |  cm_list_t               trans_sids;    |
 buf = (db_char*)cm_malloc((SE_REDO_BUF_SIZE +（64k）                        | //For performance while calling lredo_min|_point.Only use for lredo capture.   |  //For performance while calling lredo_m|in_point.Only use for lredo capture.
          EX_SIZE_FOR_LREDO) * SE_MAX_SESSION);30个srep sys保留session       | db_char*                path;            |param.SR_PARAM_LOCAL_REDO_FILE_NUM   |  db_char*                path;          |param.SR_PARAM_PEER_REDO_PATH
                                                                             +------------------------------------------+                                     +-----------------------------------------+
#define SE_SID_START             1
#define SE_SID_CAPTURER          2
#define SE_SID_LREDO             3
#define SE_SID_G2S_LNSR          4
#define SE_SID_G2S_RECEIVER      5
#define SE_SID_SENDER            6
#define SE_SID_S2S_LNSR          7
#define SE_SID_S2S_RECEIVER      8
#define SE_SID_WRITER            9
#define SE_SID_DISPATCHER        10
#define SE_SID_CMP_SRV           11
#define SE_SID_ALARM             12
#define SE_SID_FILTER            13
#define SE_SID_SCHEMA_SYNC       14
#define SE_SID_USED_IDX         SE_SID_SCHEMA_SYNC
#define SE_SID_END              30

FOR i IN SE_SID_START,SE_SID_END
    g_session[i].redo_ctx=&g_srep_instance->lredo_send.redo_ctx;
    g_session[i].sid=i
    g_session[i].redo_buf=buf+((db_uint64)(SE_REDO_BUF_SIZE + EX_SIZE_FOR_LREDO) * (i - 1));
    g_session[i].log_pos=sizeof(rd_group_t)
END
    g_session[SE_SID_S2S_RECEIVER].redo_ctx = &g_srep_instance->lredo_recv.redo_ctx;
    g_session[SE_SID_WRITER].redo_ctx   = &g_srep_instance->lredo_recv.redo_ctx;
    g_session[SE_SID_DISPATCHER].redo_ctx = &g_srep_instance->lredo_recv.redo_ctx;

lreplay_point_t
 +------------------------------------------+
 |  rd_point_t          rd_point;           |
 |  db_uint32           offset;             |
 |  db_uint32           perm_redo_offset;   |/*ONLY use it when try to find something in FILE redo log*/
 +------------------------------------------+

 replay_ctx_t; ==>g_srep_instance->replay                                                                                                        rep_queue_wrapper_t ==>g_srep_instance->replay.queue_wrapper
 +------------------------------------------+                                                                                                    +-------------------------------------------------+
 |  cm_thread_id_t          tid;            |                                                                                                    | rep_queue_t*                queue;              |==>g_sr_replay_queue
 |  db_conn                 replay_conn;    |                                                                                                    | db_bool                     no_new_data_in_file;|
 |  lreplay_point_t         replay_point;   | //replay finish point                                                                              |                                                 |
 |  lreplay_point_t         curr_point;     | //current replay point                                                                             | rep_queue_file_stat_t*      read_queue_stat;    |=>g_srep_instance->replay.queue_stat[0]
 |  lreplay_point_t         last_commit_pos;| //last commit point                                                                                | rep_queue_file_stat_t*      read_file_stat;     |=>g_srep_instance->replay.queue_stat[1]
 |                                          |                                                                                                    | rep_queue_file_stat_t*      write_queue_stat;   |=>g_srep_instance->replay.queue_stat[2]
 |  db_char*                cd_log_path;    |                                                                                                    | rep_queue_file_stat_t*      write_file_stat;    |=>g_srep_instance->replay.queue_stat[3]
 |                                          |                                                                                                    |                                                 |
 |  db_char *               replay_buf;     |==>malloc(RD_MAX_COMPRESSED_BATCH_SIZE)=>MAX_REDO_BUF*2  /*the buf to store the loaded batchs*/     | rep_load_redo_from_file_proc load_redo_from_file|=>rd_load_log()
 |  db_uint32               replay_buf_size;| /*the length of batches loaded in replay buf*/                                                     | rep_write_redo_to_file_proc write_redo_to_file; |=>rd_flush_batch()
 |  rd_batch_t*             replay_batch;   |==>malloc(RD_MAX_COMPRESSED_BATCH_SIZE)=>MAX_REDO_BUF*2  /*the decompressed one batch for replay*/  +-------------------------------------------------+
 |                                          |
 | $sr_dispatcher_t         dispatcher;     | /*dispatcher memory addr*/
 |  db_stmt                 disp_csn_stmt;  |==>stmt(SR_GLB_STMT_TYPE_DISP)  /*dispatcher stmt of update csn*/                                   rep_queue_t==>g_sr_replay_queue
 |                                          |                                                                                                    +-------------------------------------------------+
 |  rep_queue_wrapper_t     queue_wrapper;  |==>                                                                                                 |cm_thread_lock_t            lock;                |
 |  rep_queue_file_stat_t   queue_stat[4];  |                                                                                                    |volatile  db_bool           is_push_proc_enter;  |
 |                                          |                                                                                                    |db_uint32                   capacity;            |->param.SR_PARAM_SREP_BUF_SIZE
 |  sr_comp_sync_ctrl_t     comp_sync_ctrl; |                                                                                                    |db_uint32                   max_elem_num;        |->SR_PARAM_SREP_BUF_SIZE/5000
 |                                          |                                                                                                    |db_uint32                   elem_num;            |
 |  knl_session_t*          session;        |==>srep_get_session(SE_SID_DISPATCHER);                                                             |rep_queue_elem_idx_t*       idx_pool;            |->SR_SHM_ID_RPL_QUEUE_IDX共享内存索引池
 +------------------------------------------+                                                                                                    |rep_queue_elem_idx_t*       head_idx;            |
                                                                                                                                                 |rep_queue_elem_idx_t*       tail_idx;            |
$sr_dispatcher_t ==>&g_srep_instance.dispatcher                                                                                                  |rep_queue_idx_offset_t*     idx_offset;          |->idx_pool+sizeof(rep_queue_elem_idx_t)*capacity
 +----------------------------------------------+                                                                                                |db_char*                    data_pool;           |->SR_SHM_ID_RPL_QUEUE_DATA
 |  db_uint32 pworker_count;                    |=>param.SR_PARAM_PERM_WORKER_NUM                                                                |rd_point_t *                latest_point;        |
 |  db_uint32 rworker_count;                    |=>param.SR_PARAM_REP_WORKER_NUM                                                                 +-------------------------------------------------+
 |  db_uint32 all_worker_count;                 |=>PERM_NUM+REP_NUM
 | #sr_replay_worker_t all_workers[MAX_REPLAY_WO|RKER_COUNT];                                                                     0x1c1e2803  4194304    key10240+3 SEND_IDX p/x (g_instance_id&0xffff)<<16|((10240+3)&0xffff)=0x1c1e2803
 |                                              |                                                                                 0x1c1e2805  524288000  key10240+4 SEND_DAT p/x (g_instance_id&0xffff)<<16|((10240+4)&0xffff)=0x1c1e2804 500M
 |  sr_tbl_thd_t tbl_map[SR_MAX_DICT_TABLE_NUM];|//map of table and thread   负载均衡的思想按表id来分配                           element_count=capacity   SR_SHM_ID_RPL_QUEUE_IDX共享内存中    10240+4 SEND_DATA            0x1c1e2804
 |  db_uint32    map_cnt;                       |//map count for poll                                                             +----------------------------------------------------------------------------------------------------+
 |                                              |                                                                                 |rd_point_t point       |       |       |       |       |      |       |       |db_uint32 elem_num   |
 |  db_bool   is_repeat;                        |                                                                                 |db_uint32  data_size   |       |       |       |       |      |       |       |db_int64 head_offset |
 |                                              |                                                                                 |db_char*   data        |       |       |       |       |      |       |       |db_int64 tail_offset |
 |  db_bool   is_trans_end;                     |                                                                                 |db_int64   data_offset |       |       |       |       |      |       |       |                     |
 |  db_uint32 max_commit_rows;                  |=>param.SR_PARAM_TRANS_MAX_NUM                                                   +----------------------------------------------------------------------------------------------------+
 |  db_uint32 uncmt_rows;  //uncommitted rows   |                                                                          idx_pool                                                                              idx_offset
 |                                              |                                                                          head_idx=idx_pool+idx_offset->head_offset    所有索引的data都指向data_pool
 |  cd_log_mem_t log_mem;                       |                                                                          tail_idx=idx_pool+idx_offset->tail_offset
 |         db_char* cd_log_buf                  |=>malloc(8M)                                                                     +----------------------------------------------------------------------------------------------------+
 |  db_bool   is_ddl;                           |                                                                                 | data_pool                                                                                          |
 |  ddl_ctx_t ddl_ctx;                          |                                                                                 |                                                                                                    |
 |  lreplay_point_t start_point;                |                                                                                 |                                                                                                    |
 +----------------------------------------------+                                                                                 +----------------------------------------------------------------------------------------------------+
                                                                                                                           Rep queue is a circle queue, it provides:
 #sr_replay_worker_t ==>&g_srep_instance.dispatcher.all_workers[MAX_REPLAY_WORKER_COUNT]                                   1. Store and manage data block which is assigned with an ID(rd_point_t.dcn) in a FIFO manner.
 +------------------------------------------+                                                                              2. Vacate free space for new data automatically. It means that the oldest one or more elements will be discarded for the new onw if neccessary.
 |knl_session_t* session;                   |=>malloc(session)                                                             3. getting elements from a given begin ID greedily.(greedily means that put as much elements as possible to the given buffer.)
 |cm_thread_id_t   tid;                     |                                                                              4. Thread-safe.
 |db_bool is_running;                       |                                                                              The rep queue is composed of a index pool for fast search and a data pool for actual data storage. Both pool are designed as a cicular queue.
 |db_bool is_rep_worker;                    |                                                                              The index is composed of ID, data size and pointer to data. The queue searches the data over ID by binary search algorithm.
 |                                          |
 |sr_lredo_queue_t   lredo_queue;           |                                                                              The data pushed to queue and the args must satisfy dome preconditions:1.The ID(dcn) must be always consecutive and the new must be larger than the old one.
 |volatile db_uint32 lredo_count;           |//放入的lredo记录数                                                           Because the binary search algorithm means that the ID list must be ordered. 2. The size of data must be less than or equal the capacity of queue or else it can not be
 |db_uint32 push_lredo_failed_times;        |//the failed count of dispatcher pushing lredo to worker                      accommodated. 3. The max_elem_num specified in creation should equal capacity/avg_data_size approximately.Or else there may be some unnecessary space waste for the too small index pool.
 |volatile db_uint32 replayed_count;        |//已经重演的记录数，如果replayed_count==lredo_count，表示已经处理完成
 |volatile db_bool   tx_end_failed;         |//worker set tx_end_failed to true while tx end failed, then dispatcher can get the notice.
 |                                          |                                          sr_lredo_queue_t==>&g_srep_instance.dispatcher.all_workers[MAX_REPLAY_WORKER_COUNT].lredo_queue
 |db_char         *lredo_buf;               |=>malloc(4M)                              +---------------------------------+
 |db_uint32        lredo_size;              |                                          | volatile db_uint32 size;        |=>0
 |                                          |                                          | volatile db_uint32 lredo_count; |=>0
 |cd_log_mem_t  log_mem;                    |                                          | db_uint32     length;           |=>4M
 |        db_char* cd_log_buf               |=>malloc(8M)                              | cm_spinlock_t lock;             |
 |lrd_head_t      *lredo_list[LREDO_QUEUE_MA|X_COUNT];                                 |                                 |
 |                                          |                                          | db_char *wpoint; //写点         |=>pthis.data
 |sr_dml_replayer_t replayer;               |                                          | db_char *data;                  |=>malloc(REPLAY_WORKER_QUEUE_SIZE) 4M
 |                                          |                                          +---------------------------------+
 |void (*remove_table)(struct tag_sr_replay_|worker_t *pthis, db_uint32 table_id); =>sr_replay_worker_remove_table()
 |db_int32 (*push_lredo)(struct tag_sr_repla|y_worker_t *pthis, lrd_head_t *predo);=>sr_replay_worker_push()
 +------------------------------------------+

 sr_dml_replayer_t ==>&g_srep_instance.dispatcher.all_workers[MAX_REPLAY_WORKER_COUNT].replayer      4M(rqueue_push)                                             4M(rqueue_pop)
 +------------------------------------------+                                                        +------------------------------------------------------+     +------------------------------------------------------+
 | db_conn      dst_conn;                   |                                                        |                                                      |     |                                                      |
 | db_grouphdl  stmt_group;                 |                                                        |                                                      |     |                                                      |
 | db_int32     last_error;                 |                                                        |                                                      |     |                                                      |
 |                                          |                                                        +------------------------------------------------------+     +------------------------------------------------------+
 | lrd_head_t **cur_lredo_list;             |                                             lredo_queue.size         rqueue_push(worker->lredo_queue,predo,predo->size)  rqueue_pop(worker->lredo_queue,worker->lredo_buf,4M)
 | db_uint32    cur_lredo_count;            |                                                        .lredo_count      memcpy(this->wpoint,predo,predo->size)              memcpy(lredo_buf,lredo_queue->data,4M)
 | db_uint32    cur_offset;                 | //stmt count executed succeed in group                 .length           this->wpoint+=size                                  lredo_queue->wpoint=lredo_queue->data
 | db_uint32    ucmt_rows;                  | //stmt count uncommitted in worker                     .lock             this->size+=size                                    lredo_queue->size=0
 | db_uint32    cur_group_count;            | //stmt count unexecuted in group                       .wpoint           this->lredo_count++                                 lredo_queue->lredo_count=0
 | db_int32    last_conflict_pos;           |                                                        .data
 |                                          |                                                        多次push，一次全量pop，push时先检验队列是否空间足够再锁再检查空间，以保证并发
 | lredo_table_t     *map_tables[LREDO_QUEUE|_MAX_COUNT];
 | lredo_table_list_t table_list;           |
 | db_uint32          tbl_cnt;              |
 +------------------------------------------+

 lredo_table_list_t==>&g_srep_instance.dispatcher.all_workers[MAX_REPLAY_WORKER_COUNT].replayer.table_list
 +-----------------------------------------------------------------------+
 |lredo_table_t *hash_table[LREDO_TABLE_HASH_SIZE]; (128)                |
 |                                                                       |
 |knl_col_mark_list_t tab_cols;                                          |
 |db_uint32 bind_col_val[KNL_MAX_TAB_COLUMNS*2];(1024*2)                 |
 |db_char   bind_col_num[KNL_MAX_TAB_COLUMNS*2][SQL_NUMERIC_STRING_LEN];(42)
 |                                                                       |
 |void (*remove_table)(struct taglredo_table_list_t *pthis,              |=>lredo_table_remove()
 |                     db_uint32 table_id)                               |
 |db_int32 (*get_table)(struct taglredo_table_list_t *pthis,             |=>lredo_get_inited_table()
 |                       db_uint32 table_id,                             |
 |                      db_conn db, lredo_table_t **ptab);               |
 +-----------------------------------------------------------------------+


 sr_replay_worker_porc
 WHILE running
 do
     worker->lredo_size=rqueue_pop(&worker->lredo_queue,worker->lredo_buf,4M)
     memcpy(lredo_buf,lredo_queue->data,4M)
     lredo_queue->wpoint=lredo_queue->data;
     lredo_queue->size=0;
     lredo_queue->lredo_count=0;
     sr_replay_worker_replay_buf()
 done

 the entry of replay
 sr_replay_task
    replay_session=SE_SID_DISPATCHER
    replay=&g_srep_instance->replay

    replay->replay_conn  ==>gm_quick_connect
    alloc_stmt(g_sr_glb_stmt[])

    rep_load_redo_log(replay_session, &replay->queue_wrapper, &in_point, &out_point, replay->replay_buf, RD_MAX_BATCH_SIZE, &replay->replay_buf_size)
        rep_get_greedily---->尽可能多的将queue中的log memcpy到replay_buf中，从queue中的tail_idx开始进行二分查找到开始dcn值，然后一直拷贝到replay_buf满为止 ，MAX_REDO_BUF * 2
            binary_search(replay->queue_wrapper->queue->tail_idx,in_point->dcn+1,&start_pos)
            get_elems_by_pos
                FOR i<replay->queue_wrapper->elem_num i++
                do
                    replay->replay_buf<----memcpy(replay->replay_buf,replay_queue_wrapper->queue->tail_idx->data,tail_idx->data_size)
                done
       rep_check_dcn_continuity

    sr_dispatcher_proc(replay)

    +------------------------------------------+
    | rd_batch_t
    +------------------------------------------+
    | rd_group_t
    +------------------------------------------+
    | rd_head_t
    +------------------------------------------+
    |filter_rd_head_t
    +------------------------------------------+
    |lrd_head_t
    +------------------------------------------+
    |lrd_dml_head_t
    +------------------------------------------+
    |data
    +------------------------------------------+
    |lrd_tail_t
    +------------------------------------------+
    |rd_batch_tail_t
    +------------------------------------------+




```
