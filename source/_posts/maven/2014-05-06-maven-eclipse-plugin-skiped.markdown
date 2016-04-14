---
layout: post
title: "maven-eclipse-plugin-skiped"
date: 2014-05-06 14:52:19 +0800
comments: true
categories: maven
---
+	###eclipse IDE "Plugin execution not covered by lifecycle ..." solution
```xml
<pluginManagement>
    <plugins>
        <!--This plugin's configuration is used to store Eclipse m2e settings 
            only. It has no influence on the Maven build itself. -->
        <plugin>
            <groupId>org.eclipse.m2e</groupId>
            <artifactId>lifecycle-mapping</artifactId>
            <version>1.0.0</version>
            <configuration>
                <lifecycleMappingMetadata>
                    <pluginExecutions>
                        <pluginExecution>
                            <pluginExecutionFilter>
                                <groupId>org.codehaus.mojo</groupId>
                                <artifactId>
                                    gwt-maven-plugin
                                </artifactId>
                                <versionRange>
                                    [2.5.1,)
                                </versionRange>
                                <goals>
                                    <goal>i18n</goal>
                                </goals>
                            </pluginExecutionFilter>
                            <action>
                                <ignore></ignore>
                            </action>
                        </pluginExecution>
                    </pluginExecutions>
                </lifecycleMappingMetadata>
            </configuration>
        </plugin>
    </plugins>
</pluginManagement>
```
<!--more-->
+	###skip mvn warning for lifecycle-mapping plugin	
Checkout https://github.com/mfriedenhagen/dummy-lifecycle-mapping-plugin	
Run mvn install
