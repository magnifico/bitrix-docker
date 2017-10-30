#!/bin/bash -e

chown -R redis:redis /etc/redis /var/lib/redis

gosu redis /usr/bin/redis-server /etc/redis/redis.conf
