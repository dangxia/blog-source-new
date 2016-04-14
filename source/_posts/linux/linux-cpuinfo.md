title: linux-cpuinfo
date: 2015-10-29 17:11:49
tags: [linux]
---
### cpu
+ processor 逻辑处理器的唯一标识符。
+ physical id 每个物理封装的唯一标识符。
+ siblings 相同物理封装中的逻辑处理器的数量。
+ cpu cores 相同物理封装中的内核数量。
+ core id 每个内核的唯一标识符。

1. 拥有相同 physical id 的所有逻辑处理器共享同一个物理插座。每个 physical id 代表一个唯一的物理封装。
2. Siblings 表示位于这一物理封装上的逻辑处理器的数量。它们可能支持也可能不支持超线程（HT）技术。
3. 每个 core id 均代表一个唯一的处理器内核。所有带有相同 core id 的逻辑处理器均位于同一个处理器内核上。
4. 如果有一个以上逻辑处理器拥有相同的 core id 和 physical id，则说明系统支持超线程（HT）技术。
5. 如果有两个或两个以上的逻辑处理器拥有相同的 physical id，但是 core id 不同，则说明这是一个多内核处理器。cpu cores 条目也可以表示是否支持多内核。

```ssh
echo "logical CPU number:"
#逻辑CPU个数
cat /proc/cpuinfo | grep "processor" | wc -l
 
echo "physical CPU number:"
#物理CPU个数：
cat /proc/cpuinfo | grep "physical id" | sort -u | wc -l
 
echo "core number in a physical CPU:"
#每个物理CPU中Core的个数：
cat /proc/cpuinfo | grep "cpu cores" | uniq | awk -F: '{print $2}'
#查看core id的数量,即为所有物理CPU上的core的个数
cat /proc/cpuinfo | grep "core id" | uniq |  wc -l
 
#是否为超线程？
#如果有两个逻辑CPU具有相同的”core id”，那么超线程是打开的。或者siblings数目比cpu cores数目大。
#每个物理CPU中逻辑CPU(可能是core, threads或both)的个数：
cat /proc/cpuinfo | grep "siblings"
```

判断CPU是否64位，检查cpuinfo中的flags区段，看是否有lm标识。
Are the processors 64-bit?   
A 64-bit processor will have lm ("long mode") in the flags section of cpuinfo. A 32-bit processor will not.

or 

`lscpu`


### disk
df -h --total
查看硬盘和分区分布:lsblk
硬盘和分区的详细信息:fdisk -l

### mem

cat /proc/meminfo

free -m
