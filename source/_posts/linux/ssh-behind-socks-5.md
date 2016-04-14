title: ssh behind socks 5
date: 2015-06-30 17:29:01
tags: linux
---
## nc
```
ssh -o 'ProxyCommand nc -x xxx.xxx.xxx.xxx:1080 -X 5 -Pruser %h %p' root@xxx.xxx.xxx.xxx
```
-X 5 socks version 5
-P ruser proxy username
-x proxy_host|proxy:port

[nc help1](http://www.computerhope.com/unix/nc.htm)
[nc help2](https://en.wikibooks.org/wiki/OpenSSH/Cookbook/Proxies_and_Jump_Hosts)
>报错nc: authentication method negotiation failed
未找到原因

## corkscrew
[corkscrew](http://wiki.kartbuilding.net/index.php/Corkscrew_-_ssh_over_https)只支持http(s)，未尝试。
<!--more-->

## xshell
最终使用crossover+xshell配置proxy (**记得xshell的输入为UTF-8,不然键盘不能输入**)
