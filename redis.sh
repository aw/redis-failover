#!/bin/sh
#
# Script to start Redis and promote to MASTER/SLAVE
#
# Copyright (c) 2011 Alex Williams. See LICENSE for details.
#
# v0.3
#
# Usage Options:
#   -m    promote the redis-server to MASTER
#   -s    promote the redis-server to SLAVE
#   -k    start the redis-server and promote it to MASTER
#
# Tested:
#
#   - Redis 2.2.12
#   - Keepalived 1.1.20
#
# Redis Setup:
#
#   useradd -m -U redis
#   chmod 750 /home/redis
#   cd /home/redis
#   sudo -u redis git clone https://github.com/antirez/redis.git redis.git
#   cd redis.git
#   git checkout 2.2.12
#   sudo make
#
# Configurations:
#
#   MASTER/SLAVE config: /home/redis/redis-mdb.conf (runs on port 6379)
#
# How it works:
#
#   - Keepalived runs on the Redis MASTER and SLAVE servers
#   - The Redis MASTER binds the IP 172.16.0.180
#   - The Redis SLAVE connects to a Master server which has the IP 172.16.0.180
#   - Keepalived handles checking and runs a script if a server is online or offline
#   - This script will handle starting Redis promoting it to MASTER or SLAVE
#
# Note:
#
#   *This has NOT been tested in a production environment, use at your own risk*

#########################
# User Defined Variables
#########################

REDIS_HOME="/home/redis"
REDIS_COMMANDS="/home/redis/redis.git/src"      # The location of the redis binary
REDIS_MASTER_IP="172.16.0.180"                  # Redis MASTER ip
REDIS_MASTER_PORT="6379"                        # Redis MASTER port
REDIS_CONF="redis-mdb.conf"                     # Filename of MASTER config

##############
# Exit Codes
##############

E_INVALID_ARGS=65
E_INVALID_COMMAND=66
E_NO_SLAVES=67
E_DB_PROBLEM=68

##########################
# Script Functions
##########################

error() {
        E_CODE=$?
        echo "Exiting: ERROR ${E_CODE}: $E_MSG"

        exit $E_CODE
}

start_redis() {
      alive=`${REDIS_COMMANDS}/redis-cli PING`
      if [ "$alive" != "PONG" ]; then
        ${REDIS_COMMANDS}/redis-server ${REDIS_HOME}/${REDIS_CONF}
        sleep 1
      fi
}

start_master() {
        ${REDIS_COMMANDS}/redis-cli SLAVEOF no one
}

start_slave() {
        ${REDIS_COMMANDS}/redis-cli SLAVEOF ${REDIS_MASTER_IP} ${REDIS_MASTER_PORT}
}

usage() {
        echo -e "Start Redis and promote to MASTER/SLAVE - version 0.3 (c) Alex Williams - www.alexwilliams.ca"
        echo -e "\nOptions: "
        echo -e "\t-m\tpromote the redis-server to MASTER"
        echo -e "\t-s\tpromote the redis-server to SLAVE"
        echo -e "\t-k\tstart the redis-server and promote it to MASTER"
        echo -e ""

        exit $E_INVALID_ARGS
}

for arg in "$@"
do
        case $arg in
        -m) arg_m=true;;
        -s) arg_s=true;;
        -k) arg_k=true;;
        *) usage;;
        esac
done

if [ $arg_m ]; then
        echo -e "Promoting redis-server to MASTER\n"
        start_redis
        wait
        start_master
elif [ $arg_s ]; then
        echo -e "Promoting redis-server to SLAVE\n"
        start_redis
        wait
        start_slave
elif [ $arg_k ]; then
        echo -e "Starting redis-server and promoting to MASTER\n"
        start_redis
        wait
        start_master
else
        usage
fi
