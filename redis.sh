#!/bin/sh
#
# Script to start/stop a Redis instance as Master/Slave
#
# (c) Alex Williams - 2009 - www.alexwilliams.ca
#
# v0.1
#
# Usage Options:
#   -m    start redis-server as a MASTER
#   -s    start redis-server as a SLAVE
#   -k    stop all redis-servers
#
# Redis Setup:
#
#   useradd -m -U redis
#   chmod 750 /home/redis
#   echo "172.16.0.180    dbwrite-pool-1" >> /etc/hosts
#
# Configurations:
#
#   Master config: /home/redis/redis-mdb.conf (runs on port 6379)
#   Slave config:  /home/redis/redis-mdbslave.conf (runs on port 6380)
#
# How it works:
#
#   - Keepalived runs on the Redis Master and Slave servers
#   - The Redis Master binds the IP 172.16.0.180
#   - The Redis Slave connects to a Master server which has the IP 172.16.0.180
#   - Keepalived handles checking and runs a script if a server is online or offline
#   - This script will handle starting/stopping the Redis instance as a Master/Slave
#
# Note:
#
#   *This has NOT been tested in a production environment, use at your own risk*
#
###############

        
#########################
# User Defined Variables
#########################

REDIS_HOME="/home/redis"
REDIS_COMMANDS="/home/redis/redis-1.02/src"     # The location of the redis binary
REDIS_MASTER_PORT="6379"                        # Redis MASTER port
REDIS_MASTER_CONF="redis-mdb.conf"              # Filename of MASTER config
REDIS_SLAVE_PORT="6380"                         # Redis SLAVE port
REDIS_SLAVE_CONF="redis-mdbslave.conf"          # Filename of SLAVE config

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

start_master() {
        kill_redis
        wait
        ${REDIS_COMMANDS}/redis-server ${REDIS_HOME}/${REDIS_MASTER_CONF}
}

start_slave() {
        kill_redis
        wait
        ${REDIS_COMMANDS}/redis-server ${REDIS_HOME}/${REDIS_SLAVE_CONF}
}

kill_redis() {
        #${REDIS_COMMANDS}/redis-cli -p ${REDIS_MASTER_PORT} shutdown
        #${REDIS_COMMANDS}/redis-cli -p ${REDIS_SLAVE_PORT} shutdown
        killall -9 redis-server
}

usage() {
        echo -e "Start/Stop Redis Instances - version 0.1 (c) Alex Williams - www.alexwilliams.ca"
        echo -e "\nOptions: "
        echo -e "\t-m\tstart redis-server as a MASTER"
        echo -e "\t-s\tstart redis-server as a SLAVE"
        echo -e "\t-k\tstop all redis-servers"
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
        echo -e "Starting redis-server as a MASTER\n"
        start_master
elif [ $arg_s ]; then
        echo -e "Starting redis-server as a SLAVE\n"
        start_slave
elif [ $arg_k ]; then
        echo -e "Killing all redis-servers\n"
        kill_redis
else
        usage
fi