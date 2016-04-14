title: work-detail-2014-11
date: 2014-11-05 17:41:54
tags: [work]
---
##	2014-11-03
************************
+	Hive优化讨论
+	安徽电信、重庆电信 pv 付费记录同步

##	2014-11-04
************************
+	project:hive-order-mr 添加点播处理，广告处理错误的记录
+	讨论nodeserver的日志格式

##	2014-11-05
************************
+	重构project:storm-order 
	+	添加partitions.meta.cache.timeout配置
	+	添加noendOffset(目的：减少storm起始的并发量)
+	安装WIN7测试服务器
+	适配点播session transformer 为mapreduce,storm共用
	+	hobbit2-cache 添加auto refresh功能
	+	dungbeetle-api 新建类DummyTaskAttemptContext，让storm模仿mapreduce发送transformer的context

##	2014-11-06
************************
+	NodeServer Kafka通讯接口文档的编写
+	适配点播session transformer 为mapreduce,storm共用(续)
	点播session生成独立成hobbit2-order-common模块，以便mapreduce和storm使用

##	2014-11-07
************************
+	重构project:storm-order
	+	使用session transformer模块重写ExtraInfoQueryStateImpl
	+	新建com.voole.hobbit2.storm.order.util.PhoenixUtils：Avro实例到phoenixSQL的转换等。

##	2014-11-09
************************
+	重构project:storm-order(续)
	+	使用phoenix重写SessionState模块
+	实时，离线点播日志添加字段:metric_partnerinfo,extinfo,vssip,perfip
	
##	2014-11-10
************************
+	测试phoenix点播记录查询速度
	+	230W条记录
	+	no index 46s
	+	local index 23s
	+	global index 17s
+	实时，离线点播日志添加字段:bitrate
+	redis实时点播广告处理添加uid字段
+	salting phoenix点播记录表SALT_BUCKETS=14

##	2014-11-11
************************
+	phoenix索引问题:
	+	索引文件比source表文件还要大
	+	根据索引查询，提升不大
+	slave5-7被重启，hbase无法修复，clean hbase,restart hbase

##	2014-11-12
+	project:camus添加对bs_epg_info的支持
+	project:hive_order_mr添加对bs_epg_info的支持
+	修复hadoop missing block,hadoop fsck -delete

##	2014-11-13
+	phoenix 升级到4.2
+	data-slave1 更换硬盘，被关机，修复并重启服务。
+	开会

##	2014-11-14
+	修改project:hive_order_mr的topic meta的注册机制
+	data-slave1 更换硬盘，被关机，修复并重启服务。
+	开会

##	2014-11-18
+	查找hbase点播记录没有bgn的问题
	+	发现bgn和alive的IP地址不一样
	+	点播mr和storm记录的key中去掉了ip

##	2014-11-19
+	flex 计算和展示
+	讨论hbase实时和历史合一
	
##	2014-11-20
+	flex 计算和展示(续)(完成)