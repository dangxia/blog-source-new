---
layout: post
title: "hibernate-id-accessType"
date: 2013-08-06 11:28:12 +0800
category : hibernate
---

###@Id
>一般使用GenerationType.AUTO即可。
	GenerationType.AUTO - identity, sequence, or hilo
	GenerationType.IDENTITY - MS SQL Server, MySQL
	GenerationType.SEQUENCE - Oracle
```java
@Id
@GeneratedValue(strategy = GenerationType.AUTO)
@Column(name = "...")
private Long getId() {
	return id;
}
```
###@AccessType
Hibernate存取Domain object的数据有两种方式，一是透过getter与setter method（access by property），二是直接存取field（access by field），通常是建议使用前者，有封装的作用。

在Hibernate Annotation中决定存取方式的规则如下：

+ 若设有@AccessType，则采用@AccessType之配置。
+ 不然则以@Id所在的位置决定，若@Id在property上，则采用access by property，若@Id在field上，则采用access by field。
+ *@AccessType*可放在class、field或property上，在class上表示配置为class level，整个class套用，在field或property上则为attribute level，仅该attribute（property或field）适用。

不管是透过@AccessType配置或@Id所在位置决定，若class配置为access by property，要变更特定的attribute为access by field时，必须将@AccessType(“field”)放在getter method上。

不管是透过@AccessType配置或@Id所在位置决定，若class配置为access by field，要变更特定的attribute为access by property时，必须将@AccessType(“property”)放在field上。

最后，@Embedded与@MappedSuperclass的存取规则均同于owning/inherited entity。


<!--more-->







