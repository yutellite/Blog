


# 2017-01-03 中东某大亨国家代表处DU局点限呼问题
>现网升级后出现两次限呼情况，客户异常关注，紧急公关。


## 问题现象
现网自从升级后，出现两次限呼，限呼主要由于longsql造成，通过日志可以看出，限呼时的longsql时长峰值可达5000ms。

##环境
redhat 6.6 32 core

## 数据整理
从底层数据库产品角度需要解释两个关键问题：
>时间点从凌晨03:00持续到09:00。   
1、日志中出现大量的longsql，时间为30~50ms不等；   
2、日志在某些时间点longsql时长可达5000ms的峰值，直接longsql造成了限呼。   

数据：  
1、数据库所有的日志信息；  
2、系统atop数据。  

解析：  
从atop数据中解析数据。  
```
atop -r atop.log -b begin(hh:mm) -e end(hh:mm) > atop.log.txt  
```
为了更好分析，制造atop中关键信息与时间的波峰图：  
1、系统cpu（sys、usr）占有率；  
2、问题进程p（syscpu、usrcpu、cpu）占有率，p进程是直接导致系统cpu高的元凶；  
3、longsql时延与时间轴；  

## 数据分析  
整合发现：  
1、将cpu（sys、usr）、p（cpu）整合到一张波峰图中，完美的峰谷重合，可以p是真凶；  
2、p的syscpu远比usrcpu来的高，usrcpu很稳定，syscpu在问题时间点峰值瞬间波动到250s，cpu（sys）瞬间到1300%，p进行CPU 768%。平时一般都为p(syscpu-18s、usrcpu-18s两者相当)，说明p进程出问题时，长时间处于系统调用层。  
>* syscpu、usrcpu分别是进程运行时处于系统调用内核态、用户态所占CPU的时间比例。  
  
3、现网cache使用率很高，包括共享内存已经达到mem的92%（总内存338G）， free内存已经只剩659M。  
4、由于现网并没有gstack，所以无从得知问题复现时进程p的活动。只有通过perf抓取系统调用，看各层调用时耗情况。  
```
perf record -g -p pid //pid进程号，执行完ctrl+c结束  
perf report           //查看结果  
```      
结果：  
8.71%   0.10%   p   libpthread-2.12.so      [.]\__lll_unlock_wake  
8.18%   8.18%   p   [kernel.kallsyms]       [.]\_spin_unlock_irqrestore  
8.12%   5.42%   p   libc-2.12.so            [.] memcpy  
5.95%   5.94%   p   [vsyscall]              [.] 0x0000000000000014c  
5.56    5.96    p   [kernel.kallsyms]       [k] default_send_IPI_mask_sequence_phys  
...
以上是标红重点耗时靠前的调用。  
\__lll_unlock_wake线程锁需要调用  
\_spin_unlock_irqrestore中断恢复  
  
没有十分有用信息，只知道系统调用花费时间很长，可能造成cpu高。  
  
意外：  
业务进程p如果全部断连DB时，会unattached DB共享内存在排查时，后面有连接请求会重新malloc内存进行重连。  
  
业务在总结问题时发现p进程在cache使用率高下重新申请内存会触发cpu高，怀疑触发系统内存回收机制。  
  
## 分析尾声  
有了怀疑点，下面就是去验证怀疑点，拉通redhat原厂工程师，排查现网  
```  
cat /proc/buddyinfo  
```  
linux是根据node中的阈值判断是否回收内存，申请内存是否走快速还是慢速机制，现网该阈值已经达到慢速申请范围，导致申请内存走慢速机制，触发回收，回收扫描page，全是内核行为，该行为造成cpu高。  
  
##规避措施  
1、定时任务定时清理cache  
2、现网调整zone阈值  


---------------------------------------------------------------------------------------------------------

##接下来，试图从linux内存回收的角度解释一下原理 

>linux内核对空闲内存空间的管理采用的是buddy管理算法 

>linux内核不是把整块物理内存看成一整块，而是划分为不同的内存池，不同的内存池称为zones，内存管理的基本单位都是以zone划分的。 

##查看空闲页 

以下操作均在本地服务器上，非现网： 


```
1 <1013 linux6 [tyhdb] :/onip/tyhdb/atop>cat /proc/buddyinfo        
2 Node 0, zone DMA     1     1    2     2     1   1    0   0    1    1    3
3 Node 0, zone DMA32  1071  385   2348  2042 805  68   13  6    6    6   52
4 Node 0, zone Normal 60545 11673 37463 8450 2928 1192 993 647 1502 589 191
5 Node 1, zone Normal 89112 6693  12613 8784 3675 552  318 1948 684 486 1429
6 以上的数据都是用2的幂来表示page的个数，分别为：
7            2^0 2^1 2^2 2^3 2^4 2^5 2^6 2^7 2^8 2^9 2^10
8 例如：DMA32的空闲大小为：
9 (1071*1+385*2+2348*4+2042*8+805*16+68*32+13*64+6*128+6*256+6*512+52*1024)*PAGE_SIZE 
```

可以通过pagetypeinfo查看更详细的信息

