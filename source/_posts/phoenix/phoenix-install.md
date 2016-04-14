title: phoenix-install
date: 2014-10-30 22:27:31
tags: [phoenix]
---

##  环境
************************
* jdk 1.6
* hadoop 2.2
* hbase 0.98.4

## Installation
************************
To install a pre-built phoenix, use these directions:

* Download and expand the latest phoenix-[version]-bin.tar. Use either hadoop1 and hadoop2 artifacts which match your HBase installation.
* Add the phoenix-[version]-server.jar to the classpath of every HBase region server and remove any previous version. An easy way to do this is to copy it into the HBase lib directory (use phoenix-core-[version].jar for Phoenix 3.x)
* Restart all region servers.
  `hbase-daemon.sh restart regionserver`
* Add the phoenix-[version]-client.jar to the classpath of any Phoenix client.

## Command Line
************************
`sqlline.py localhost:2181:/hbase`

