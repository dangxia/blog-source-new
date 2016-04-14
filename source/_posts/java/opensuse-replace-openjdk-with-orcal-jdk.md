title: opensuse replace openjdk with orcal jdk
date: 2015-01-06 19:29:15
tags: [java]
---
##  安装openjdk
opensuse 默认只安装了jre没有安装jdk，shell则替换jre和jdk，保证shell能正确运行，首先安装openjdk
## 替换
```ssh
#!/bin/bash
cd /home/hexh/develop/zip
sudo tar -xzf ./jdk-7u71-linux-x64.tar.gz
sudo chown -R root:root jdk1.7.0_71/
sudo mv ./jdk1.7.0_71/ /usr/lib64/
sudo ln -s -T /usr/lib64/jdk1.7.0_71/ /usr/lib64/jdk_Oracle

#Compress the man files involved in your installation
sudo gzip $(readlink -f /usr/lib64/jdk_Oracle/man/man1/java.1)
sudo gzip $(readlink -f /usr/lib64/jdk_Oracle/man/man1/keytool.1)
sudo gzip $(readlink -f /usr/lib64/jdk_Oracle/man/man1/orbd.1)
sudo gzip $(readlink -f /usr/lib64/jdk_Oracle/man/man1/policytool.1)
sudo gzip $(readlink -f /usr/lib64/jdk_Oracle/man/man1/rmid.1)
sudo gzip $(readlink -f /usr/lib64/jdk_Oracle/man/man1/rmiregistry.1)
sudo gzip $(readlink -f /usr/lib64/jdk_Oracle/man/man1/servertool.1)
sudo gzip $(readlink -f /usr/lib64/jdk_Oracle/man/man1/tnameserv.1)

#Prepare the directory for jvm-exports (specific for version 1.7.0): 
sudo mkdir /usr/lib64/jvm-exports/jdk_Oracle
cd /usr/lib64/jvm-exports/jdk_Oracle
sudo ln -s /usr/lib64/jdk_Oracle/jre/lib/rt.jar jaas-1.7.0_Orac.jar
sudo ln -s jaas-1.7.0_Orac.jar jaas-1.7.0.jar
sudo ln -s jaas-1.7.0_Orac.jar jaas.jar
sudo ln -s /usr/lib64/jdk_Oracle/jre/lib/jce.jar jce-1.7.0_Orac.jar
sudo ln -s jce-1.7.0_Orac.jar jce-1.7.0.jar
sudo ln -s jce-1.7.0_Orac.jar jce.jar
sudo ln -s /usr/lib64/jdk_Oracle/jre/lib/rt.jar jdbc-stdext-1.7.0_Orac.jar
sudo ln -s jdbc-stdext-1.7.0_Orac.jar jdbc-stdext-1.7.0.jar
sudo ln -s jdbc-stdext-1.7.0_Orac.jar jdbc-stdext-3.0.jar
sudo ln -s jdbc-stdext-1.7.0_Orac.jar jdbc-stdext.jar
sudo ln -s /usr/lib64/jdk_Oracle/jre/lib/rt.jar jndi-1.7.0_Orac.jar
sudo ln -s jndi-1.7.0_Orac.jar jndi-1.7.0.jar
sudo ln -s /usr/lib64/jdk_Oracle/jre/lib/rt.jar jndi-cos-1.7.0_Orac.jar
sudo ln -s jndi-cos-1.7.0_Orac.jar jndi-cos-1.7.0.jar
sudo ln -s jndi-cos-1.7.0_Orac.jar jndi-cos.jar
sudo ln -s jndi-1.7.0_Orac.jar jndi.jar
sudo ln -s /usr/lib64/jdk_Oracle/jre/lib/rt.jar jndi-ldap-1.7.0_Orac.jar
sudo ln -s jndi-ldap-1.7.0_Orac.jar jndi-ldap-1.7.0.jar
sudo ln -s jndi-ldap-1.7.0_Orac.jar jndi-ldap.jar
sudo ln -s /usr/lib64/jdk_Oracle/jre/lib/rt.jar jndi-rmi-1.7.0_Orac.jar
sudo ln -s jndi-rmi-1.7.0_Orac.jar jndi-rmi-1.7.0.jar
sudo ln -s jndi-rmi-1.7.0_Orac.jar jndi-rmi.jar
sudo ln -s /usr/lib64/jdk_Oracle/jre/lib/jsse.jar jsse-1.7.0_Orac.jar
sudo ln -s jsse-1.7.0_Orac.jar jsse-1.7.0.jar
sudo ln -s jsse-1.7.0_Orac.jar jsse.jar
sudo ln -s /usr/lib64/jdk_Oracle/jre/lib/rt.jar sasl-1.7.0_Orac.jar
sudo ln -s sasl-1.7.0_Orac.jar sasl-1.7.0.jar
sudo ln -s sasl-1.7.0_Orac.jar sasl.jar

sudo /usr/sbin/update-alternatives --install /usr/bin/java java /usr/lib64/jdk_Oracle/bin/java 3 --slave /usr/share/man/man1/java.1.gz java.1.gz /usr/lib64/jdk_Oracle/man/man1/java.1.gz --slave /usr/lib64/jvm/jre jre /usr/lib64/jdk_Oracle/jre --slave /usr/lib64/jvm-exports/jre jre_exports /usr/lib64/jvm-exports/jdk_Oracle --slave /usr/bin/keytool keytool /usr/lib64/jdk_Oracle/bin/keytool --slave /usr/share/man/man1/keytool.1.gz keytool.1.gz /usr/lib64/jdk_Oracle/man/man1/keytool.1.gz --slave /usr/bin/orbd orbd /usr/lib64/jdk_Oracle/bin/orbd --slave /usr/share/man/man1/orbd.1.gz orbd.1.gz /usr/lib64/jdk_Oracle/man/man1/orbd.1.gz --slave /usr/bin/policytool policytool /usr/lib64/jdk_Oracle/bin/policytool --slave /usr/share/man/man1/policytool.1.gz policytool.1.gz /usr/lib64/jdk_Oracle/man/man1/policytool.1.gz --slave /usr/bin/rmid rmid /usr/lib64/jdk_Oracle/bin/rmid --slave /usr/share/man/man1/rmid.1.gz rmid.1.gz /usr/lib64/jdk_Oracle/man/man1/rmid.1.gz --slave /usr/bin/rmiregistry rmiregistry /usr/lib64/jdk_Oracle/bin/rmiregistry --slave /usr/share/man/man1/rmiregistry.1.gz rmiregistry.1.gz /usr/lib64/jdk_Oracle/man/man1/rmiregistry.1.gz --slave /usr/bin/servertool servertool /usr/lib64/jdk_Oracle/bin/servertool --slave /usr/share/man/man1/servertool.1.gz servertool.1.gz /usr/lib64/jdk_Oracle/man/man1/servertool.1.gz --slave /usr/bin/tnameserv tnameserv /usr/lib64/jdk_Oracle/bin/tnameserv --slave /usr/share/man/man1/tnameserv.1.gz tnameserv.1.gz /usr/lib64/jdk_Oracle/man/man1/tnameserv.1.gz

#Compress the man files involved in your installation: 
sudo gzip $(readlink -f /usr/lib64/jdk_Oracle/man/man1/appletviewer.1)
sudo gzip $(readlink -f /usr/lib64/jdk_Oracle/man/man1/apt.1)
sudo gzip $(readlink -f /usr/lib64/jdk_Oracle/man/man1/extcheck.1)
sudo gzip $(readlink -f /usr/lib64/jdk_Oracle/man/man1/jar.1)
sudo gzip $(readlink -f /usr/lib64/jdk_Oracle/man/man1/jarsigner.1)
sudo gzip $(readlink -f /usr/lib64/jdk_Oracle/man/man1/javac.1)
sudo gzip $(readlink -f /usr/lib64/jdk_Oracle/man/man1/javadoc.1)
sudo gzip $(readlink -f /usr/lib64/jdk_Oracle/man/man1/javah.1)
sudo gzip $(readlink -f /usr/lib64/jdk_Oracle/man/man1/javap.1)
sudo gzip $(readlink -f /usr/lib64/jdk_Oracle/man/man1/jcmd.1)
sudo gzip $(readlink -f /usr/lib64/jdk_Oracle/man/man1/jconsole.1)
sudo gzip $(readlink -f /usr/lib64/jdk_Oracle/man/man1/jdb.1)
sudo gzip $(readlink -f /usr/lib64/jdk_Oracle/man/man1/jhat.1)
sudo gzip $(readlink -f /usr/lib64/jdk_Oracle/man/man1/jinfo.1)
sudo gzip $(readlink -f /usr/lib64/jdk_Oracle/man/man1/jmap.1)
sudo gzip $(readlink -f /usr/lib64/jdk_Oracle/man/man1/jps.1)
sudo gzip $(readlink -f /usr/lib64/jdk_Oracle/man/man1/jrunscript.1)
sudo gzip $(readlink -f /usr/lib64/jdk_Oracle/man/man1/jsadebugd.1)
sudo gzip $(readlink -f /usr/lib64/jdk_Oracle/man/man1/jstack.1)
sudo gzip $(readlink -f /usr/lib64/jdk_Oracle/man/man1/jstat.1)
sudo gzip $(readlink -f /usr/lib64/jdk_Oracle/man/man1/jstatd.1)
sudo gzip $(readlink -f /usr/lib64/jdk_Oracle/man/man1/native2ascii.1)
sudo gzip $(readlink -f /usr/lib64/jdk_Oracle/man/man1/pack200.1)
sudo gzip $(readlink -f /usr/lib64/jdk_Oracle/man/man1/rmic.1)
sudo gzip $(readlink -f /usr/lib64/jdk_Oracle/man/man1/schemagen.1)
sudo gzip $(readlink -f /usr/lib64/jdk_Oracle/man/man1/serialver.1)
sudo gzip $(readlink -f /usr/lib64/jdk_Oracle/man/man1/unpack200.1)
sudo gzip $(readlink -f /usr/lib64/jdk_Oracle/man/man1/wsgen.1)
sudo gzip $(readlink -f /usr/lib64/jdk_Oracle/man/man1/wsimport.1)
sudo gzip $(readlink -f /usr/lib64/jdk_Oracle/man/man1/xjc.1)

sudo /usr/sbin/update-alternatives --install /usr/bin/javac javac /usr/lib64/jdk_Oracle/bin/javac 3 \
--slave /usr/bin/appletviewer appletviewer /usr/lib64/jdk_Oracle/bin/appletviewer \
--slave /usr/share/man/man1/appletviewer.1.gz appletviewer.1.gz /usr/lib64/jdk_Oracle/man/man1/appletviewer.1.gz \
--slave /usr/bin/apt apt /usr/lib64/jdk_Oracle/bin/apt \
--slave /usr/share/man/man1/apt.1.gz apt.1.gz /usr/lib64/jdk_Oracle/man/man1/apt.1.gz \
--slave /usr/bin/extcheck extcheck /usr/lib64/jdk_Oracle/bin/extcheck \
--slave /usr/share/man/man1/extcheck.1.gz extcheck.1.gz /usr/lib64/jdk_Oracle/man/man1/extcheck.1.gz \
--slave /usr/bin/jar jar /usr/lib64/jdk_Oracle/bin/jar \
--slave /usr/share/man/man1/jar.1.gz jar.1.gz /usr/lib64/jdk_Oracle/man/man1/jar.1.gz \
--slave /usr/bin/jarsigner jarsigner /usr/lib64/jdk_Oracle/bin/jarsigner \
--slave /usr/share/man/man1/jarsigner.1.gz jarsigner.1.gz /usr/lib64/jdk_Oracle/man/man1/jarsigner.1.gz \
--slave /usr/lib64/jvm/java java_sdk /usr/lib64/jdk_Oracle \
--slave /usr/lib64/jvm-exports/java java_sdk_exports /usr/lib64/jvm-exports/jdk_Oracle \
--slave /usr/share/man/man1/javac.1.gz javac.1.gz /usr/lib64/jdk_Oracle/man/man1/javac.1.gz \
--slave /usr/bin/javadoc javadoc /usr/lib64/jdk_Oracle/bin/javadoc \
--slave /usr/share/man/man1/javadoc.1.gz javadoc.1.gz /usr/lib64/jdk_Oracle/man/man1/javadoc.1.gz \
--slave /usr/bin/javah javah /usr/lib64/jdk_Oracle/bin/javah \
--slave /usr/share/man/man1/javah.1.gz javah.1.gz /usr/lib64/jdk_Oracle/man/man1/javah.1.gz \
--slave /usr/bin/javap javap /usr/lib64/jdk_Oracle/bin/javap \
--slave /usr/share/man/man1/javap.1.gz javap.1.gz /usr/lib64/jdk_Oracle/man/man1/javap.1.gz \
--slave /usr/share/man/man1/jcmd.1.gz jcmd.1.gz /usr/lib64/jdk_Oracle/man/man1/jcmd.1.gz \
--slave /usr/bin/jconsole jconsole /usr/lib64/jdk_Oracle/bin/jconsole \
--slave /usr/share/man/man1/jconsole.1.gz jconsole.1.gz /usr/lib64/jdk_Oracle/man/man1/jconsole.1.gz \
--slave /usr/bin/jdb jdb /usr/lib64/jdk_Oracle/bin/jdb \
--slave /usr/share/man/man1/jdb.1.gz jdb.1.gz /usr/lib64/jdk_Oracle/man/man1/jdb.1.gz \
--slave /usr/bin/jhat jhat /usr/lib64/jdk_Oracle/bin/jhat \
--slave /usr/share/man/man1/jhat.1.gz jhat.1.gz /usr/lib64/jdk_Oracle/man/man1/jhat.1.gz \
--slave /usr/bin/jinfo jinfo /usr/lib64/jdk_Oracle/bin/jinfo \
--slave /usr/share/man/man1/jinfo.1.gz jinfo.1.gz /usr/lib64/jdk_Oracle/man/man1/jinfo.1.gz \
--slave /usr/bin/jmap jmap /usr/lib64/jdk_Oracle/bin/jmap \
--slave /usr/share/man/man1/jmap.1.gz jmap.1.gz /usr/lib64/jdk_Oracle/man/man1/jmap.1.gz \
--slave /usr/bin/jps jps /usr/lib64/jdk_Oracle/bin/jps \
--slave /usr/share/man/man1/jps.1.gz jps.1.gz /usr/lib64/jdk_Oracle/man/man1/jps.1.gz \
--slave /usr/bin/jrunscript jrunscript /usr/lib64/jdk_Oracle/bin/jrunscript \
--slave /usr/share/man/man1/jrunscript.1.gz jrunscript.1.gz /usr/lib64/jdk_Oracle/man/man1/jrunscript.1.gz \
--slave /usr/bin/jsadebugd jsadebugd /usr/lib64/jdk_Oracle/bin/jsadebugd \
--slave /usr/share/man/man1/jsadebugd.1.gz jsadebugd.1.gz /usr/lib64/jdk_Oracle/man/man1/jsadebugd.1.gz \
--slave /usr/bin/jstack jstack /usr/lib64/jdk_Oracle/bin/jstack \
--slave /usr/share/man/man1/jstack.1.gz jstack.1.gz /usr/lib64/jdk_Oracle/man/man1/jstack.1.gz \
--slave /usr/bin/jstat jstat /usr/lib64/jdk_Oracle/bin/jstat \
--slave /usr/share/man/man1/jstat.1.gz jstat.1.gz /usr/lib64/jdk_Oracle/man/man1/jstat.1.gz \
--slave /usr/bin/jstatd jstatd /usr/lib64/jdk_Oracle/bin/jstatd \
--slave /usr/share/man/man1/jstatd.1.gz jstatd.1.gz /usr/lib64/jdk_Oracle/man/man1/jstatd.1.gz \
--slave /usr/bin/native2ascii native2ascii /usr/lib64/jdk_Oracle/bin/native2ascii \
--slave /usr/share/man/man1/native2ascii.1.gz native2ascii.1.gz /usr/lib64/jdk_Oracle/man/man1/native2ascii.1.gz \
--slave /usr/bin/pack200 pack200 /usr/lib64/jdk_Oracle/bin/pack200 \
--slave /usr/share/man/man1/pack200.1.gz pack200.1.gz /usr/lib64/jdk_Oracle/man/man1/pack200.1.gz \
--slave /usr/bin/rmic rmic /usr/lib64/jdk_Oracle/bin/rmic \
--slave /usr/share/man/man1/rmic.1.gz rmic.1.gz /usr/lib64/jdk_Oracle/man/man1/rmic.1.gz \
--slave /usr/bin/schemagen schemagen /usr/lib64/jdk_Oracle/bin/schemagen \
--slave /usr/share/man/man1/schemagen.1.gz schemagen.1.gz /usr/lib64/jdk_Oracle/man/man1/schemagen.1.gz \
--slave /usr/bin/serialver serialver /usr/lib64/jdk_Oracle/bin/serialver \
--slave /usr/share/man/man1/serialver.1.gz serialver.1.gz /usr/lib64/jdk_Oracle/man/man1/serialver.1.gz \
--slave /usr/bin/unpack200 unpack200 /usr/lib64/jdk_Oracle/bin/unpack200 \
--slave /usr/share/man/man1/unpack200.1.gz unpack200.1.gz /usr/lib64/jdk_Oracle/man/man1/unpack200.1.gz \
--slave /usr/bin/wsgen wsgen /usr/lib64/jdk_Oracle/bin/wsgen \
--slave /usr/share/man/man1/wsgen.1.gz wsgen.1.gz /usr/lib64/jdk_Oracle/man/man1/wsgen.1.gz \
--slave /usr/bin/wsimport wsimport /usr/lib64/jdk_Oracle/bin/wsimport \
--slave /usr/share/man/man1/wsimport.1.gz wsimport.1.gz /usr/lib64/jdk_Oracle/man/man1/wsimport.1.gz \
--slave /usr/bin/xjc xjc /usr/lib64/jdk_Oracle/bin/xjc \
--slave /usr/share/man/man1/xjc.1.gz xjc.1.gz /usr/lib64/jdk_Oracle/man/man1/xjc.1.gz

#Web browser plug-in
sudo /usr/sbin/update-alternatives --install /usr/lib64/browser-plugins/javaplugin.so javaplugin /usr/lib64/jdk_Oracle/jre/lib/amd64/libnpjp2.so 3 --slave /usr/bin/javaws javaws /usr/lib64/jdk_Oracle/jre/bin/javaws --slave /usr/share/man/man1/javaws.1 javaws.1 /usr/lib64/jdk_Oracle/man/man1/javaws.1


sudo /usr/sbin/update-alternatives --config java
sudo /usr/sbin/update-alternatives --config javac
sudo /usr/sbin/update-alternatives --config javaplugin

sudo /usr/sbin/update-alternatives --install /usr/lib64/jvm/jre-1.7.0 jre_1.7.0 /usr/lib64/jdk_Oracle/jre 3 --slave /usr/lib64/jvm-exports/jre-1.7.0 jre_1.7.0_exports /usr/lib64/jvm-exports/jdk_Oracle
sudo /usr/sbin/update-alternatives --config jre_1.7.0

sudo /usr/sbin/update-alternatives --install /usr/lib64/jvm/java-1.7.0 java_sdk_1.7.0 /usr/lib64/jdk_Oracle 3 --slave /usr/lib64/jvm-exports/java-1.7.0 java_sdk_1.7.0_exports /usr/lib64/jvm-exports/jdk_Oracle
sudo /usr/sbin/update-alternatives --config java_sdk_1.7.0
```