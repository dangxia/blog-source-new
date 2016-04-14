---
layout: post
title: "eclipse mirror"
date: 2014-05-25 20:18:15 +0800
comments: true
categories: eclipse
---
##使用mirror更新eclipse插件
+	####修改hosts	
127.0.0.1  download.eclipse.org
+	####运行代理服务	
```javascript nodejs代理
var http = require('http');
http.createServer(function (request, response) {
	console.log(request.method + '\t' + request.url);
	response.writeHead(302, {
		'Location': 'http://mirror.bit.edu.cn/eclipse'+request.url
	});
	response.end();
}).listen(80);
```
