---
layout: post
title: "maven-install-plugin"
date: 2014-05-06 14:40:36 +0800
comments: true
categories: maven
---

+	###install existed jar in local repository	
```xml
<plugin>
	<artifactId>maven-install-plugin</artifactId>
	<version>2.3.1</version>
	<inherited>false</inherited>
	<executions>
		<execution>
			<id>install-kafka</id>
			<phase>validate</phase>
			<goals>
				<goal>install-file</goal>
			</goals>
			<configuration>
				<groupId>kafka</groupId>
				<artifactId>kafka</artifactId>
				<version>0.8-SNAPSHOT</version>
				<packaging>jar</packaging>
				<file>${basedir}/lib/kafka-0.8-SNAPSHOT.jar</file>
				<pomFile>${basedir}/lib/kafka-0.8-SNAPSHOT.xml</pomFile>
			</configuration>
		</execution>
		<execution>
			<id>install-avro-repo-client</id>
			<phase>validate</phase>
			<goals>
				<goal>install-file</goal>
			</goals>
			<configuration>
				<groupId>org.apache.avro</groupId>
				<artifactId>avro-repo-bundle</artifactId>
				<version>1.7.4-SNAPSHOT</version>
				<packaging>jar</packaging>
				<file>${basedir}/lib/avro-repo-bundle-1.7.4-SNAPSHOT-withdeps.jar</file>
				<pomFile>${basedir}/lib/avro-repo-bundle-1.7.4-SNAPSHOT-withdeps.xml</pomFile>
			</configuration>
		</execution>
	</executions>
</plugin>
```
