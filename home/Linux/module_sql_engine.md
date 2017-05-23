```c
sql_parse_new_dml 
    sql_parse_dml_remain_text() 
        switch(word_id) 
            CM_KW_SELECT 
                sql_parse_select() 
                    sql_alloc_mem 
                    sql_init_select 
                    sql_parse_select_columns()---column field lists 
                    sql_parse_select_tables() ---table lists 
                    WHILE 1 
                    do 
                        /* 
                              following sql text is optional, can be: 
                             WHERE, 
                             FOR UPDATE [ WAIT | NOWAIT], 
                             ORDER BY, 
                             GROUP BY, 
                             FETCH xxx TO xxx, 
                             HAVING 
                        */ 
                        switch parse_info->end_word.id 
                            CM_KW_WHERE 
                                sql_parse_select_condition()----condition field lists 
                            CM_KW_ORDER 
                                sql_parse_select_order_by()-----order by field lists 
                            CM_KW_GROUP 
                                sql_parse_select_group_by()-----group by field lists 
                            CM_KW_FOR 
                                sql_parse_select_having()-----having field lists 
                            CM_KW_FETCH 
                                sql_parse_select_for()-----SELECT FOR FIELD LISTS 
                            CM_KW_HAVING 
                                sql_parse_select_fetch()---FETCH FIELD LISTS 
                            CM_KW_UNION 
                                SQL_SET_ERROR_EXCLUDE_WORD---UNION LISTS 
                    done 
            CM_KW_UPDATE 
                sql_parse_update() 
            CM_KW_INSERT 
                sql_parse_insert() 
            CM_KW_EXEC 
                sql_parse_exec() 
            CM_KW_CALL 
                sql_parse_call() 
            CM_KW_DELETE 
                sql_parse_delete() 
    sql_verify()                            ----------object exists check (find id by name)-->permission check(username/passwd/schema)-->logical check-->build query tree-> 
        SWITCH ctx->stmt_type 
            SQL_STMT_SELECT 
                sql_verify_select() 
                    sql_verify_accumulator() 
                    sql_privs_req_objprivs_ext() 
 
                    sql_verify_join_conditions 
                    sql_verify_select_columns 
                    sql_verify_select_where 
                    sql_verify_select_group 
                    sql_verify_distinct_columns 
                    sql_verify_select_having 
                    sql_verify_select_order 
                    sql_verify_select_columns_group 
                    sql_simple_stmt 
            SQL_STMT_UPDATE 
            SQL_STMT_UPDATE_ACCUM 
            SQL_STMT_DELETE 
            SQL_STMT_INSERT 
            SQL_STMT_EXEC 
            SQL_STMT_CALL 
 
            SQL_STMT_UNION 
            SQL_STMT_UNION_ALL 
 
            default 
 
        sql_verify_hint 
    sql_optimize()--------------------------------- 
 
```
