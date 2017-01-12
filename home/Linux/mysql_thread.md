##线程
以下是有一个connect的情况
```
Thread 17 (Thread 0x2b1a95245700 (LWP 119753)):
#0  0x00002b1a93b026a4 in ?? () from /lib64/libaio.so.1
#1  0x0000000000a22f9e in os_aio_linux_collect ()
#2  0x0000000000a23312 in os_aio_linux_handle ()
#3  0x00000000009d28aa in fil_aio_wait ()
#4  0x000000000092c2ed in io_handler_thread ()
#5  0x00002b1a938ec6b6 in start_thread () from /lib64/libpthread.so.0
#6  0x00002b1a94db919d in clone () from /lib64/libc.so.6
#7  0x0000000000000000 in ?? ()
Thread 16 (Thread 0x2b1a9f7c0700 (LWP 119754)):
#0  0x00002b1a93b026a4 in ?? () from /lib64/libaio.so.1
#1  0x0000000000a22f9e in os_aio_linux_collect ()
#2  0x0000000000a23312 in os_aio_linux_handle ()
#3  0x00000000009d28aa in fil_aio_wait ()
#4  0x000000000092c2ed in io_handler_thread ()
#5  0x00002b1a938ec6b6 in start_thread () from /lib64/libpthread.so.0
#6  0x00002b1a94db919d in clone () from /lib64/libc.so.6
#7  0x0000000000000000 in ?? ()
Thread 15 (Thread 0x2b1a9f9c1700 (LWP 119755)):
#0  0x00002b1a93b026a4 in ?? () from /lib64/libaio.so.1
#1  0x0000000000a22f9e in os_aio_linux_collect ()
#2  0x0000000000a23312 in os_aio_linux_handle ()
#3  0x00000000009d28aa in fil_aio_wait ()
#4  0x000000000092c2ed in io_handler_thread ()
#5  0x00002b1a938ec6b6 in start_thread () from /lib64/libpthread.so.0
#6  0x00002b1a94db919d in clone () from /lib64/libc.so.6
#7  0x0000000000000000 in ?? ()
Thread 14 (Thread 0x2b1a9fbc2700 (LWP 119756)):
#0  0x00002b1a93b026a4 in ?? () from /lib64/libaio.so.1
#1  0x0000000000a22f9e in os_aio_linux_collect ()
#2  0x0000000000a23312 in os_aio_linux_handle ()
#3  0x00000000009d28aa in fil_aio_wait ()
#4  0x000000000092c2ed in io_handler_thread ()
#5  0x00002b1a938ec6b6 in start_thread () from /lib64/libpthread.so.0
#6  0x00002b1a94db919d in clone () from /lib64/libc.so.6
#7  0x0000000000000000 in ?? ()
Thread 13 (Thread 0x2b1a9fdc3700 (LWP 119757)):
#0  0x00002b1a93b026a4 in ?? () from /lib64/libaio.so.1
#1  0x0000000000a22f9e in os_aio_linux_collect ()
#2  0x0000000000a23312 in os_aio_linux_handle ()
#3  0x00000000009d28aa in fil_aio_wait ()
#4  0x000000000092c2ed in io_handler_thread ()
#5  0x00002b1a938ec6b6 in start_thread () from /lib64/libpthread.so.0
#6  0x00002b1a94db919d in clone () from /lib64/libc.so.6
#7  0x0000000000000000 in ?? ()
Thread 12 (Thread 0x2b1a9ffc4700 (LWP 119758)):
#0  0x00002b1a93b026a4 in ?? () from /lib64/libaio.so.1
#1  0x0000000000a22f9e in os_aio_linux_collect ()
#2  0x0000000000a23312 in os_aio_linux_handle ()
#3  0x00000000009d28aa in fil_aio_wait ()
#4  0x000000000092c2ed in io_handler_thread ()
#5  0x00002b1a938ec6b6 in start_thread () from /lib64/libpthread.so.0
#6  0x00002b1a94db919d in clone () from /lib64/libc.so.6
#7  0x0000000000000000 in ?? ()
Thread 11 (Thread 0x2b1aa01c5700 (LWP 119759)):
#0  0x00002b1a93b026a4 in ?? () from /lib64/libaio.so.1
#1  0x0000000000a22f9e in os_aio_linux_collect ()
#2  0x0000000000a23312 in os_aio_linux_handle ()
#3  0x00000000009d28aa in fil_aio_wait ()
#4  0x000000000092c2ed in io_handler_thread ()
#5  0x00002b1a938ec6b6 in start_thread () from /lib64/libpthread.so.0
#6  0x00002b1a94db919d in clone () from /lib64/libc.so.6
#7  0x0000000000000000 in ?? ()
Thread 10 (Thread 0x2b1aa03c6700 (LWP 119760)):
#0  0x00002b1a93b026a4 in ?? () from /lib64/libaio.so.1
#1  0x0000000000a22f9e in os_aio_linux_collect ()
#2  0x0000000000a23312 in os_aio_linux_handle ()
#3  0x00000000009d28aa in fil_aio_wait ()
#4  0x000000000092c2ed in io_handler_thread ()
#5  0x00002b1a938ec6b6 in start_thread () from /lib64/libpthread.so.0
#6  0x00002b1a94db919d in clone () from /lib64/libc.so.6
#7  0x0000000000000000 in ?? ()
Thread 9 (Thread 0x2b1aa05c7700 (LWP 119761)):
#0  0x00002b1a93b026a4 in ?? () from /lib64/libaio.so.1
#1  0x0000000000a22f9e in os_aio_linux_collect ()
#2  0x0000000000a23312 in os_aio_linux_handle ()
#3  0x00000000009d28aa in fil_aio_wait ()
#4  0x000000000092c2ed in io_handler_thread ()
#5  0x00002b1a938ec6b6 in start_thread () from /lib64/libpthread.so.0
#6  0x00002b1a94db919d in clone () from /lib64/libc.so.6
#7  0x0000000000000000 in ?? ()
Thread 8 (Thread 0x2b1aa07c8700 (LWP 119762)):
#0  0x00002b1a93b026a4 in ?? () from /lib64/libaio.so.1
#1  0x0000000000a22f9e in os_aio_linux_collect ()
#2  0x0000000000a23312 in os_aio_linux_handle ()
#3  0x00000000009d28aa in fil_aio_wait ()
#4  0x000000000092c2ed in io_handler_thread ()
#5  0x00002b1a938ec6b6 in start_thread () from /lib64/libpthread.so.0
#6  0x00002b1a94db919d in clone () from /lib64/libc.so.6
#7  0x0000000000000000 in ?? ()
Thread 7 (Thread 0x2b1aa09c9700 (LWP 119764)):
#0  0x00002b1a938f08b9 in pthread_cond_timedwait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
#1  0x0000000000a2597e in os_cond_wait_timed ()
#2  0x0000000000a25938 in os_event_wait_time_low ()
#3  0x0000000000929c56 in srv_lock_timeout_thread ()
#4  0x00002b1a938ec6b6 in start_thread () from /lib64/libpthread.so.0
#5  0x00002b1a94db919d in clone () from /lib64/libc.so.6
#6  0x0000000000000000 in ?? ()
Thread 6 (Thread 0x2b1aa0bca700 (LWP 119765)):
#0  0x00002b1a938f08b9 in pthread_cond_timedwait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
#1  0x0000000000a2597e in os_cond_wait_timed ()
#2  0x0000000000a25938 in os_event_wait_time_low ()
#3  0x0000000000929fe2 in srv_error_monitor_thread ()
#4  0x00002b1a938ec6b6 in start_thread () from /lib64/libpthread.so.0
#5  0x00002b1a94db919d in clone () from /lib64/libc.so.6
#6  0x0000000000000000 in ?? ()
Thread 5 (Thread 0x2b1aa1075700 (LWP 119766)):
#0  0x00002b1a938f08b9 in pthread_cond_timedwait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
#1  0x0000000000a2597e in os_cond_wait_timed ()
#2  0x0000000000a25938 in os_event_wait_time_low ()
#3  0x0000000000929900 in srv_monitor_thread ()
#4  0x00002b1a938ec6b6 in start_thread () from /lib64/libpthread.so.0
#5  0x00002b1a94db919d in clone () from /lib64/libc.so.6
#6  0x0000000000000000 in ?? ()
Thread 4 (Thread 0x2b1aa1276700 (LWP 119767)):
#0  0x00002b1a938f051c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
#1  0x0000000000a25793 in os_cond_wait ()
#2  0x0000000000a256fe in os_event_wait_low ()
#3  0x000000000092b7a5 in srv_master_thread ()
#4  0x00002b1a938ec6b6 in start_thread () from /lib64/libpthread.so.0
#5  0x00002b1a94db919d in clone () from /lib64/libc.so.6
#6  0x0000000000000000 in ?? ()
Thread 3 (Thread 0x2b1aa1297700 (LWP 119779)):
#0  0x00002b1a938f43e7 in do_sigwait () from /lib64/libpthread.so.0
#1  0x00002b1a938f448d in sigwait () from /lib64/libpthread.so.0
#2  0x000000000054f44b in signal_hand ()
#3  0x00002b1a938ec6b6 in start_thread () from /lib64/libpthread.so.0
#4  0x00002b1a94db919d in clone () from /lib64/libc.so.6
#5  0x0000000000000000 in ?? ()
Thread 2 (Thread 0x2b1aa12b8700 (LWP 127329)):
#0  0x00002b1a938f36bd in read () from /lib64/libpthread.so.0
#1  0x0000000000b3101b in vio_read ()
#2  0x000000000055757d in my_real_read(st_net*, unsigned long*) ()
#3  0x0000000000557b17 in my_net_read ()
#4  0x00000000005f0033 in do_command(THD*) ()
#5  0x00000000006bf4bf in do_handle_one_connection(THD*) ()
#6  0x00000000006bf57b in handle_one_connection ()
#7  0x00002b1a938ec6b6 in start_thread () from /lib64/libpthread.so.0
#8  0x00002b1a94db919d in clone () from /lib64/libc.so.6
#9  0x0000000000000000 in ?? ()
Thread 1 (Thread 0x2b1a95044540 (LWP 119751)):
#0  0x00002b1a94dafcd6 in poll () from /lib64/libc.so.6
#1  0x000000000055056c in handle_connections_sockets() ()
#2  0x0000000000554dfc in mysqld_main(int, char**) ()
#3  0x000000000054a847 in main ()
```
