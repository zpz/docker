ARG PARENT

FROM ${PARENT}
USER root


# JAVA
# How to find the latest version of Java:
#   search 'oracle download java'
#   click tab entitled 'Downloads'
#   download the desired file and note the URL in address bar, esp the '-bxx' part for the 'build' number
#   and the long hash-style 'token' string.
# Download the 'x64' (not 'x86') version of "server JRE".
#
# TODO:
#   switch to openjdk.
ARG JAVA_MAJOR_VERSION=8
ARG JAVA_UPDATE_VERSION=172
ARG JAVA_VERSION=${JAVA_MAJOR_VERSION}u${JAVA_UPDATE_VERSION}
ARG JAVA_BUILD_NUMBER=11
ARG JAVA_BASE_URL=http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION}-b${JAVA_BUILD_NUMBER}
# ARG JAVA_DOWNLOAD_TOKEN=0da788060d494f5095bf8624735fa2f1
ARG JAVA_DOWNLOAD_TOKEN=a58eab1ec242421181065cdc37240b08
RUN mkdir -p /usr/share/java \
    && curl -skL --retry 3 --header "Cookie: oraclelicense=accept-securebackup-cookie;" \
            ${JAVA_BASE_URL}/${JAVA_DOWNLOAD_TOKEN}/server-jre-${JAVA_VERSION}-linux-x64.tar.gz \
        | tar xz -C /usr/share/java
ENV JAVA_HOME /usr/share/java/jdk1.${JAVA_MAJOR_VERSION}.0_${JAVA_UPDATE_VERSION}
ENV PATH $PATH:$JAVA_HOME/bin

# SPARK
# How to find the latest version of spark:
# Go to official Apache Spark site, go to 'download'.
#
ENV SPARK_VERSION 2.3.0
ENV SPARK_HOME /usr/lib/spark
ARG SPARK_PACKAGE=spark-${SPARK_VERSION}-bin-hadoop2.7
RUN mkdir -p ${SPARK_HOME} \
    && curl -skL --retry 3 \
        "https://dist.apache.org/repos/dist/release/spark/spark-${SPARK_VERSION}/${SPARK_PACKAGE}.tgz" \
        | tar xz -C ${SPARK_HOME}
ENV SPARK_HOME ${SPARK_HOME}/${SPARK_PACKAGE}
ENV PATH $PATH:${SPARK_HOME}/bin

# Unpack the downloaded Spark source tar ball, find out the version of `py4j`.
# Can also find this info in the built image.
ENV PY4J_VERSION 0.10.6
ENV PYTHONPATH ${PYTHONPATH}:${SPARK_HOME}/python:${SPARK_HOME}/python/lib/py4j-${PY4J_VERSION}-src.zip
ENV SPARK_OPTS --driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=info

# Note：(at least some of) the env varialbes set by these ENV commands are for `root` only.
# To set global env variables, some other approach is needed.
# Hints: /etc/bash.bashrc, /etc/profile.d/, /etc/pam.d/

COPY ./spark-defaults.conf ${SPARK_HOME}/conf

# Instructions on using IPython or Jupyter Notebook for Spark
# are found in 'Spark Programming Guide / Using the Shell'.
RUN echo '#!/usr/bin/env bash' > /usr/local/bin/ispark \
    && echo 'PYSPARK_DRIVER_PYTHON=ipython pyspark' >> /usr/local/bin/ispark \
    && chmod +x /usr/local/bin/ispark

