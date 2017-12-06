#!/bin/bash

sed -i s/@CASS_NODE_IP/$(hostname -i)/g /cassandra/apache-cassandra-$CASS_VERSION/conf/cassandra.yaml

cd /cassandra/apache-cassandra-$CASS_VERSION/
/cassandra/apache-cassandra-$CASS_VERSION/bin/cassandra -R > /cassandra/cassandra.txt

tail -f /cassandra/cassandra.txt
