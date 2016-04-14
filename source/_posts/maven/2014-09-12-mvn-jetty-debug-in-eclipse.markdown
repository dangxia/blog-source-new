---
layout: post
title: "mvn jetty debug in eclipse"
date: 2014-09-12 15:53:14 +0800
comments: true
categories: maven
---
+	###create eclipse Program
	eclise->run->External tools->External Configurations->Program->右击->new
	+	Location:${M2_HOME}/bin/mvn	
	+	Work Directory:选择需要debug的工程	
	+	Arguments:jetty:run
	+	Environment:
	`MAVEN_OPTS=-Xdebug -Xnoagent -Djava.compiler=NONE -Xrunjdwp:transport=dt_socket,address=8000,server=y,suspend=y`	
+	###create remote java application
	eclipse->run->debug configurations->remote java application
	+	project 选择需要debug的工程	
	+	Host:localhost
	+	Prot:8000
	+	select allow termination of remote VM
+	###run
	1.	run program
	2.	debug run remote java application 
	
