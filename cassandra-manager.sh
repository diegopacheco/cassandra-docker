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

function backup_tokens(){
  echo "Backing up old tokens..."
  $nodetool ring | grep $(hostname -i) | awk '{print $NF ","}' | xargs > tokens_backup.txt
  mv tokens_backup.txt $backup_dir/$TODAY/
}

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
         backup_tokens
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

  # todo: Restore old tokens

  echo "--Drain..."
  $nodetool drain

  echo "--Schema: Restore Schema..."
  cat $backup_dir/$date_restore/$main_keyspace-keyspace-backup.cql | $cqlsh $localhost

  echo "--Copy: Data from backup and restore..."
  cd $backup_dir/$date_restore/$main_table-*/snapshots/$main_keyspace-data-backup/
  cp * /cassandra/apache-cassandra-$VERSION/data/data/$main_keyspace/$main_table-*/

  echo "--Refresh..."
  $nodetool refresh -- $main_keyspace $main_table

  echo "--Repair..."
  $nodetool repair

  echo "--Restart..."
  sudo killall java
  cd /cassandra/apache-cassandra-$VERSION/
  /cassandra/apache-cassandra-$VERSION/bin/cassandra -R > /cassandra/cassandra.txt &

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
