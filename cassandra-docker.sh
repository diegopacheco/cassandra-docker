#!/bin/bash

DV=$2

function bake(){
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
  SHARED=/usr/local/docker-shared/cassandra-1/:/var/lib/cassandra/
  docker run -d -v $SHARED --net myDockerNetCassandra --ip 178.18.0.101 --name cassandra1 diegopacheco/cassandradocker

  SHARED=/usr/local/docker-shared/cassandra-2/:/var/lib/cassandra/
  docker run -d -v $SHARED --net myDockerNetCassandra --ip 178.18.0.102 --name cassandra2 diegopacheco/cassandradocker

  SHARED=/usr/local/docker-shared/cassandra-3/:/var/lib/cassandra/
  docker run -d -v $SHARED --net myDockerNetCassandra --ip 178.18.0.103 --name cassandra3 diegopacheco/cassandradocker
}

function run(){
  cleanUp
  setUpNetwork
  setupCluster
  info
}


function info(){
  echo "ClusterTopology :"
  echo "  node1 - 178.18.0.101"
  echo "  node2 - 178.18.0.102"
  echo "  node3 - 178.18.0.103"
  echo ""
}

function help(){
   echo " "
   echo "cassandra-docker: easy setup for cassandra cluster(3.9) for development. Created by: Diego Pacheco."
   echo "functions: "
   echo ""
   echo "bake        : Bakes docker image"
   echo "run         : Run cassandra docker cluster"
   echo "info        : Get topology"
   echo "log         : Print cassandra logs, you need pass the node number. i.e: ./cassandra-docker.sh log 1"
   echo "cqlsh       : Enters cqlsh on cassandra. i.e: ./cassandra-docker.sh cqlsh 1"
   echo "stop        : Stop and clean up all docker running images"
   echo "help        : help documentation"
}

function log(){
  docker exec -i -t cassandra$DV cat /cassandra/cassandra.txt
}

function cqlsh(){
  if [[ "$DV" = *[!\ ]* ]];
  then
    docker exec -it cassandra$DV /cassandra/apache-cassandra-3.9/bin/cqlsh 178.18.10$DV
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
      "stop")
          cleanUp
          ;;
      *)
          help
esac
