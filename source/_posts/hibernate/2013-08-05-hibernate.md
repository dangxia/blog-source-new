---
layout: post
title: "hibernate"
date: 2013-08-05 11:28:12 +0800
category : hibernate
---

###关联
>\@OneToMany  mappedBy
>@ManyToOne 默认fetch:EAGER  @JoinColumn
>hibernate 自动建表的关联一般是外键，但实际表结构不一定是外键
###删除 
>建议先load后删除，方便使用CascadeType.REMOVE
###load get
>load方式检索不到的话会抛出org.hibernate.ObjectNotFoundException异常
>get方法检索不到的话会返回null
###a different object with the same identifier value was already associated with the session
	session.clean()
	session.refresh(object)
	session.merge(object)
### megre
>megre 可能也更新关联的对象
###Arraytest
+ 当关联的不是entity对象时可以用@ElementCollection
+ *@ElementCollection*关联的是enmu时，默认是tinyint,可以使用@Enumerated(EnumType.STRING)在表中用字符
+ 当你的Enum中有自定义字段，并且你希望用该字段作为hibernate持久化的值的时候，就需要用到hibernate的自定义映射类型UserType
+ 有序的对象可以使用@OrderColumn,@IndexColumn
+ *@CollectionId*可以给*@ElementCollection*添加ID
###@IdClass
+ pk可以是关联对象的字段,可应通过@IdClass引用
+ *@ID* 可以加在@ManyToOne等上面
+ *@MapsId* 在@EmbeddedId中启到相同的作用  也可以使用@JoinColumns
+ *SimpleParentEmbedded*可以不用@IdClass
###CascadeTest
+ DETACH对应缓存的数据的删除等。
###时间
+ *@Temporal*指定是Date,Time,Timestamp
###@Basic
+ 默认的为@Basic
###@Parent
+ IdClass可以用@Parent引用owner
###@XXXToOne
+ 默认@JoinColumn id attribute mapped by join column default
###继承
+ 查询@org.hibernate.annotations.Entity(polymorphisms = PolymorphismType.EXPLICIT)
+ 或者Restrictions.eq("class", A.class)
###left join
+ createAlias("menus", "menus", Criteria.LEFT_JOIN)
###其他
+ [man](http://www.mkyong.com/hibernate/hibernate-fetching-strategies-examples)
+ [JPA注解](http://www.360doc.com/content/07/1224/21/15643_921681.shtml)


<!--more-->





