#!/bin/bash

CV=$2
CV2=$3
mac_docker_ip="localhost"
mac_dir=/Users/cassandra_docker/

function bake(){
  sudo mkdir $mac_dir
  sudo mkdir $mac_dir/cass/
  docker build -t diegopacheco/cassandradocker . --network=host
}

function cleanUp(){
  docker stop cassandra1 > /dev/null 2>&1 ; docker rm cassandra1 > /dev/null 2>&1
  docker stop cassandra2 > /dev/null 2>&1 ; docker rm cassandra2 > /dev/null 2>&1
  docker stop cassandra3 > /dev/null 2>&1 ; docker rm cassandra3 > /dev/null 2>&1

  docker network rm myDockerNetCassandra > /dev/null 2>&1
  echo "Docker images and Network clean up DONE."
}

function setUpNetwork(){
  docker network create --subnet=178.18.0.0/16 myDockerNetCassandra
  docker network ls
}

function setupCluster(){
  SHARED=$mac_dir/cass/cassandra-1-$CV/::/cassandra/apache-cassandra-$CV/data
  docker run -d -v $SHARED --net myDockerNetCassandra --ip 178.18.0.101 --name cassandra1 -p 32101:9060 -p 32102:9042 -e CASS_VERSION=$CV diegopacheco/cassandradocker

  SHARED=$mac_dir/cass/cassandra-2-$CV/::/cassandra/apache-cassandra-$CV/data
  docker run -d -v $SHARED --net myDockerNetCassandra --ip 178.18.0.102 --name cassandra2 -p 32103:9060 -p 32104:9042 -e CASS_VERSION=$CV diegopacheco/cassandradocker

  SHARED=$mac_dir/cass/cassandra-3-$CV/::/cassandra/apache-cassandra-$CV/data
  docker run -d -v $SHARED --net myDockerNetCassandra --ip 178.18.0.103 --name cassandra3 -p 32105:9060 -p 32106:9042 -e CASS_VERSION=$CV diegopacheco/cassandradocker
}

function createSchemaAndData(){
  if [[ "$CV" = *[!\ ]* ]];
  then
    if [[ "$CV2" = *[!\ ]* ]];
    then
      docker exec -it cassandra$CV sh -c "echo \"
       CREATE KEYSPACE CLUSTER_TEST WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 3 };
       USE CLUSTER_TEST;
       CREATE TABLE TEST ( key text PRIMARY KEY, value text);
       INSERT INTO TEST (key,value) VALUES ('1', 'works');
       SELECT * from CLUSTER_TEST.TEST;\" | /cassandra/apache-cassandra-$CV2/bin/cqlsh 178.18.10$CV"
    else
      missingVerion
    fi
  else
    echo "Mising Cassandra node! Aborting! You need pass the node: 1, 2 or 3"
  fi
}

function cleanData(){
  sudo rm -rf $mac_dir/cass/cassandra-*
}

function run(){
  echo "$CV"
     if [[ "$CV" = *[!\ ]* ]];
     then
        cleanUp
        setUpNetwork
        setupCluster
        info
     else
        missingVerion
     fi
}

function missingVerion(){
  echo "Mising Cassandra version! Aborting! You need pass the version: 2.1.19, 3.9"
}

function info(){
  echo "ClusterTopology :"
  echo "  node1 - 178.18.0.101"
  echo "  node2 - 178.18.0.102"
  echo "  node3 - 178.18.0.103"
  echo ""
}

function help(){
   echo " #####                             ######                                     "
   echo "#     #   ##    ####   ####        #     #  ####   ####  #    # ###### #####   "
   echo "#        #  #  #      #            #     # #    # #    # #   #  #      #    #  "
   echo "#       #    #  ####   ####  ##### #     # #    # #      ####   #####  #    #  "
   echo "#       ######      #      #       #     # #    # #      #  #   #      #####   "
   echo "#     # #    # #    # #    #       #     # #    # #    # #   #  #      #   #   "
   echo " #####  #    #  ####   ####        ######   ####   ####  #    # ###### #    #   "
   echo "                                                                               "
   echo " "
   echo "cassandra-docker: Easy setup for cassandra cluster(2.1 & 3.9) for development. Created by: Diego Pacheco."
   echo "functions: "
   echo ""
   echo "bake        : Bakes docker image"
   echo "run         : Run cassandra docker cluster. i.e: ./cassandra-docker.sh run 2.1"
   echo "info        : Get topology"
   echo "log         : Print cassandra logs, you need pass the node number. i.e: ./cassandra-docker.sh log 1"
   echo "cqlsh       : Enters cqlsh on cassandra. i.e: ./cassandra-docker.sh cqlsh 1 3.9"
   echo "schema      : Create some Schema and Data on cluster i.e: ./cassandra-docker.sh schema 1 3.9"
   echo "cleanData   : Delete all cassandra data files"
   echo "stop        : Stop and clean up all docker running images"
   echo "help        : help documentation"
}

function log(){
  docker exec -i -t cassandra$CV cat /cassandra/cassandra.txt
}

function cqlsh(){
  if [[ "$CV" = *[!\ ]* ]];
  then
    if [[ "$CV2" = *[!\ ]* ]];
    then
      docker exec -it cassandra$CV /cassandra/apache-cassandra-$CV2/bin/cqlsh 178.18.10$CV
    else
      missingVerion
    fi
  else
    echo "Mising Cassandra node! Aborting! You need pass the node: 1, 2 or 3"
  fi
}

case $1 in
     "bake")
          bake
          ;;
     "run")
          run
          ;;
     "info")
          info
          ;;
     "log")
          log
          ;;
      "cqlsh")
          cqlsh
          ;;
      "schema")
          createSchemaAndData
          ;;
      "cleanData")
          cleanData
          ;;
      "stop")
          cleanUp
          ;;
      *)
          help
esac
