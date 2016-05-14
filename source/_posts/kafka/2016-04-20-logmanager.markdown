---
layout: "post"
title: "LogManager"
date: "2016-04-20 17:45"
category : kafka
tags: kafka
---
kafka version: 0.10.0

### logdir文件结构
+ .lock
`logdir`的`FileLock`的文件
**启动时会加锁,还没有看到何时释放锁.**


+ recovery-point-offset-checkpoint
操作类`OffsetCheckpoint`,line format: `{version}\n({topic}\s{partition}\s{offset})*`,`version`为0

+ .kafka_cleanshutdown
>Clean shutdown file that indicates the broker was cleanly shutdown in 0.8. This is required to maintain backwards compatibility with 0.8 and avoid unnecessary log recovery when upgrading from 0.8 to 0.8.1

+ {topic}-{partition}
topic-partition分区的目录,操作类`Log`

### log的文件结构
FileSuffix:
+ .log
a log file
+ .index
an index file
+ .deleted
a file that is scheduled to be deleted
+ .cleaned
A temporary file that is being used for log cleaning
+ .swap
A temporary file used when swapping files into the log
