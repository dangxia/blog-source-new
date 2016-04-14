---
layout: post
title: "hadoop文件切分和合并"
date: 2014-08-18 15:07:20 +0800
comments: true
categories: hadoop
---

+ ###文件切分
	如果想一个大的文件能同时被多个Mapper处理，hadoop一般把一个文件切分成多个splits。当然如果文件被压缩，文件的压缩格式需支持splitable;	
	源代码见:org.apache.hadoop.mapreduce.lib.input.FileInputFormat
	+ ####涉及的参数
		+ blocksize hadoop文件系统的block的大小
		+ splitMaxSize mapreduce.input.fileinputformat.split.maxsize
		+ splitMinSize mapreduce.input.fileinputformat.split.minsize	
		
		`splitSize = max{splitMinSize, min{splitMaxSize, blocksize}}`	
		有意思的是:splitMaxSize设置成大于blocksize没有任何意义。只有splitMinSize>blocksize时，splitSize才会大于blocksize。还是hadoop不希望splitSize>blocksize?
+ ###文件合并
	mapreduce过程，每个split对应一个map jvm 进程（当然也可以通过设置mapred.job.reuse.jvm.num.tasks来使同job的task重用jvm)。过多的小文件给HDFS的性能带来影响，所以有时需要合并小文件成大文件。
