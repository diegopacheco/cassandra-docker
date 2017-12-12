#!/bin/bash

CV=$2
CV2=$3
CV3=$4
mac_docker_ip="localhost"
mac_dir=/Users/cassandra_docker/
main_keyspace=cluster_test
main_table=test


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
  ensureVersionIsPresent
  cleanUp
  setUpNetwork
  setupCluster
  info
}

function missingVerion(){
  echo "Mising Cassandra version! Aborting! You need pass the version: 2.1.19, 3.9"
}

function missingNode(){
  echo "Mising Cassandra node! Aborting! You need pass the node: 1,2 or 3"
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
   echo "bash        : Enters ssh/bash on cassandra node. i.e: ./cassandra-docker.sh bash 1"
   echo "schema      : Create some Schema and Data on cluster i.e: ./cassandra-docker.sh schema 1 3.9"
   echo "cleanData   : Delete all cassandra data files"
   echo "backup      : Does a snaposhot on a node with today date. i.e: ./cassandra-docker.sh backup 1 2.1.19"
   echo "restore     : Does a restore on a node by date. i.e: ./cassandra-docker.sh restore 1 2.1.19 2017-12-11"
   echo "all         : Select * from defautl keyspace/table in all nodes. i.e: ./cassandra-docker.sh all 2.1.19"
   echo "truncate    : TRUNCATE TABLE defautl keyspace/table in all nodes. i.e: ./cassandra-docker.sh truncate 2.1.19"
   echo "stop        : Stop and clean up all docker running images"
   echo "help        : help documentation"
}

function ensureNodeVersionIsPresent(){
  if [[ "$CV" = *[!\ ]* ]];
  then
    if [[ "$CV2" = *[!\ ]* ]];
    then
      valid="OK"
    else
      missingVerion
      exit 1
    fi
  else
    missingNode
    exit 1
  fi
}

function ensureVersionIsPresent(){
    if [[ "$CV" = *[!\ ]* ]];
    then
      valid="OK"
    else
      missingVerion
      exit 1
    fi
}

function log(){
  docker exec -i -t cassandra$CV cat /cassandra/cassandra.txt
}

function cqlsh(){
  ensureNodeVersionIsPresent
  docker exec -it cassandra$CV /cassandra/apache-cassandra-$CV2/bin/cqlsh 178.18.10$CV
}

function node_bash(){
  if [[ "$CV" = *[!\ ]* ]];
  then
    docker exec -it cassandra$CV bash
  else
    missingNode
  fi
}

function backup(){
   ensureNodeVersionIsPresent
   docker exec -it cassandra$CV /cassandra/cassandra-manager.sh backup $CV2
}

function restore(){
   ensureNodeVersionIsPresent
   restore_date=$CV3
   docker exec -it cassandra$CV /cassandra/cassandra-manager.sh restore $CV2 $restore_date
}


function all(){
  cass_version=$CV
  for i in `seq 1 3`;
  do
    echo "Node 178.18.0.10$i - Cassandra version [$cass_version] - SELECT * FROM $main_keyspace.$main_table;"
    docker exec -it cassandra$i sh -c \
    "echo 'SELECT * FROM $main_keyspace.$main_table;' | /cassandra/apache-cassandra-$cass_version/bin/cqlsh 178.18.0.10$i"
  done
}

function truncate(){
  ensureVersionIsPresent
  cass_version=$CV
  echo "Truncate $main_keyspace.$main_table - Cassandra version [$cass_version]"
  docker exec -it cassandra1 sh -c \
  "echo 'TRUNCATE TABLE $main_keyspace.$main_table;' | /cassandra/apache-cassandra-$cass_version/bin/cqlsh 178.18.0.101"
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
      "bash")
          node_bash
          ;;
      "backup")
          backup
          ;;
      "restore")
          restore
          ;;
      "stop")
          cleanUp
          ;;
      "all")
          all
          ;;
      "truncate")
          truncate
          ;;
      *)
          help
esac
