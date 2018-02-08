# cassandra-docker

Simple Docker Image for Cassandra. cassandra-docker provides utilities to create clusters.

## Linux: How to use it? (native)

1. Download and install Docker. -> https://docs.docker.com/engine/installation/
2. Bake docker images $ ./cassandra-docker.sh bake
3. Create the Cassandra cluster $ ./cassandra-docker.sh run 3.9

## Windows/Mac: How to use it?

#### (MAC) Docker (Require changes on bash script)

1. Install docker -> https://docs.docker.com/docker-for-mac/install/
2. (just 1 time) Bake docker images $ sudo ./cassandra-docker-mac.sh bake
3. Create the Cassandra cluster $ sudo ./cassandra-docker-mac.sh run 3.9

## What cassandra versions are suppoorted?

* 2.1.19 <BR>
* 3.9    <BR>

## What parameters can I use?

```bash
$ ./cassandra-docker.sh help
 #####                             ######                                     
#     #   ##    ####   ####        #     #  ####   ####  #    # ###### #####   
#        #  #  #      #            #     # #    # #    # #   #  #      #    #  
#       #    #  ####   ####  ##### #     # #    # #      ####   #####  #    #  
#       ######      #      #       #     # #    # #      #  #   #      #####   
#     # #    # #    # #    #       #     # #    # #    # #   #  #      #   #   
 #####  #    #  ####   ####        ######   ####   ####  #    # ###### #    #   

cassandra-docker: Easy setup for cassandra cluster(2.1 & 3.9) for development. Created by: Diego Pacheco.
functions:

bake        : Bakes docker image
run         : Run cassandra docker cluster. i.e: ./cassandra-docker.sh run 2.1
info        : Get topology
log         : Print cassandra logs, you need pass the node number. i.e: ./cassandra-docker.sh log 1
cqlsh       : Enters cqlsh on cassandra. i.e: ./cassandra-docker.sh cqlsh 1 3.9
schema      : Create some Schema and Data on cluster i.e: ./cassandra-docker.sh schema 1 3.9
cleanData   : Delete all cassandra data files
backup      : Does a snaposhot on a node with today date. i.e: ./cassandra-docker.sh backup 1 2.1.19
backup_all  : Does backup in all nodes of the cluster - 1 by 1. ./cassandra-docker.sh backup_all 2.1.19
restore     : Does a restore on a node by date. i.e: ./cassandra-docker.sh restore 1 2.1.19 2017-12-11
restore_all : Rolling back update process restoring all nodes in cluster. i.e: ./cassandra-docker.sh restore_all 2.1.19 2017-12-11
all         : Select * from defautl keyspace/table in all nodes. i.e: ./cassandra-docker.sh all 2.1.19
truncate    : TRUNCATE TABLE defautl keyspace/table in all nodes. i.e: ./cassandra-docker.sh truncate 2.1.19
stop        : Stop and clean up all docker running images
set_version : Sets the default cassandra version. i.e: ./cassandra-docker.sh set_version 2.1.19
help        : help documentation

```

## How it works?

1. We bake a docker image with Cassandra v2.1.X and Cassandra 3.9.x.
2. We create 1 cluster - 3 nodes.
4. You just need run ./cassandra-docker.sh bake 1 time.
5. You can run ./cassandra-docker.sh run as many times as you want. First thing on the script we delete old docker images and old docker network - so we create new docker images and network every time you run the script cassandra-docker-cluster.sh.

## What are my seeds/topology?

Cluster 1A (Linux)
```bash
178.18.0.101 - 9160 / 9042
179.18.0.102 - 9160 / 9042
179.18.0.103 - 9160 / 9042
```
Cluster 1A (Mac)
```bash
178.18.0.101 - 32101(9160) / 32102(9042)
179.18.0.102 - 32103(9160) / 32104(9042)
179.18.0.103 - 32105(9160) / 32106(9042)
```

## Steps to test Backup/Restore(Linux)
Backup
```bash
./cassandra-docker.sh stop
sudo rm -rf /usr/local/docker-shared/cassandra-*/
./cassandra-docker.sh run 2.1.19
# wait 30s
./cassandra-docker.sh schema 1 2.1.19
./cassandra-docker.sh all
./cassandra-docker.sh backup_all 2.1.19
ls /usr/local/docker-shared/cassandra-*/
./cassandra-docker.sh all
```
Restore
```bash
./cassandra-docker.sh stop
./cassandra-docker.sh run 2.1.19
# wait 30s
./cassandra-docker.sh all
./cassandra-docker.sh restore_all 2.1.19 2018-02-08
./cassandra-docker.sh all
```

## Similar projects

* dynomite-docker         -> https://github.com/diegopacheco/dynomite-docker
* dynomite-dooker-rocksdb -> https://github.com/diegopacheco/dynomite-docker-rocksdb
