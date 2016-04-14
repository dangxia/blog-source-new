title: update opensuse repos
date: 2015-01-06 19:42:50
tags: [opensuse]
---
```ssh		
#/bin/bash
sudo zypper ar -t yast2 -c -n openSUSE-13.1-Non-Oss-Mirror -k -g -f http://mirrors.ustc.edu.cn/opensuse/distribution/13.2/repo/non-oss/ repo-non-oss-mirror
sudo zypper ar -t yast2 -c -n openSUSE-13.1-Oss-Mirror -k -g -f http://mirrors.ustc.edu.cn/opensuse/distribution/13.2/repo/oss/ repo-oss-mirror
sudo zypper mr -d -R repo-non-oss
sudo zypper mr -d -R repo-oss

sudo zypper ar -t rpm-md -c -n openSUSE-13.1-Update-Mirror -k -g -f http://mirrors.ustc.edu.cn/opensuse/update/13.2/ repo-update-mirror
sudo zypper ar -t rpm-md -c -n openSUSE-13.1-Update-Non-Oss-Mirror -k -g -f http://mirrors.ustc.edu.cn/opensuse/update/13.2-non-oss/ repo-update-non-oss-mirror

sudo zypper mr -d -R repo-update
sudo zypper mr -d -R repo-update-non-oss

sudo zypper ar -f http://mirrors.hust.edu.cn/packman/suse/openSUSE_13.2/ packman
sudo zypper ar -f http://opensuse-guide.org/repo/13.2/ libdvdcss
sudo zypper ref		
```