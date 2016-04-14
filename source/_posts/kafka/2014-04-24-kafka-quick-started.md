---
layout: post
title: "kafka quick started"
date: 2014-04-24 11:28:12 +0800
category : kafka
---
+ ###install

		下载tar -xzf kafka_2.10-0.8.1.tgz
		tar -xzf kafka_2.10-0.8.1.tgz
	kafka_2.10-0.8.1.tgz中没有发现sbt,可以直接使用  
	kafka-0.8.1-src.tgz中发现0.8.1使用了gradlew
+ ###jars
	+ 使用ZK目录中的ZK jar替换kafka libs/的ZK jar  
	+ ./kafka-producer-perf-test.sh 时发现缺少perf jar
	
			下载kafka-0.8.1-src.tgz
			修改gradle.properties中scalaVersion=2.10.0与kafka_2.10-0.8.1.tgz相匹配
			修改build.gradle的mavenCentral() to  maven{ url:"http://maven.oschina.net/content/groups/public/"}
			./gradlew perf:jar
			copy kafka-0.8.1-src/perf/build/libs/kafka-perf_2.10-0.8.1.jar 到kafka的libs/
+ ###server.properties

	+ server.properties 分解成server.diff server.common  
	server.diff 配置中不同的部分  
	server.common 配置中相同的部分，方便在多台kafka服务器间同步  
	
			#组成server.properties
			cat server.diff>server.properties && cat server.common>>server.properties
			
<!--more-->
		
+ ###[broker config](http://kafka.apache.org/documentation.html#brokerconfigs)

	+ diff
	
		+ *broker.id* - 唯一非负整数
		+ *host.name* - Hostname of broker,它被发布到ZK中可以在ZK中找到
				
				#get /kafka/brokers/ids/2
				{"jmx_port":-1,"timestamp":"1398223889122","host":"data-slave1.xxxx.com","version":1,"port":9092}
	+ common
	
		+ *zookeeper.connect* - hostname1:port1,hostname2:port2,hostname3:port3 或hostname1:port1,hostname2:port2,hostname3:port3/chroot/path  
		kafka的paths比较多，建议放在一个kafka path下,you must create this path yourself 
		
		+ *log.dirs* - kafka log 存放的位置
		
		+ *num.partitions* - 默认的分区数(overridden on a per-topic basis)
		
		+ *log.segment.bytes* - This setting controls the size to which a segment file will grow before a new segment is rolled over in the log(overridden on a per-topic basis)
		
		+ *log.roll.hours* - This setting will force Kafka to roll a new log segment even if the log.segment.bytes size has not been reached(overridden on a per-topic basis)
		
		+ *log.cleanup.policy* - \[delete,compact\](overridden on a per-topic basis)
		
		+ *log.retention.minutes* - The number of minutes to keep a log segment before it is deleted(overridden on a per-topic basis)
		
		+ *log.retention.bytes* - The amount of data to retain in the log for each topic-partitions. Note that this is the limit per-partition so multiply by the number of partitions to get the total data retained for the topic.(overridden on a per-topic basis)
		
		+ *log.cleaner.enable* - This configuration must be set to true for log compaction to run
		
		+ *log.index.size.max.bytes* - The maximum size in bytes we allow for the offset index for each log segment.(overridden on a per-topic basis)

