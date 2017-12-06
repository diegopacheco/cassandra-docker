#!/bin/bash

sed -i s/@CASS_NODE_IP/$(hostname -i)/g /cassandra/apache-cassandra-3.9/conf/cassandra.yaml

cd /cassandra/apache-cassandra-3.9/
/cassandra/apache-cassandra-3.9/bin/cassandra -R > /cassandra/cassandra.txt

tail -f /cassandra/cassandra.txt
