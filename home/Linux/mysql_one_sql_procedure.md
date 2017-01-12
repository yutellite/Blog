###1 mysqld_main函数
```
mysqld_main
mysql_service
win_main

/*
void one_thread_scheduler()
{
  scheduler_init();
  thread_scheduler= &one_thread_scheduler_functions;
}
*/
/*
one_thread_per_connection_scheduler_functions
{
 init_new_connection_handler_thread,    // init_new_connection_thread
 create_thread_to_handle_connection,    // add_connection
}
*/

*handle_connections_sockets*
create_new_thread
->MYSQL_CALLBACK --> MYSQL_CALLBACK(thread_scheduler, add_connection, (thd));
-->thread_scheduler.add_connection             <-create_thread_to_handle_connection()

create_thread_to_handle_connection
->handle_one_connection
-->do_handle_one_connection
-->thread_scheduler.init_new_connection_thread  <-init_new_connection_handler_thread()
--->do_command()
---->dispatch_command()
---->switch(command)
---->case1: case2:
---->case COM_QUERY: -->mysql_parse()-->parse_sql

```
