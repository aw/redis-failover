## Usage Options:
-   -m    promote the redis-server to MASTER
-   -s    promote the redis-server to SLAVE
-   -k    start the redis-server and promote it to MASTER

## Tested:

- Redis 2.2.12
- Keepalived 1.1.20

## Redis Setup:

    useradd -m -U redis
    chmod 750 /home/redis
    cd /home/redis
    sudo -u redis git clone https://github.com/antirez/redis.git redis.git
    cd redis.git
    git checkout 2.2.12
    sudo make

## Configurations:

- MASTER/SLAVE config: /home/redis/redis-mdb.conf (runs on port 6379)

## How it works:

- Keepalived runs on the Redis MASTER and SLAVE servers
- The Redis MASTER binds the IP 172.16.0.180
- The Redis SLAVE connects to a Master server which has the IP 172.16.0.180
- Keepalived handles checking and runs a script if a server is online or offline
- This script will handle starting Redis promoting it to MASTER or SLAVE

## Note:

*This has NOT been tested in a production environment, use at your own risk*

## Copyright

Copyright (c) 2011 Alex Williams. See LICENSE for details.
