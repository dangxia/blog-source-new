title: install nodejs in openSUSE 13.1
date: 2014-10-28 15:43:40
tags: [nodejs,hexo]
---
##install nodejs in openSUSE
```sh
sudo zypper ar http://download.opensuse.org/repositories/devel:/languages:/nodejs/openSUSE_13.1/devel:languages:nodejs.repo
sudo zypper refresh
sudo zypper instal nodejs npm
```

##install hexo and init folder
```sh
npm install hexo -g
hexo init blog
cd blog
npm install
hexo server
```