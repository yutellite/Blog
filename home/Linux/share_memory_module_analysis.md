```c
g_instance_id	GMDB(UID)用户ID（7198）						gmstat -m	

CM_SHM_IDX_TO_KEY=((((g_instance_id)&oxFFFF)<<16)|(db_uint32)((idx)&0xFFFF))
+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
|cm_fixed_shm_id_e		                CM_SHM_IDX_TO_KEY         type	 RANGE(0-4096)	            size		 key          bytes      type            name              create_time	               |
+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
|SHM_ID_MNG_CTRL = 0  CM_SHM_CTRL_KEY	0:1c1e0000	SHM_FIXED	 1-99	sizeof(cm_shm_ctrl_t)	    2262096	    0x1c1e0000   2262096    SHM_FIXED       MEMORY_MANAGER    Fri Sep  2 14:46:34 2016     |
|																												                                                                                       |
|SHM_ID_LOG		                        1:1c1e0001	SHM_FIXED		    30M	                        30M	        0x1c1e0001   31457280   SHM_FIXED       MEMORY_MISC       Fri Sep  2 14:46:34 2016	   |
|																											                                                                                           |
|SHM_ID_SYS_GA		                    2:1c1e0002	SHM_FIXED		    sys_area_size=16*(sizeof(db_ulong)+                                                                                            |
|                                                                        sumof(g_sys_pools[16].capacity)		0x1c1e0002   821200680  SHM_FIXED       MEMORY_SYSGA      Tue Sep 13 10:36:58 2016	   |
|                                                                        																											                   |
|SHM_ID_APP_GA		                    3:1c1e0003	SHM_FIXED		    app_area_size=sizeof(db_ulong)+                                                                                                |
|                                                                        g_app_pools[0].capacity		        0x1c1e0003   99172656   SHM_FIXED       MEMORY_APPGA      Tue Sep 13 10:36:59 2016	   |
|                                                                        																											                   |
|SHM_ID_CTRL_SPACE		                4:1c1e0004	SHM_FIXED		    sizeof(knl_ctrl_space_t)	160K	    0x1c1e0004   163840     SHM_FIXED       MEMORY_CTRLSPACE  Fri Sep  2 14:46:37 2016	   |
|																											                                                                                           |
|SHM_ID_CS		                        5:1c1e0005	SHM_FIXED		    sizeof(cs_ipc_lsnr_ctrl_t)+                                                                                                    |
|                                                                        KNL_MAX_SESSIONS * (sizeof(cs_ipc_pipe_room_t) +                                                                              |
|                                                                        sizeof(cs_ipc_app_room_t))	128M 	    0x1c1e0005   67277016   SHM_FIXED       MEMORY_APPCS      Tue Sep 13 10:37:01 2016	   |
|                                                                        																											                   |
|SHM_ID_REP_STAT		                6:1c1e0006	SHM_FIXED		    sizeof(rep_total_stat_t)	7186B	    0x1c1e0006   7816       SHM_FIXED       MEMORY_REPSTAT    Fri Sep  2 14:46:51 2016	   |
|																											                                                                                           |
|SHM_ID_HATOOL		                    7:1c1e0007	SHM_FIXED			416B																													       |
|                                                                                                                                                                                                      |
|SHM_ID_SECURITY		                8:1c1e0008	SHM_FIXED		    sizeof(cm_security_block_t)	264K	    0x1c1e0008   270336     SHM_FIXED       MEMORY_SECURITY   Tue Sep 13 10:37:01 2016	   |
|																											                                                                                           |
|SHM_ID_RT_REDO_CTRL		            9:1c1e0009	SHM_FIXED		    sizeof(rt_redo_ctl_t)+                                                                                                         |
|                                                                        (db_uint32)knl_lz4_compress_buf_len(100G)100G+1K(105269846）                                                                  |
|                                                                                                               0x1c1e0009  105269846   SHM_FIXED       RT_REDO_CTRL      Fri Sep  2 14:46:49 2016	   |
|SHM_ID_BUTT																																			                                               |
|																																			                                                           |
|			                                        SHM_GA	    100-299																															       |
|			                                        SHM_RT_REDO	400-470                             (140G)																							   |
|			                                        SHM_DEVICE	1000																			                                                       |
|			                                        SHM_PAGE_LATCH	3000                                                                                                                               |
|			                                        																															                       |
|	                                                                                                                                                                                                   |
+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
|GA																												                                                                                                                                                                                      |
|SHM_ID	            POOL_ID	              POOL_NAME     POOL_ID	         POOL_ID	OBJ_COUNT	                    OBJ_SIZE	        EX_MAX	        OBJ_SIZE																												                      |
|g_sys_pools[0]	    GA_INSTANCE_POOL	  instance      GA_SYS_AREA+0	0x01000000	 1	                            INS_INS_SIZE	        0);	        (cm_get_uint32_param(CM_PARAM_REDO_BUF) * (1024*1024) + sizeof(knl_inst_t) + CKPT_GROUP_SIZE * SPC_PAGE_SIZE)								  |
|g_sys_pools[1]	    GA_SESSION_POOL1	 session1		GA_SYS_AREA+1	0x01000001	 KNL_MAX_SESSIONS	            (db_uint32)obj_size	    0);	        (sizeof(knl_session_t) + SESSION_PAGE_SIZE * KNL_STACK_PAGE_COUNT - 4)																		  |
|g_sys_pools[2]	    GA_SESSION_POOL2	 session2       GA_SYS_AREA+2	0x01000002	 KNL_MAX_SESSIONS	            (db_uint32)obj_size	    0);	        (sizeof(knl_session_t) + SESSION_PAGE_SIZE * KNL_STACK_PAGE_COUNT - 4)																		  |
|g_sys_pools[3]	    GA_DICTIONARY_POOL	 dictionary     GA_SYS_AREA+3	0x01000003	((cm_get_uint32_param(CM_PARAM_DICTIONARY_CACHE_SIZE) * 1024 * 1024) / DC_PAGE_SIZE)	                                                                                                                          |
|                                                                                                                   DC_PAGE_SIZE	        0);	        (KNL_MAX_SESSIONS > 1024 ? 32768 : ((cm_get_uint32_param(CM_PARAM_PAGE_SIZE)) > 16384?(cm_get_uint32_param(CM_PARAM_PAGE_SIZE)):16384))//16384|
|g_sys_pools[4]	    GA_PERM_UNDO_POOL	  perm undo     GA_SYS_AREA+5	0x01000005	 KNL_MAX_SESSIONS	            UD_SET_ITEM_SIZE	    0);	        ((sizeof(ud_seg_item_t) - sizeof(seg_segment_t)) + SEG_SEGMENT_SIZE)						
|g_sys_pools[5]	    GA_TEMP_UNDO_POOL	  temp undo     GA_SYS_AREA+6	0x01000006	 KNL_MAX_SESSIONS	            UD_SET_ITEM_SIZE	    0);	        ((sizeof(ud_seg_item_t) - sizeof(seg_segment_t)) + SEG_SEGMENT_SIZE)																		  |
|g_sys_pools[6]	    GA_REP_UNDO_POOL	   rep undo     GA_SYS_AREA+7	0x01000007	 KNL_MAX_SESSIONS	            UD_SET_ITEM_SIZE	    0);	        ((sizeof(ud_seg_item_t) - sizeof(seg_segment_t)) + SEG_SEGMENT_SIZE)																		  |
|g_sys_pools[7]	    GA_LOCK_POOL	      lock			GA_SYS_AREA+8	0x01000008	 cm_get_uint32_param(CM_PARAM_MAX_LOCKS)	
|                                                                                                                   sizeof(lock_item_t)	    0);	        sizeof(lock_item_t)	                                                                                                         				  |
|g_sys_pools[8]	    GA_SQL_ROOT_POOL	  sql root      GA_SYS_AREA+9	0x01000009	 1	                            GA_SQL_ROOT_POOL_SIZE	0);	        (db_uint32)(2 * 1048576)  /* 2M */	                				                                                             			  |
|                   																							
|g_sys_pools[9]	    GA_SQL_8K_POOL	      sql 8k        GA_SYS_AREA+10	0x01000010	 INS_SQL_OBJ_COUNT(2,8)	        8192	                0);	        8192	8k																																	  |
|g_sys_pools[10]	GA_SQL_16K_POOL	      sql 16k       GA_SYS_AREA+11	0x01000011	 INS_SQL_OBJ_COUNT(4,16)	    16384	                0);	        16384	16k																											                          |
|g_sys_pools[11]	GA_SQL_32K_POOL	      sql 32k       GA_SYS_AREA+12	0x01000012	 INS_SQL_OBJ_COUNT(4,32)	    32768	                0);	        32768	32k																											                          |
|g_sys_pools[12]	GA_SEQUENCE_POOL	  sequence  	GA_SYS_AREA+4	0x01000004	 1	                            GA_SEQUENCE_POOL_SIZE	0);	        (db_uint32)1048576					                                                                                                          |
|g_sys_pools[13]	GA_PRIVS_CACHE_POOL	  privs cache   GA_SYS_AREA+14	0x01000014	 1	                            GA_PC_POOL_SIZE	        0);	        (db_uint32)(1048576 / 2)  /* 512k																			                                  |
|g_sys_pools[14]	GA_SORT_POOL	      sort          GA_APP_AREA+0	0x02000000	 INS_SORT_OBJ_COUNT	            GA_SORT_PAGE_SIZE	    0);    	    (db_uint32)32768  			        																										  |
|
|g_app_pools[0]	    GA_CURSOR_POOL	      cursor        GA_SYS_AREA+13	0x01000013	 4096	                        INS_CURSOR_SIZE	        instance_cursor_ex_max(4096));	(sizeof(knl_cursor_t) + SPC_PAGE_SIZE * 2 - 4)                                                                            |
+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
																													              																									
																																			
g_sys_area_addr	SHM_ID_SYS_GA共享内存地址																																		
g_app_area_addr	SHM_ID_APP_GA共享内存地址																		    											

g_sys_pools

  ga_pool_t
  +----------------------------------+
  |db_char    *pool_name             |
  |db_char    *addr                  |
  |db_char    *object_addr           |
  |ga_pool_ctrl   *ctrl              |
  |ga_object_map_t    *object_map    |
  |db_char    *ex_pool_addr          |
  |           [GM_MAX_EXTENDED_POOLS]|
  |                                  |
  |ga_pool_def_t  def                |
  |         db_uint32 object_count   |
  |         db_uint32 object_size    |
  |         db_uint32 ex_max         |
  |db_ulong   capacity               |
  |db_uint32  ex_attach_count        |
  +----------------------------------+

g_sys_pools
+----------------------------------------------------------------------------------------------------------------------+
| {"instance",   NULL, NULL, NULL, NULL, {NULL}, {1, GA_INSTANCE_POOL_SIZE, 0}, 0, 0},   /* instance pool */           |
| {"session.1",  NULL, NULL, NULL, NULL, {NULL}, {0, 0, 0}, 0, 0},                       /* session pool 1*/           |
| {"session.2",  NULL, NULL, NULL, NULL, {NULL}, {0, 0, 0}, 0, 0},                       /* session pool 2*/           |
| {"dictionary", NULL, NULL, NULL, NULL, {NULL}, {0, 0, 0}, 0, 0},                       /* dictionary pool */         |
| {"perm undo",  NULL, NULL, NULL, NULL, {NULL}, {0, 0, 0}, 0, 0},                       /* perm undo context pool */  |
| {"temp undo",  NULL, NULL, NULL, NULL, {NULL}, {0, 0, 0}, 0, 0},                       /* temp undo context pool */  |
| {"rep undo",   NULL, NULL, NULL, NULL, {NULL}, {0, 0, 0}, 0, 0},                       /* rep undo context pool */   |
| {"lock",       NULL, NULL, NULL, NULL, {NULL}, {0, 0, 0}, 0, 0},                       /* lock pool */               |
| {"sql root",   NULL, NULL, NULL, NULL, {NULL}, {1, GA_SQL_ROOT_POOL_SIZE, 0}, 0, 0},   /* sql root pool */           |
| {"sql 8k",     NULL, NULL, NULL, NULL, {NULL}, {0, 0, 0}, 0, 0},                       /* sql 8k pool */             |
| {"sql 16k",    NULL, NULL, NULL, NULL, {NULL}, {0, 0, 0}, 0, 0},                       /* sql 16k pool */            |
| {"sql 32k",    NULL, NULL, NULL, NULL, {NULL}, {0, 0, 0}, 0, 0},                       /* sql 32k pool */            |
| {"sequence",   NULL, NULL, NULL, NULL, {NULL}, {1, GA_SEQUENCE_POOL_SIZE, 0}, 0, 0},   /* sequence pool */           |
| {"privs cache",NULL, NULL, NULL, NULL, {NULL}, {1, GA_PC_POOL_SIZE, 0}, 0, 0}, /* privs cache pool */                |
| {"sort",       NULL, NULL, NULL, NULL, {NULL}, {GA_INITIAL_SORT_PAGES, GA_SORT_PAGE_SIZE, 0}, 0, 0}, /* sort pool */ |
+----------------------------------------------------------------------------------------------------------------------+
g_app_pools
+----------------------------------------------------------------------------------------------------------------------+
| {"cursor",     NULL, NULL, NULL, NULL, {NULL}, {GA_INITIAL_CURSORS, 0, 0}, 0, 0},      /* cursor pool */             |
+----------------------------------------------------------------------------------------------------------------------+

一、g_sys_area_addr共享内存
实际共享内存创建区域
Such as SHM_ID_SYS_GA share memory
g_sys_area_addr(GA_SYS_POOL_COUNT=15) 15 pools
      +-------------------------------------------+-----------------------+-----------------------+-----------------------+	
      |        |          |       |       |       |                       |                       |                       |
      |offset0 |offset0+1 |       |       |       |                       |                       |       .....           |
      |        |          |       |...    |       |                       |                       |                       |
      |        |          |       |       |       |                       |                       |                       |
      +-------------------------------------------+-----------------------+-----------------------+-----------------------+
g_sys_area_addr              15 pools          pool[0]->addr           pool[1]->addr
pool_offset[0]

      pool[0].addr=g_sys_area_addr+((db_ulong*)g_sys_area_addr)[0]

      +-----------------------+-------+-------+-------+-------+-------+-------+-------+ -------+---------------------------------------------------+
      |                       |     <--- prior|       |       |       |       |       |        |                                                   |
      |                       |       |       |       |       |       |       |       |        |                                                   |
      |                       |       |  next--->     |       |       |       |       |        |                                                   |
      |                       |       |       |       |       |       |       |       |        |                                                   |
      +-----------------------+-------+-------+-------+-------+-------+-------+-------+ -------+---------------------------------------------------+
    pool[0]->ctrl    pool[0]->object_map                                                      pool[0]->object_addr
                              <-----pool[0[->def.object_count*sizeof(ga_object_map_t)---------->

      ga_pool_ctrl_t
      +-------------------------------------------------+
      |cm_spinlock_t   mutex                            |
      |ga_pool_def_t   def                              |->pool[0]->def
      |db_ulong        offset                           |->((db_ulong*)g_sys_area_addr)[0]
      |ga_queue_t      free_objects                     |
      |       db_uint32    count                        |->pool[0]->def.object_count
      |       db_uint32    first                        |->0
      |       db_uint32    last                         |->pool[0]->def.object_count-1
      |                                                 |
      |db_uint32       ex_count                         |
      |db_int32        ex_shm_id[GA_MAX_EXTENDEAD_POOLS]|
      +-------------------------------------------------+
      ga_object_map_t
      +-------------------------------------------------+
      |db_uint32       next                             |
      |db_uint32       prior                            |
      +-------------------------------------------------+


二、g_app_area_addr共享内存
g_app_area_addr(GA_APP_POOL_COUNT=1) only one pool
        +--------+	
        |        |
        |        |
        |        |
        |        |
        +--------+	
g_app_area_addr
```
