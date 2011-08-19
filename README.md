## Usage Options:
-   -m    start redis-server as a MASTER
-   -s    start redis-server as a SLAVE
-   -k    stop all redis-servers

## Tested:

- Redis 1.02
- Keepalived 1.1.19

## Redis Setup:

    useradd -m -U redis
    chmod 750 /home/redis

## Configurations:

- Master config: /home/redis/redis-mdb.conf (runs on port 6379)
- Slave config:  /home/redis/redis-mdbslave.conf (runs on port 6380)

## How it works:

- Keepalived runs on the Redis Master and Slave servers
- The Redis Master binds the IP 172.16.0.180
- The Redis Slave connects to a Master server which has the IP 172.16.0.180
- Keepalived handles checking and runs a script if a server is online or offline
- This script will handle starting/stopping the Redis instance as a Master/Slave

## Note:

*This has NOT been tested in a production environment, use at your own risk*