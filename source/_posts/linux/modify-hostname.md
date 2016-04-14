title: modify hostname
date: 2015-10-26 12:16:19
tags: linux
categories: linux
---
### modify hostname
+ uname -a 查看hostname
+ hostname xxxxx 修改下，让hostname立刻生效。
+ vi /etc/hosts 修改原hostname为 xxxxx
+ vi  /etc/sysconfig/network 修改原hostname为 xxxxx,这样可以让reboot重启后也生效
+ reboot重启，uname -a 重新检查下。收工

### reverse mapping checking getaddrinfo POSSIBLE BREAK-IN ATTEMPT
[Resolution](https://access.redhat.com/solutions/83933)
+ Setup a [Reverse DNS Record (aka PTR Record)][1] for the SSH client
+ Ensure UseDNS no and GSSAPIAuthentication no are set in /etc/ssh/sshd_config on the SSH server, then restart the sshd
+ Confirm that /etc/hosts on the SSH server has an entry for the SSH client IP address and hostname

[1]: https://access.redhat.com/site/documentation/en-US/Red_Hat_Enterprise_Linux/5/html/Deployment_Guide/s2-bind-configuration-zone-reverse.html

