#!/bin/bash

VERSION=$2
ARG3=$3
main_keyspace=cluster_test
main_table=test
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
  $nodetool clearsnapshot ${keyspace}
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
  ensureDatePresent
  date_restore=$ARG3

  # Trumcate before restore to avoid loose data.
  echo "TRUNCATE TABLE $main_keyspace.$main_table" | $cqlsh $localhost

  # Copy data from backup and refresh (need be done by node basis)
  cd $backup_dir/$date_restore/$main_table-*/snapshots/$main_keyspace-data-backup/
  cp * /cassandra/apache-cassandra-$VERSION/data/data/$main_keyspace/$main_table-*/
  $nodetool refresh -- $main_keyspace $main_table
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

function ensureDatePresent(){
  if [[ "$ARG3" = *[!\ ]* ]];
  then
    valid="ok"
  else
    echo "Missing Restore Date. You should pass: YYYY-mm-dd i.e: 2017-12-11"
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
