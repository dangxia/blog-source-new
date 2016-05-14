---
layout: "post"
title: "chrome-redirector"
date: "2016-04-15 23:34"
category: chrome
---

### 起因
`https://github-atom-io-herokuapp-com.global.ssl.fastly.net/assets/application-ba07c5c2889a34307a4b7d49410451d9.css`
不能使用`https`访问，使用[chrome-redirector][1](商店已经下架，以防万一，已经备份了一个到百度云盘)重定向到`http`

```
Refused to load the script 'http://github-atom-io-herokuapp-com.global.ssl.fastly.net/assets/application-3db62b578ebfc39ee871abc91b175302.js'
because it violates the following Content Security Policy directive: "script-src 'self' 'unsafe-inline'
https://ssl.google-analytics.com
https://www.google-analytics.com
https://platform.twitter.com https://github-atom-io-herokuapp-com.global.ssl.fastly.net".
```
<!-- more -->
由于[CSP][2],chrome报错，进而又安装了plugin:[Disable Content-Security-Policy][3],[正确的web解决方法][6]

可是仍然报错:
```
Mixed Content: The page at 'https://atom.io/' was loaded over HTTPS,
but requested an insecure stylesheet
'http://github-atom-io-herokuapp-com.global.ssl.fastly.net/assets/application-ba07c5c2889a34307a4b7d49410451d9.css'.
This request has been blocked; the content must be served over HTTPS.
```
chrome URL的最右边，容许加载不安全的脚本。以下参照[Enabling mixed content in Google Chrome][4],[How to allow Chrome (browser) to load insecure content?][5]
1. Click the alert shield icon in the address bar.
2. In the icon dialog box, click Load anyway.
3. The site will reload; if within ANGEL, users will be returned to the course homepage.
4. Upon returning to the page or link in question, the content will now be visible.
5. 补充一下，浏览器重启后失效

### rules

[1]:https://github.com/chrome-redirector/chrome-redirector
[2]:http://content-security-policy.com/
[3]:https://chrome.google.com/webstore/detail/disable-content-security/ieelmcmcagommplceebfedjlakkhpden/related
[4]:http://wiki.sln.suny.edu/display/SLNKB/Enabling+mixed+content+in+Google+Chrome
[5]:http://superuser.com/questions/487748/how-to-allow-chrome-browser-to-load-insecure-content
[6]:http://magento.stackexchange.com/questions/74121/how-to-stop-redirect-loading-of-insecure-scripts
