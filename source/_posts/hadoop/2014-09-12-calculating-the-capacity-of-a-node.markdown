---
layout: post
title: "Calculating the Capacity of a Node"
date: 2014-09-12 16:23:08 +0800
comments: true
categories: hadoop
---
[1]:http://docs.hortonworks.com/HDPDocuments/HDP2/HDP-2.1-latest/bk_using-apache-hadoop/content/node_capacity.html	"Calculating the Capacity of a Node"
[2]:http://docs.hortonworks.com/HDPDocuments/HDP2/HDP-2.1.5/bk_installing_manually_book/content/rpm-chap1-11.html	"Determine YARN and MapReduce Memory Configuration Settings"
转自：[Calculating the Capacity of a Node][1]	
Because YARN has now removed the hard partitioned mapper and reducer slots of Hadoop Version 1, new capacity calculations are required. There are eight important parameters for calculating a node’s capacity that are specified in *mapred-site.xml* and *yarn-site.xml*:	
	
+	###In mapred-site.xml:
		mapreduce.map.memory.mb	
		mapreduce.reduce.memory.mb`
These are the hard limits enforced by Hadoop on each mapper or reducer task.	
<!--more-->
		mapreduce.map.java.opts
		mapreduce.reduce.java.opts
*The heapsize of the jvm –Xmx for the mapper or reducer task. Remember to leave room for the JVM Perm Gen and Native Libs used. This value should always be lower than `mapreduce.[map|reduce].memory.mb`.*	

+	###In yarn-site.xml:
		yarn.scheduler.minimum-allocation-mb
The smallest container that YARN will allow.	

		yarn.scheduler.maximum-allocation-mb
The largest container that YARN will allow.	

		yarn.nodemanager.resource.memory-mb
The amount of physical memory (RAM) for Containers on the compute node. It is important that this is not equal to the total amount of RAM on the node, as other Hadoop services also require RAM.	

		yarn.nodemanager.vmem-pmem-ratio
The amount of virtual memory that each Container is allowed. This can be calculated with:`containerMemoryRequest*vmem-pmem-ratio`	

+	###Example YARN MapReduce Settings
<table border="1" 
	style="border-collapse: collapse; mso-table-layout-alt: fixed; mso-yfti-tbllook: 1184; mso-padding-alt: 0in 0in 0in 0in"
	width="705" id="d6e372">
	<colgroup>
		<col width="250pt">
		<col width="100pt">
	</colgroup>
	<tbody>
		<tr>
			<td valign="top">Property</td>
			<td valign="top">Value</td>
		</tr>
		<tr>
			<td valign="top">mapreduce.map.memory.mb</td>
			<td valign="top">1536</td>
		</tr>
		<tr>
			<td valign="top">mapreduce.reduce.memory.mb</td>
			<td valign="top">2560</td>
		</tr>
		<tr>
			<td valign="top">mapreduce.map.java.opts</td>
			<td valign="top">-Xmx1024m</td>
		</tr>
		<tr>
			<td valign="top">mapreduce.reduce.java.opts</td>
			<td valign="top">-Xmx2048m</td>
		</tr>
		<tr>
			<td valign="top">yarn.scheduler.minimum-allocation-mb</td>
			<td valign="top">512</td>
		</tr>
		<tr>
			<td valign="top">yarn.scheduler.maximum-allocation-mb</td>
			<td valign="top">4096</td>
		</tr>
		<tr>
			<td valign="top">yarn.nodemanager.resource.memory-mb</td>
			<td valign="top">36864</td>
		</tr>
		<tr>
			<td valign="top">yarn.nodemanager.vmem-pmem-ratio</td>
			<td valign="top">2.1</td>
		</tr>
	</tbody>
</table>		

With these settings, each map and reduce task has a generous 512MB of overhead for the Container, as evidenced by the difference between `the mapreduce.[map|reduce].memory.mb` and the `mapreduce.[map|reduce].java.opts`. 	

Next, YARN has been configured to allow a Container no smaller than 512MB and no larger than 4GB. The compute nodes have 36GB of RAM available for Containers. With a virtual memory ratio of 2.1 (the default value), each map can have up to 3225.6MB of RAM, or a reducer can have 5376MB of virtual RAM.

This means that the compute node configured for 36GB of Container space can support up to 24 maps or 14 reducers, or any combination of mappers and reducers allowed by the available resources on the node.

For more information about calculating memory settings, see [Determine YARN and MapReduce Memory Configuration Settings][2].
