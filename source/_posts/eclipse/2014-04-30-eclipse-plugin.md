---
layout: post
title: "eclipse plugin"
date: 2014-04-30 15:00:12 +0800
category : eclipse
---
[galileo-install-plug-ins-into-eclipse-ide]:http://ekkescorner.wordpress.com/2009/06/27/galileo-install-plug-ins-into-eclipse-ide/
[following-eclipse-milestones]:http://www.peterfriese.de/following-eclipse-milestones/
+	### install plugins	
参考[galileo-install-plug-ins-into-eclipse-ide][]
+	### share plugins	
setting your eclipse.ini -Dorg.eclipse.equinox.p2.reconciler.dropins.directory=C:/jv/eclipse/mydropins
+	### install Plug-ins from old Eclipse Installations	
参考[following-eclipse-milestones][]	
using the file chooser, browse to <OLD_ECLIPSE_PATH>/eclipse/p2/org.eclipse.equinox.p2.engine/profileRegistry/SDKProfile.profile/ 	
and click Choose to select that directory
+	### disable a plugin	
Some plugins allow controlling their load-on-startup behavior. These will be listed in the preferences, under General → Startup and Shutdown. If the plugin provides view, you will need to close those views (in all perspectives) for this to work.
<!-- more -->



