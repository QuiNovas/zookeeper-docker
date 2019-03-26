FROM adoptopenjdk/openjdk11:x86_64-alpine-jre-11.0.2.9
LABEL maintainer="Mathew Moon <mmoon@quinovas.com>"

# Install required packages
RUN apk add --no-cache \
    bash \
    su-exec

RUN set -ex && \
   export GPG_KEY=D0BC8D8A4E90A40AFDFC43B3E22A746A68E327C1 && \
   mkdir -p /logs /datalog /conf /data && \
   apk add --no-cache --virtual .build-deps \
        ca-certificates \
        gnupg \
        libressl; \
    wget -q "https://www.apache.org/dist/zookeeper/zookeeper-3.5.4-beta/zookeeper-3.5.4-beta.tar.gz"; \
    wget -q "https://www.apache.org/dist/zookeeper/zookeeper-3.5.4-beta/zookeeper-3.5.4-beta.tar.gz.asc"; \
    export GNUPGHOME="$(mktemp -d)"; \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-key "$GPG_KEY" || \
    gpg --keyserver pgp.mit.edu --recv-keys "$GPG_KEY" || \
    gpg --keyserver keyserver.pgp.com --recv-keys "$GPG_KEY" && \
    gpg --batch --verify "zookeeper-3.5.4-beta.tar.gz.asc" "zookeeper-3.5.4-beta.tar.gz" && \
    tar -zxf "zookeeper-3.5.4-beta.tar.gz" && \
    mv zookeeper-3.5.4-beta /zookeeper && \
    mv "zookeeper/conf/"* /conf && \
    rm -rf "$GNUPGHOME" "zookeeper-3.5.4-beta.tar.gz" "zookeeper-3.5.4-beta.tar.gz.asc" && \
    apk del .build-deps && \
    adduser -D "zookeeper" && \
    chown -R zookeeper:zookeeper /logs /datalog /conf /data /zookeeper && \
    rm -f /zookeeper/bin/*.cmd && \
    rm -f /zookeeper/bin/zkServer.sh && \
    rm -f /zookeeper/bin/zkEnv.sh

RUN wget -qO /usr/local/bin/prometheus_agent.jar https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.11.0/jmx_prometheus_javaagent-0.11.0.jar

WORKDIR /zookeeper

COPY zookeeper /zookeeper/bin/zookeeper
COPY prometheus.yml /etc/prometheus/config.yml
COPY zoo.cfg /conf/zoo.cfg
COPY log4j.properties /conf/log4j.properties
COPY ensemble.cfg /conf/ensemble.cfg
COPY client /zookeeper/bin/zk-client
RUN chmod +x /zookeeper/bin/zk-client
RUN chmod +x /zookeeper/bin/zookeeper
RUN chown -R zookeeper:zookeeper /logs /datalog /conf /data /zookeeper

ENV PATH=$PATH:/zookeeper/bin

CMD ["/zookeeper/bin/zookeeper"]
