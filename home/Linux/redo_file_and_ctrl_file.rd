SESSION_ID_SYS  = 1                                                                                                      
  +------------------------------------------------------+
  |                                                      |
  |   cm_spinlock_t           lock;                      |
  |   cm_spinlock_t           set_redo_lock;             | //change free_log_size and redo file num                        
  |   cm_spinlock_t           write_lock;                |
  |   cm_thread_lock_t        flush_lock;                |
  |   cm_thread_lock_t        flush_all_lock;            |
  |   cm_thread_id_t          thread_id;                 |
  |   rd_redo_push            redo_push_proc;            |
  |   rd_redo_push            redo_g2s_push_proc;        |
  |   rd_redo_push            redo_s2s_push_proc;        |
  |   const db_char*          path;                      |
  |   db_void*                ctrlspace;                 |
  |   rd_ins_type_t           ins_type;                  |
  |                                                      |
  |   db_bool                 is_archive;                | // archive open|close                                           
  |   db_uint32               arv_curr_id;               | // archive current file id                                      
  |   db_uint32               arv_min_id;                | // archive min file id                                          
  |   cm_thread_id_t          arv_tid;                   | // archive thread id                                            
  |   db_uint32               arv_file_num;              |
  |   db_uint32               arv_bkp_id;                |
  |                                                      |
  |   db_uint32               file_num;                  | // total redo file num            CM_PARAM_REDO_NUM             
  |   db_uint32               min_id;                    | // redo min file id                                             
  |   rd_file_t               file[RD_MAX_REDO_FILE_NUM];| // redo file context                                            
  |   rd_point_t              rcy_point;                 |// recovery point                                                
  |   rd_point_t              curr_point;                |// current redo write position                                   
  |   rd_point_t              replay_point;              |// standby redo replay position                                  
  |   rd_queue_t              queue;                     |// redo queue                                                    
  |   db_uint32               gid;                       |// current group id                                              
  |                                                      |
  |   db_ulong                buf_offset;                |
  |   db_uint32               redo_buf_size;             |
  |   db_uint32               free_buf_size;             |
  |   db_uint32               curr_pos;                  |// current redo buf position                                     
  |   db_uint32               curr_buf_id;               |// current redo buf id                                           
  |   db_char*                buf[2];                    |
  |   lredo_trans_t           phy_point[2];              |// physical point in logic redo                                  
  |   lredo_trans_t           saved_phy_point;           |// saved physical point in logic redo                            
  |   rd_batch_t*             compress_buf;              |
  |   rd_batch_t*             perm_redo_buf;             |//store perm redo batch                                          
  |                                                      |
  |   db_uint64               free_log_size;             |
  |   db_uint64               flushing_redo_size;        |
  |                                                      |
  |   db_uint32 redo_buf_full_count;                     |
  |   db_uint64 redo_buf_start_time;                     |
  |                                                      |
  |   redo_statistic_t        redo_stat;                 |
  | rd_context_t;                                        |
  +------------------------------------------------------+

  typedef db_int32 (*rd_redo_push)(knl_session_t* session, rd_batch_t* batch);                                             

  rd_point_t
  +---------------------------------------+
  |                                       |
  |    db_uint32               file_id;   |    // redo file id                                                             
  |    db_uint32               seek_pos;  |    // redo offset                                                              
  |    db_uint64               dcn;       |    // dcn                                                                      
  +---------------------------------------+

  rd_queue_t
  +---------------------------------------+
  |    db_uint32              start_pos   |
  |    db_uint32              curr_pos    |
  |    db_uint32              mark_pos ;  |
  |    knl_session_t*     session[1024]   |
  +---------------------------------------+

  db_char*                buf[2];   --->malloc(REDO_BUFF*1024*1024)                                                        

 cm_db_id_t                                   ->ctrlredo文件
 +----------------------------------------+
 |typedef struct tagcm_db_id              |
 |                                        | Address  0   1   2   3   4   5   6   7   8   9   a   b   c   d   e   f         
 |    db_uint64 time;                     | 00000000 89 d8  0f  81  3c  4b  05  00  70  54  f5  de  0b  0c  00  00         
 |    db_uint8  mac_addr[CM_MAC_LEN];     | 1490098118973577 us /1000 000 =   1490098118.973577 ->time=  2017/3/21 20:8:38 
 |    db_uint16 reserved;                 | eth4      Link encap:Ethernet  HWaddr 70:54:F5:DE:0B:0C                        
 |cm_db_id_t;                             |           inet addr:10.75.162.44  Bcast:10.75.163.255  Mask:255.255.254.0      
 +----------------------------------------+
  
  knl_ctrl_space_t = 160K
 +---------------------------------------------------------+
 | typedef struct tagknl_ctrl_space                        |                                                                                               
 | {                                                       |   47 4d 44 42 56 32 30 30 52 30 30 35 43 30 30 20 2d 20 50 72 6f 64 75 63 74 69 6f 6e 20 6f 6e 20 20 4a 61 6e 20 20 31 20 31 39 37 30 20 20 20 20                                                                             
 |     db_char             pkg_version[256];               |   // package version   ->GMDB V200R005C00 - Production on  Jan  1 1970 debug(0)                                                       
 |     db_uint32           ctrl_version;                   |   // database version 
 |     db_uint32           ckpt_id;                        |   // checkpoint id
 |     knl_mode_e          mode;                           |   // database mode
 |     knl_db_stat_e       status;                         |   // database status,opening,closed
 |     knl_ctlg_entry_t    ctlg_entry;                     |   // catalog entry
 |     db_uint64           global_tid;                     |   // global transaction id,here for persistence                              
 |     cm_db_id_t          db_id;                          |                                                                              
 |     db_uint16           created_done;                   |   // database created done
 |     db_uint16           ps_reserved[1];                 |   // reserved bytes for 8 bytes alignment
 |     db_uint8            rep_undo_spc;                   |   // Rep undo tablespace id                                    
 |     db_uint8            reserved_undo_spc;              |                                                                              
 |     db_uint8            perm_undo_spc;                  |   // Permanent undo tablespace id
 |     db_uint8            temp_undo_spc;                  |   // Temp undo tablespace id
 |     rd_ctrl_t           redo;                           |   // redo control infomation
 |     knl_persisted_db_param_t  persisted_param;          |   //recreate param of config file
 |     sr_baseline_param_t    sr_baseline_param;           |   //check whether need  force smartrep do baseline
 |     lredo_trans_t       lredo_trans[2];                 |   //lredo use it to store min point and max point, szieof(lredo_trans_t) = 40
 |     db_uint8            is_rt_redo_useable;             |   //set to be db_false if rt is not opened  or rt is disable  
 |     db_char             head_reverse[3575];             |   //size of head is 4k for performance.
 |     db_uint32           cfg_max_sessions;               |                                
 |     knl_invalid_mode_cause_e invalid_cause;             |   // the cause to set database mode in invalid 
 |     db_uint64            shm_mng_create_time;           |                                                                              
 |     db_uint8            head_md5[MD5_KEY_LENGTH];       |   //the head is 4096 bytes                                                   
 |     knl_space_t         spaces[SPC_MAX_SPACE];          |                                                                              
 |     knl_device_t        devices[SPC_MAX_DEVICE];        |   // concurrency control is in space level                                   
 |     db_char             ckpt_temp_file_name[DB_MAX_PATH]|                                                                              
 |     db_char             soft_version[DB_MAX_NAME_LEN];  |   // software version.                                                       
 |     db_uint32           tail_chg_num;                   | 
 |     db_uint64           job_max_id;                     |
 |     db_uint64           proc_max_id;                    |
 |     db_uint32           sr_new_filenum;                 |
 |     db_char             tail_reverse[3080];             |
 |     db_uint8            tail_md5[MD5_KEY_LENGTH];       |  //the total size is multiple of 4096
 | }knl_ctrl_space_t;                                      |
 +---------------------------------------------------------+
