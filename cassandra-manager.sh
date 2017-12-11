#!/bin/bash

VERSION=$2
data_dir=/cassandra/apache-cassandra-$VERSION/data/data/
backup_dir=/cassandra/backup/
cqlsh=/cassandra/apache-cassandra-$VERSION/bin/cqlsh
nodetool=/cassandra/apache-cassandra-$VERSION/bin/nodetool
localhost=$(hostname -i)
TODAY=`date +%Y-%m-%d`

function backup_keyspaces(){
  keyspace=$1
  echo "Backup keyspace $keyspace ..."
  $cqlsh $localhost -e "DESC KEYSPACE ${keyspace}" > "${keyspace}-keyspace-backup".cql
  mv "${keyspace}-keyspace-backup".cql $backup_dir/$TODAY/
}

function backup_data(){
  keyspace=$1
  echo "Backup Data $keyspace ..."
  $nodetool snapshot -t ${keyspace}-data-backup ${keyspace}
  cp -prf $data_dir/$keyspace/* $backup_dir/$TODAY/
  #$nodetool clearsnapshot ${keyspace}
}

function mainBackup(){
  ensureVersionPresent
  mkdir -p $backup_dir/$TODAY/
  keyspaces=($($cqlsh $localhost -e 'DESCRIBE KEYSPACES'))
  for keyspace in "${keyspaces[@]}"; do
    	if [[ ${keyspace} != "system" && ${keyspace} != "system_traces" && ${keyspace} != '"OpsCenter"' ]]; then
         backup_keyspaces $keyspace
         backup_data $keyspace
      fi
  done
  echo "Backup done."
}

function mainRestore(){
  ensureVersionPresent
  #$nodetool repair -- cluster_test
  $nodetool refresh -- cluster_test test
  echo "Restore done."
}

function ensureVersionPresent(){
  if [[ "$VERSION" = *[!\ ]* ]];
  then
    valid="ok"
  else
    echo "Missing Version. You should pass: 2.1.19 or 3.9"
    exit 1
  fi
}

case $1 in
  "backup")
      mainBackup
      ;;
  "restore")
      mainRestore
      ;;
  *)
      echo "Invalid Option [$1]! Options Avaliabble: backup|restore."
esac
