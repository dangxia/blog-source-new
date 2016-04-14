---
layout: post
title: "hibernate spring"
date: 2013-10-10 11:28:12 +0800
category : hibernate
---

###When using spring and spring managed transactions never mess around with the 'hibernate.current_session_context_class' UNLESS you are using JTA.

Spring will by default set its own CurrentSessionContext implementation (the SpringSessionContext), however if you set it yourself this will not be the case. Basically breaking proper transaction integration.

The only reason for chancing this setting is if you want to use JTA managed transactions, then you have to setup this to properly integrate with JTA.


<!--more-->





