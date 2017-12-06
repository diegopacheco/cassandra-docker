# cassandra-docker

Simple Docker Image for Cassandra. cassandra-docker provides utilities to create clusters.

## Linux: How to use it? (native)

2. Download and install Docker. -> https://docs.docker.com/engine/installation/
3. Bake docker images $ ./cassandra-docker.sh bake
3. Create the Cassandra cluster $ ./cassandra-docker.sh run

## Windows/Mac: How to use it?

#### (MAC) Docker (Require changes on bash script)

1. Install docker -> https://docs.docker.com/docker-for-mac/install/
2. (just 1 time) Bake docker images $ sudo ./cassandra-docker-mac.sh bake
3. Create the Cassandra cluster $ sudo ./cassandra-docker-mac.sh run

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
cqlsh       : Enters cqlsh on cassandra. i.e: ./cassandra-docker.sh cqlsh 1
stop        : Stop and clean up all docker running images
help        : help documentation

```

## How it works?

1. We bake a docker image with Cassandra v2.1.X and Cassandra 3.9.x.
2. We create 1 cluster - 3 nodes.
4. You just need run ./cassandra-docker.sh bake 1 time.
5. You can run ./cassandra-docker.sh run as many times as you want. First thing on the script we delete old docker images and old docker network - so we create new docker images and network every time you run the script cassandra-docker-cluster.sh.

## What are my seeds/topology?

Cluster 1A
```bash
178.18.0.101 - 9160 / 9042
179.18.0.102 - 9160 / 9042
179.18.0.103 - 9160 / 9042
```
