title: redis-conf
date: 2015-06-30 17:49:02
tags: redis
category : redis
---
Redis is able to start without a configuration file using a built-in default configuration, however this setup is only recommended for testing and development purposes.
The proper way to configure Redis is by providing a Redis configuration file, usually called redis.conf.
The redis.conf file contains a number of directives that have a very simple format:`keyword argument1 argument2 ... argumentN`
It is possible to provide strings containing spaces as arguments using quotes, as in the following example:`requirepass "hello world"`
## Passing arguments via the command line
Since Redis 2.6 it is possible to also pass Redis configuration parameters using the command line directly. This is very useful for testing purposes. The following is an example that starts a new Redis instance using port 6380 as a slave of the instance running at 127.0.0.1 port 6379.

    ./redis-server --port 6380 --slaveof 127.0.0.1 6379
## Changing Redis configuration while the server is running
It is possible to reconfigure Redis on the fly without stopping and restarting the service, or querying the current configuration programmatically using the special commands [CONFIG SET][CONFIG SET] and [CONFIG GET][CONFIG GET]
Not all the configuration directives are supported in this way, but most are supported as expected. Please refer to the [CONFIG SET][CONFIG SET] and [CONFIG GET][CONFIG GET] pages for more information.
Note that modifying the configuration on the fly **has no effects on the redis.conf file** so at the next restart of Redis the old configuration will be used instead.
Make sure to also modify the redis.conf file accordingly to the configuration you set using [CONFIG SET][CONFIG SET]. There are plans to provide a [CONFIG REWRITE][CONFIG REWRITE] command that will be able to run the redis.conf file rewriting the configuration accordingly to the current server configuration, without modifying the comments and the structure of the current file.
<!--more-->
## Configuring Redis as a cache
If you plan to use Redis just as a cache where every key will have an expire set, you may consider using the following configuration instead (assuming a max memory limit of 2 megabytes as an example):

    maxmemory 2mb
    maxmemory-policy allkeys-lru
In this configuration there is no need for the application to set a time to live for keys using the [EXPIRE][EXPIRE] command (or equivalent) since all the keys will be evicted using an approximated LRU algorithm as long as we hit the 2 megabyte memory limit.
Basically in this configuration Redis acts in a similar way to memcached. We have more extensive documentation about [using Redis as an LRU cache][LRU cache].
## redis.conf(2.8)

### memory size

    # Note on units: when memory size is needed, it is possible to specify
    # it in the usual form of 1k 5GB 4M and so forth:
    #
    # 1k => 1000 bytes
    # 1kb => 1024 bytes
    # 1m => 1000000 bytes
    # 1mb => 1024*1024 bytes
    # 1g => 1000000000 bytes
    # 1gb => 1024*1024*1024 bytes
    #
    # units are case insensitive so 1GB 1Gb 1gB are all the same.

### includes

    # Include one or more other config files here.  This is useful if you
    # have a standard template that goes to all Redis servers but also need
    # to customize a few per-server settings.  Include files can include
    # other files, so use this wisely.
    #
    # Notice option "include" won't be rewritten by command "CONFIG REWRITE"
    # from admin or Redis Sentinel. Since Redis always uses the last processed
    # line as value of a configuration directive, you'd better put includes
    # at the beginning of this file to avoid overwriting config change at runtime.
    #
    # If instead you are interested in using includes to override configuration
    # options, it is better to use include as the last line.
    #
    # include /path/to/local.conf
    # include /path/to/other.conf
[CONFIG REWRITE][CONFIG REWRITE]只重写redis.conf file,所以
include at the beginning of conf file 中的property将**被覆盖**
include at the ending of conf file 中的property将**无法覆盖**

### GENERAL
    # By default Redis does not run as a daemon. Use 'yes' if you need it.
    # Note that Redis will write a pid file in /var/run/redis.pid when daemonized.
    daemonize no

    # When running daemonized, Redis writes a pid file in /var/run/redis.pid by
    # default. You can specify a custom pid file location here.
    pidfile /var/run/redis.pid

    # Accept connections on the specified port, default is 6379.
    # If port 0 is specified Redis will not listen on a TCP socket.
    port 6379

    # TCP listen() backlog.
    #
    # In high requests-per-second environments you need an high backlog in order
    # to avoid slow clients connections issues. Note that the Linux kernel
    # will silently truncate it to the value of /proc/sys/net/core/somaxconn so
    # make sure to raise both the value of somaxconn and tcp_max_syn_backlog
    # in order to get the desired effect.
    tcp-backlog 511

    # By default Redis listens for connections from all the network interfaces
    # available on the server. It is possible to listen to just one or multiple
    # interfaces using the "bind" configuration directive, followed by one or
    # more IP addresses.
    #
    # Examples:
    #
    # bind 192.168.1.100 10.0.0.1
    # bind 127.0.0.1

    # Specify the path for the Unix socket that will be used to listen for
    # incoming connections. There is no default, so Redis will not listen
    # on a unix socket when not specified.
    #
    # unixsocket /tmp/redis.sock
    # unixsocketperm 700

    # Close the connection after a client is idle for N seconds (0 to disable)
    timeout 0

    # TCP keepalive.
    #
    # If non-zero, use SO_KEEPALIVE to send TCP ACKs to clients in absence
    # of communication. This is useful for two reasons:
    #
    # 1) Detect dead peers.
    # 2) Take the connection alive from the point of view of network
    #    equipment in the middle.
    #
    # On Linux, the specified value (in seconds) is the period used to send ACKs.
    # Note that to close the connection the double of the time is needed.
    # On other kernels the period depends on the kernel configuration.
    #
    # A reasonable value for this option is 60 seconds.
    tcp-keepalive 0

    # Specify the server verbosity level.
    # This can be one of:
    # `debug` (a lot of information, useful for development/testing)
    # `verbose` (many rarely useful info, but not a mess like the debug level)
    # `notice` (moderately verbose, what you want in production probably)
    # `warning` (only very important / critical messages are logged)
    loglevel notice

    # Specify the log file name. Also the empty string can be used to force
    # Redis to log on the standard output. Note that if you use standard
    # output for logging but daemonize, logs will be sent to /dev/null
    logfile ""

    # To enable logging to the system logger, just set 'syslog-enabled' to yes,
    # and optionally update the other syslog parameters to suit your needs.
    # syslog-enabled no

    # Specify the syslog identity.
    # syslog-ident redis

    # Specify the syslog facility. Must be USER or between LOCAL0-LOCAL7.
    # syslog-facility local0

    # Set the number of databases. The default database is DB 0, you can select
    # a different one on a per-connection basis using SELECT <dbid> where
    # dbid is a number between 0 and 'databases'-1
    databases 16
[bind ip][bind ip]
[IPC][IPC]

## copy from
+ [config][config]
+ [redis.conf][redis.conf]

[CONFIG SET]: http://redis.io/commands/config-set
[CONFIG GET]: http://redis.io/commands/config-get
[CONFIG REWRITE]: http://redis.io/commands/config-rewrite
[EXPIRE]: http://redis.io/commands/expire
[LRU cache]: http://redis.io/topics/lru-cache
[config]: http://redis.io/topics/config
[redis.conf]: https://raw.githubusercontent.com/antirez/redis/2.8/redis.conf
[bind ip]: http://www.cnblogs.com/nightwatcher/archive/2011/07/03/2096717.html
[IPC]: http://blog.csdn.net/guxch/article/details/7041052
