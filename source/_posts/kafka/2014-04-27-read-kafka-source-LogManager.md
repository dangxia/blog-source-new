---
layout: post
title: "kafka源码学习:LogManager"
date: 2014-04-24 11:28:12 +0800
category : kafka
---
+ #####logdir目录结构
	+	recovery-point-offset-checkpoint  
		该文件对应类OffsetCheckpoint  
		第1行：version	正常值为:0  
		第2行：expectedSize  
		第3行~第n行：topic	partition	offset  
		expectedSize 应该为所有offset的和
	+	replication-offset-checkpoint
	+	.kafka_cleanshutdown  
		如果有此文件表明kakfa正常关闭，log不需要recovery
	+	topic dirs  
		每个dir对应一个Log instance  
		dir name: topic-partition
+ #####topic目录结构
	+	startoffset.log  
		对应类LogSegment  
		每个topic有1～n个segment文件，startoffset为该segment的开始offset  
		每个segment文件都有一个如之相对应的index文件
	+	startoffset.index  
		对应类OffsetIndex
	+	startoffset.log.deleted
	+	startoffset.index.deleted
	+	startoffset.log.cleaned
	+	startoffset.index.cleaned
	+	startoffset.index.swap
	+	startoffset.log.swap
+ #####相关类
	+	Log
	+	
+ #####LogManager参数
	+ logDirs - log 所在的位置
	+ topicConfigs - topic的特别配置
	+ defaultConfig - log default config
	+ cleanerConfig 
	+ flushCheckMs
	+ flushCheckpointMs
	+ retentionCheckMs
+ #####主要property
	+ logs - Pool[TopicAndPartition, Log]
	+ recoveryPoints - logdir => OffsetCheckpoint
	+ cleaner
