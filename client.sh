#!/bin/bash

ZOO_DATADIR=/data

ZOOBINDIR="$( cd "$(dirname "$0")" ; pwd -P )"
export PATH=$PATH:/zookeeper/bin

for i in "$ZOOBINDIR"/../src/java/lib/*.jar
do
    CLASSPATH="$i:$CLASSPATH"
done

for i in "$ZOOBINDIR"/../zookeeper-*.jar
do
  CLASSPATH="$i:$CLASSPATH"
done
LIBPATH=("${ZOOBINDIR}"/../lib/*.jar)

for i in "${LIBPATH[@]}"
do
    CLASSPATH="$i:$CLASSPATH"
done

for d in "$ZOOBINDIR"/../build/lib/*.jar
do
   CLASSPATH="$d:$CLASSPATH"
done

#remove trailing slash
CLASSPATH=$(echo "$CLASSPATH"|sed -e 's/:$//' -e 's/::/:/')

CLASSPATH="$ZOOBINDIR/../build/classes:$CLASSPATH:/conf/"

ZOO_CMD=$JAVA_HOME/bin/java

SERVER=${1}
[ -z ${1} ] && SERVER="127.0.0.1:2181"

$ZOO_CMD -cp $CLASSPATH \
org.apache.zookeeper.ZooKeeperMain -server ${1}
exit 0
