#!/bin/bash
ps -ef|grep hexo|grep -v grep|cut -c 9-15|xargs kill
