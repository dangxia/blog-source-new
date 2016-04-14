---
layout: post
title: "消息的可靠处理"
date: 2014-05-25 19:07:17 +0800
comments: true
categories: storm
---
+	###参考	
	http://blog.linezing.com/?p=1898
+	###ack	
	+	IBasicBolt会自动ack
	+	IRichBolt需要手动ack,当使用啦IRichBolt而忘记啦ack时，Config.TOPOLOGY_MESSAGE_TIMEOUT_SECS 时间后，Spout的fail会被调用
+	###锚定	
	+	IBasicBolt会自动锚定
	+	IRichBolt需要手动锚定
+	###关闭可靠性	
	+	将参数Config.TOPOLOGY_ACKERS设置为0，通过此方法，当Spout发送一个消息的时候，它的ack方法将立刻被调用；
	+	Spout发送一个消息时，不指定此消息的messageID。当需要关闭特定消息可靠性的时候，可以使用此方法；
	+	如果你不在意某个消息派生出来的子孙消息的可靠性，则此消息派生出来的子消息在发送时不要做锚定，即在emit方法中不指定输入消息。因为这些子孙消息没有被锚定在任何tuple tree中，因此他们的失败不会引起任何spout重新发送消息。
+	###相关	
	开启可靠性后TOPOLOGY_MAX_SPOUT_PENDING才会有效
