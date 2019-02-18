#!/bin/bash

ZOOCFG="/conf/zoo.cfg"

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

ZOOMAIN="org.apache.zookeeper.server.quorum.QuorumPeerMain"

# default heap for zookeeper server
ZK_SERVER_HEAP="${ZK_SERVER_HEAP:-1000}"
SERVER_JVMFLAGS="-Xmx${ZK_SERVER_HEAP}m $SERVER_JVMFLAGS"


if [ -z "$ZOOPIDFILE" ]; then
    if [ ! -d "$ZOO_DATADIR" ]; then
        mkdir -p "$ZOO_DATADIR"
    fi
    ZOOPIDFILE="$ZOO_DATADIR/zookeeper_server.pid"
else
    # ensure it xists, otw stop will fail
    mkdir -p "$(dirname "$ZOOPIDFILE")"
fi

[ -z $PROMETHEUS_PORT ] && PROMETHEUS_PORT=7070
PROMETHEUS_CMD=""

if [ -z ${WITHOUT_PROMETHEUS} ]; then
  PROMETHEUS_CMD="-javaagent:/usr/local/bin/prometheus_agent.jar=${PROMETHEUS_PORT}:/etc/prometheus/config.yml"
fi

ZOO_CMD=$JAVA_HOME/bin/java
MEMORY_OPTS='-XX:+CrashOnOutOfMemoryError'

[ ! -z "${ASYNC_HOOK}" ] && [ -x "${ASYNC_HOOK}" ] && ${ASYNC_HOOK} 2>&1 &

[ ! -z "${PREHOOK}" ] && [ -x "${PREHOOK}" ] && ${PREHOOK}

CMD=$(cat<<EOF
  ${ZOO_CMD} \
  ${MEMORY_OPTS} \
  ${PROMETHEUS_CMD} \
  ${ZOO_EXTRA_ARGS} \
  -cp $CLASSPATH $JVMFLAGS $ZOOMAIN $ZOOCFG
EOF
);

#Lets see the command for debugging
[ ! -z ${DEBUG} ] && echo -e "${CMD}"

#Now run it
${CMD}
