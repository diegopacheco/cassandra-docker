FROM java:8-jdk
MAINTAINER Diego Pacheco - diego.pacheco.it@gmail.com

RUN apt-get update && apt-get install -y \
	autoconf \
	build-essential \
	dh-autoreconf \
	git \
	libssl-dev \
	libtool \
	python-software-properties \
	unzip

# Install Java 8
RUN wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u151-b12/e758a0de34e24606bca991d704f6dcbf/jdk-8u151-linux-x64.tar.gz"
RUN tar -xzvf jdk-8u151-linux-x64.tar.gz
RUN rm -rf jdk-8u151-linux-x64.tar.gz
RUN echo "alias cls='clear'\nexport JAVA_HOME=~/jdk1.8.0_151\nexport JRE_HOME=~/jdk1.8.0_151/jre\nexport PATH=$PATH:~/jdk1.8.0_151/bin:/~/jdk1.8.0_151/jre/bin" >> ~/.bashrc

# Install Cassandra
RUN mkdir /cassandra/ && chmod 777 /cassandra/
RUN wget https://archive.apache.org/dist/cassandra/3.9/apache-cassandra-3.9-bin.tar.gz
RUN tar -xzvf apache-cassandra-3.9-bin.tar.gz
RUN rm -rf apache-cassandra-3.9-bin.tar.gz
RUN mv apache-cassandra-3.9/ /cassandra/apache-cassandra-3.9

# Configure the cluster
ADD start-cass.sh  /cassandra/
ADD cassandra.yaml /casandra/apache-cassandra-3.9/conf/
RUN sed $(hostname -i)/q/@CASS_NODE_IP >> /apache-cassandra-3.9/conf/cassandra.yaml

EXPOSE 9160
EXPOSE 9042

CMD ["/start-cass.sh"]
