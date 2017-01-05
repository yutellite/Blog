


# 2017-01-03 中东某大亨国家代表处DU局点限呼问题
>* 现网升级后出现两次限呼情况，客户异常关注，紧急公关。


## 问题现象
现网自从升级后，出现两次限呼，限呼主要由于longsql造成，通过日志可以看出，限呼时的longsql时长峰值可达5000ms。

##环境
redhat 6.6 32 core

## 数据整理
从底层数据库产品角度需要解释两个关键问题：
>* 时间点从凌晨03:00持续到09:00。   
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
