---
layout: post
title: "grub4dos install win7 and ubuntu"
date: 2014-04-30 16:30:21 +0800
comments: true
categories: grub4dos
---
[imdisk_home]:http://dl.dropbox.com/u/3141121/Grub4Dos/imdisk.7z
[config_home]:http://download.sysinternals.com/Files/Contig.zip
+	###写引导区	
使用bootice写引导区
+	###tools	
	+	[ImDisk Virtual Disk Driver][imdisk_home]	
		imdisk是用来解决安装win7时找不到安装文件。虚拟win.iso=>CD_ROM
	+	[Config][config_home]	
		grub4dos - map /iso/cn_windows_7_ultimate_with_sp1_x64_dvd_u_677408.iso (hd32)	
		需要iso在disk上连续存放  	
		**BUG:Config -s  xx.iso 命令时会提示找不到文件，可改成Config -s xx.iso\***
		------------
		map --mem /iso/cn_windows_7_ultimate_with_sp1_x64_dvd_u_677408.iso (hd32)	
		不会存在文件连续存放的问题,但需要内存足够大
+	###win7安装	
	进入选择语言界面时，`Shift + F10` 进入cmd
```
Microsoft Windows  [版本 6.1.7600]

X:\Sources>pushd K:\imdisk

k:\imdisk>SetupImDisk.CMD

k:\imdisk>SetupCDROM.CMD path_to_win7_iso

k:\imdisk>
```
其他同CD安装	
<!--more-->

+	###编写menu.lst	
```bash menu.lst
graphicsmode -1 640:800 480:600 24:32
font /unifont.hex.gz

title install lubuntu-14.04-desktop-amd64.iso
root (hd0,0)
map /iso/lubuntu-14.04-desktop-amd64.iso (hd32)
map --hook
map --status
kernel (hd32)/casper/vmlinuz.efi iso-scan/filename=/iso/lubuntu-14.04-desktop-amd64.iso file=/cdrom/preseed/lubuntu.seed locale=zh_CN.UTF-8 ro boot=casper noprompt quiet splash --
initrd (hd32)/casper/initrd.lz
map --unhook
boot


title install cn_windows_7_ultimate_with_sp1_x64_dvd_u_677408.iso
map (hd1) (hd0)
map (hd0) (hd1)
find --set-root /iso/cn_windows_7_ultimate_with_sp1_x64_dvd_u_677408.iso
map /iso/cn_windows_7_ultimate_with_sp1_x64_dvd_u_677408.iso (hd32)
map --hook
chainloader (hd32)
boot

title reboot
reboot

title shutdown
halt
```

+	###注意事项	
	+	vmlinuz		
不同的ubuntu版本，可能时vmlinuz或vmlinuz.efi	
preseed/lubuntu.seed同样要注意
	+	map		
usb加载完后，默认hd0,root是U盘	
安装WIN7时需要map (hd1) (hd0) map (hd0) (hd1)把hd0指向harddisk	
map --hook使map操作生效	

+	###附件:	
[unifont.hex.gz][],[SetupImDisk.CMD][],[SetupCDROM.CMD][]

+	###参考:	
http://fireball-catcher.blogspot.com/2012/07/grub4dos.html	
http://www.iteedu.com//os/grub/grub4doscmds/index.php	
http://bbs.wuyou.net/forum.php?mod=viewthread&tid=322662	

[unifont.hex.gz]:/assets/fonts/unifont.hex.gz
[SetupCDROM.CMD]:/assets/cmd/SetupCDROM.CMD
[SetupImDisk.CMD]:/assets/cmd/SetupImDisk.CMD
