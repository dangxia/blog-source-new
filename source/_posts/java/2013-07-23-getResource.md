---
layout: post
title: "getResource"
date: 2013-07-23 11:28:12 +0800
category : java
---
Class.getResource 起始位置为.class文件所在的文件夹。 以/开头的路径起始位置切换到工作目录下。

ClassLoader.getResource的起始位置为工作目录。路径不能以/开头。


spring 的Resource路径,表示绝对路径时用两个//开头。



<!--more-->

