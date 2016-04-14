---
layout: post
title: "maven jdk version"
date: 2014-04-30 17:39:48 +0800
comments: true
categories: maven
---
+	###plugin	
```xml
<plugin>
	<groupId>org.apache.maven.plugins</groupId>
	<artifactId>maven-compiler-plugin</artifactId>
	<configuration>
		<source>1.6</source>
		<target>1.6</target>
	</configuration>
</plugin>
```
该段代码加入pom.xml中就可以指定该project的jdk版本（可以被继承）	

+	###JAVA_HOME	
```sh
JAVA_HOME=$JAVA_HOME_15 mvn install   # run with 1.5
JAVA_HOME=$JAVA_HOME_16 mvn install   # run with 1.6
```
<!--more-->
+	###profile	
```xml
<profile>
	<id>jdk-1.7</id>
	<activation>
		<jdk>1.7</jdk>
	</activation>
	<properties>
		<maven.compiler.source>1.6</maven.compiler.source>
		<maven.compiler.target>1.6</maven.compiler.target>
		<maven.compiler.compilerVersion>1.6</maven.compiler.compilerVersion>
	</properties>
</profile>
```
加入maven的config下的setting.xml中，所有的project都会成效		
以上profile只有在jdk为1.7时激活,可以改成默认激活	
```xml
<activation>  
	<activeByDefault>true</activeByDefault>  
</activation>
```
或显示激活	
```xml
<activeProfiles>  
	<activeProfile>jdk-1.7</activeProfile>  
</activeProfiles> 
```
或mvn命令行显示激活	
```sh
 #mvn -P,--activate-profiles <arg>           Comma-delimited list of profiles
mvn -Pjdk-1.7
```

