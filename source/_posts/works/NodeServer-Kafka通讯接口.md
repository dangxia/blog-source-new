title: NodeServer Kafka通讯接口
date: 2014-11-05 17:41:54
---
##	前言
**********************
Node Server 主要是动态记录各流媒体服务器的网络流量信息，并提供短信和MAIL报警功能，详见《NodeServer系统V1.1设计说明书》
Node Server 向Kafka发送部分流媒体采集的信息，以便统计平台分析用户的行为和状态。

##	目的
**********************
本文档为Node Server 向Kafka发送部分流媒体采集的信息提供协议规范。

##	格式
**********************
协议的字段用制表符(\t)分隔

## 字段
**********************
|字段名                |字节数              |类型     |描述                                                              |
|------------------|:---------------:|-------:|--------------------------------------------------------:|
|STBID               |--                  |String   |机顶盒号，从终端访问URL的Authinfo防盗链信息中提取                           |
|STBIP               |--                  |String  |终端IP地址                                                   |
|UserAgent           |4                   |Uint32  |终端类型                                                     |
|CMSID               |--                  |String  |内容对应的CMSID                                               |
|ContentID           |32                  |String  |内容对应的ContentID(介质的ID=>fid)                             |
|RelativeUrl         |--                  |String  |终端请求内容的相对URL，包括URL中携带的参数                                 |
|ServiceType         |2                   |Uint16  |服务类型（直播/点播）。取值：00（点播），01（直播），02（回看），03-99（其他）            |
|bitrate             |4                   |Uint32  |内容码率，单位为Kbps。HLS等多码率内容情况下填写当前内容各个Profile的码率的总和。          |
|BeginTime           |--                  |String  |点播开始时间                                                   |
|EndTime             |--                  |String  |点播结束时间                                                   |
|volume              |8                   |Uint64  |点播发生流量，单位KB。                                             |
|transactionID       |--                  |String  |服务器提供服务的会话号                                              |
|VSSIP               |--                  |String  |流媒体IP                          |
|nodeServerIP        |--                  |String  |node server IP                          |

