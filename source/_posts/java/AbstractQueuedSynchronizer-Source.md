title: AbstractQueuedSynchronizer Source
date: 2016-03-22 11:18:02
tags: [java]
categories: [java]
---
### 不添加Node到queue
+ tryAcquire 可以获得锁
+ tryAcquireShared 可以获得锁

### 进入queue
pred.waitStatus == SIGNAL  ==> park
pred.waitStatus == CANCELED ==> 更新祖先节点,直到祖先节点不为CANCELED的节点
其他 => 更新祖先节点为SIGNAL , park

### acquireQueued
setHead(node),原先的head被移除


### waitStatus
enq : 0
被下一个enq:更新为SINGAL
被unparkSuccessor:更新为:0
cancelAcquire:当超时或interrept,更新为CANCELLED




