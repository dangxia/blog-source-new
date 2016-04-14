---
layout: post
title: "hadoop configurations"
date: 2014-09-12 17:01:22 +0800
comments: true
categories: hadoop
---
		Yarn的配置keys在org.apache.hadoop.yarn.conf.YarnConfiguration
		MR的配置keys在org.apache.hadoop.mapreduce.MRJobConfig

其他:[YARN详解_参数配置](http://bise.aliapp.com/index.php/435.html)

+	###mapreduce.job.user.classpath.first
	优先加载用户的class
+	###mapreduce.job.jvm.numtasks
	JVM重用
+	###mapreduce.map.speculative
	map 预测执行
+	###mapreduce.reduce.speculative
	reduce 预测执行
