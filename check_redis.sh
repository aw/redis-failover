#!/bin/bash
#
# This script checks if a Redis server is healthy running on localhost. It will
# return:
#
# "HTTP/1.x 200 OK\r" (if Redis is running smoothly)
#
# - OR -
#
# "HTTP/1.1 503 Service Unavailable\r"
#
# The purpose of this script is make haproxy capable of monitoring Redis properly
#
# Original Author: Unai Rodriguez
#
# Script modified by Alex Williams - August 4, 2009
#       - removed the need to write to a tmp file, instead store results in memory
#
# Script modified by Alex Williams - October 28, 2011
#	- monitor Redis instead of MySQL (original script)

REDIS_HOME="/home/redis"
REDIS_COMMANDS="/home/redis/redis.git/src"      # The location of the redis binary
REDIS_MASTER_IP="172.16.0.180"                  # Redis MASTER ip
REDIS_MASTER_PORT="6379"                        # Redis MASTER port

#
# We perform a simple query that should return a few results :-p

ERROR_MSG=`${REDIS_COMMANDS}/redis-cli PING`

#
# Check the output for PONG.
#
if [ "$ERROR_MSG" != "PONG" ]
then
        # redis is down, return http 503
        /bin/echo -e "HTTP/1.1 503 Service Unavailable\r\n"
        /bin/echo -e "Content-Type: Content-Type: text/plain\r\n"
        /bin/echo -e "\r\n"
        /bin/echo -e "Redis is *down*.\r\n"
        /bin/echo -e "\r\n"
else
        # redis is fine, return http 200
        /bin/echo -e "HTTP/1.1 200 OK\r\n"
        /bin/echo -e "Content-Type: Content-Type: text/plain\r\n"
        /bin/echo -e "\r\n"
        /bin/echo -e "Redis is running.\r\n"
        /bin/echo -e "\r\n"
fi
