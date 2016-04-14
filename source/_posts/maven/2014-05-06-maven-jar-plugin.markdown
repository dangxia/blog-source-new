---
layout: post
title: "maven-jar-plugin"
date: 2014-05-06 14:47:53 +0800
comments: true
categories: maven
---
#	generate XXXX-tests.jar	
```xml
<plugin>
	<groupId>org.apache.maven.plugins</groupId>
	<artifactId>maven-jar-plugin</artifactId>
	<version>2.2</version>
	<executions>
		<execution>
			<goals>
				<goal>test-jar</goal>
			</goals>
		</execution>
	</executions>
</plugin>
```
