---
layout: post
title: "gwt startup"
date: 2013-07-30 11:28:12 +0800
category : gwt
---
###安装google gwt plugin
>update site http://dl.google.com/eclipse/plugin/${eclipse.version}
###建立maven gwt project
```sh
	mvn archetype:generate    -DarchetypeGroupId=org.codehaus.mojo    -DarchetypeArtifactId=gwt-maven-plugin    -DarchetypeVersion=2.5.1
```
###修改project的pom.xml


<!--more-->
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
###配置eclipse gwt plugin
>google web toolkit 中rmove junit module
###备注
>[eclipse no maven plugins](http://wiki.eclipse.org/M2E_plugin_execution_not_covere)

>[spring source github](https://github.com/SpringSource)

###注意事项
>>1.eclipse gwt plugin 的compile中间件在src/main中,maven在target中，在换了jar包，中间件可能存在不兼容的错误，需要先清理
>>2.gwt 验证 jar包只能使用4.3以下。RPC接口中需要声明Support
>>3.eclipse gwt plugin 安装SDKs需要下载完整的SDK的zip
>>4.在使用泛型时，String不能正确解析,建议使用Provider包装。
>>5.引入source code 需要在xml中声明super path
>>6.maven gwt debug 运行mvn debug 然后debug as a remote java application
>>7.使用延迟绑定EventBus使使用com.google.web.bindery.event.shared.EventBus
>>8.exception SerializationPolicy
	GWT keeps track of a set of types which can be serialized and sent to the client. your.class.Type apparently was not on this list. Lists like this are stored in .gwt.rpc files. These lists are generated, so editing these lists is probably useless. How these lists are generated is a bit unclear, but you can try the following things:
	
	Make sure your.class.Type implements java.io.Serializable
	Make sure your.class.Type has a public no-args constructor
	Make sure the members of your.class.Type do the same
	
	Check if your program does not contain collections of a non-serializable type, e.g. ArrayList<Object>. If such a collection contains your.class.Type and is serialized, this error will occur.
	
	Make your.class.Type implement IsSerializable. This marker interface was specifically meant for classes that should be sent to the client. This didn't work for me, but my class also implemented Serializable, so maybe both interfaces don't work well together.
	
	Another option is to create a dummy class with your.class.Type as a member, and add a method to your RPC interface that gets and returns the dummy. This forces the GWT compiler to add the dummy class and its members to the serialization whitelist.
>>9.Interface SerializationPolicy
	确保有一个实现
>>10.grid 如果不能正确选择，往往是hash eq 出了问题.