```
-bash代码
1 linux6:~ # cat /proc/pagetypeinfo
2 Page block order: 9
3 Pages per block:  512
4  
5 Free pages count per migrate type at order 0   1   2   3   4   5   6   7   8   9  10
6 Node 0, zone   DMA, type Unmovable   0   0   0   0   0   0   0   0   0   0   0
7 Node 0, zone   DMA, type Reclaimable 0   0   0   0   0   0   0   0   0   0   0
8 
···
```

这里补充一句：

如果发现有大量的order 0的free page，说明系统内存有大量的碎片，因为buddy算法会自动将小的连续的page合成更大的page块，这种情况说明碎片很多，无法合成，如下所示，可以认为系统碎片率还不是很高。

```
-bash代码
01 linux6:~ # cat /proc/buddyinfo;echo m>/proc/sysrq-trigger;grep -i Normal /var/log/messages | tail -3
02 Node 0, zone  DMA      1      1      2      2      1      1      0      0      1      1   3
03 Node 0, zone  DMA32   1071    385   2348   2042    805     68     13      6      6    6   52
04 Node 0, zone  Normal  44951  12730  37598   8478   2825   1192    994    648   1502   590 191
05 Node 1, zone  Normal  84863   7818  12711   8925   3705    568    293   1946    683   487 1429
06 
07
Jan  6 15:48:30 linux6 kernel: [2440887.190039] Node 1 Normal free:9821868kB min:51220kB low:64024kB high:76828kB active_anon:20737992kB inactive_anon:6066100kB active_file:12118632kB inactive_file:513996kB unevictable:15217384kB isolated(anon):0kB isolated(file):0kB present:66191360kB mlocked:11520kB dirty:176kB writeback:0kB mapped:28140236kB shmem:29370668kB slab_reclaimable:587332kB slab_unreclaimable:49228kB kernel_stack:6352kB pagetables:161528kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
08 
09
Jan  6 15:48:30 linux6 kernel: [2440887.190064] Node 0 Normal: 44951*4kB 12730*8kB 37598*16kB 8478*32kB 2825*64kB 1192*128kB 994*256kB 648*512kB 1502*1024kB 590*2048kB 191*4096kB = 5602828kB
10
11
Jan  6 15:48:30 linux6 kernel: [2440887.190072] Node 1 Normal: 84863*4kB 7818*8kB 12711*16kB 8925*32kB 3705*64kB 568*128kB 293*256kB 1946*512kB 683*1024kB 487*2048kB 1429*4096kB = 9822108kB
```

linux的zone划分图：



1 如果机器物理内存小于4G，那么，64位系统就有可能没有Normal部分，比如说如果物理内存只有2G，那么完全没有Normal，如果4G，可能只有小部分Normal；

2 DMA和DMA32都是针对特定支持DMA传输的硬件使用的，但是如果在64位机子上申请Normal内存，而Normal上没有free内存，而DMA32块上有足够的free内存，那么也可以从DMA32上申请，也就是说，DMA区除了优先供DMA特殊服务外可以作为通用；

3 zone是attach到node上的，一般机器只有一个node0，但是大的服务器会有多个node，系统为进程分配内存时是从node上的RAM进行分配的；

4 DMA、DMA32和32-bit的Normal只会存在于node0上，而其他的node只会有Normal（64-bit）或HighMem（32-bit）；

内存回收

kswapd是linux的内存回收线程，相关介绍可以看这里，内存触发可以参考这里。内存回收与交换参考这里。


内存回收机制：

1、kswapd周期性检查，保证内存剩余足够；

2、触发式内存回收，即分配内存时没有空闲内存可以使用，触发回收；





触发条件

1、申请内存不足；

2、kswapd周期检测发现内存达到一定阈值；

那么这个阈值时什么？

可以从内存使用水位来说明。zone的内存水位分min、low、high三个档位，内存回收行为基于剩余内存的水位来进行决策。下图中详细描述了kswapd的唤醒和休眠情况。

zone的内存水位



```
min_free_kbytes


-bash代码
1
linux6:/tmp/test # cat /proc/sys/vm/min_free_kbytes
2
102400
```

2.min_free_kbytes的主要用途是计算影响内存回收的三个参数 watermark[min/low/high]
1) watermark[high] > watermark [low] > watermark[min]，各个zone各一套
2)在系统空闲内存低于 watermark[low]时，开始启动内核线程kswapd进行内存回收（每个zone一个），直到该zone的空闲内存数量达到watermark[high]后停止回收。如果上层申请内存的速度太快，导致空闲内存降至watermark[min]后，内核就会进行direct reclaim（直接回收），即直接在应用程序的进程上下文中进行回收，再用回收上来的空闲页满足内存申请，因此实际会阻塞应用程序，带来一定的响应延迟，而且可能会触发系统OOM。这是因为watermark[min]以下的内存属于系统的自留内存，用以满足特殊使用，所以不会给用户态的普通申请来用。

min_free_kbytes的主要用途是计算影响内存回收的三个参数 watermark[min/low/high]

https://yq.aliyun.com/articles/8865
http://www.myjishu.com/?p=80
http://liwei.life/2016/06/27/linux%E7%9A%84%E5%86%85%E5%AD%98%E5%9B%9E%E6%94%B6%E5%92%8C%E4%BA%A4%E6%8D%A2/
http://kernel.taobao.org/index.php?title=Kernel_Documents/mm_sysctl
