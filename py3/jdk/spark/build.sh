set -o nounset
set -o pipefail

thisfile="${BASH_SOURCE[0]}"
thisdir=$( cd "$( dirname "${thisfile}" )" && pwd )
parentdir=$(dirname "${thisdir}")
parent_name=$(cat "${parentdir}"/name)
parent_version=$(cat "${parentdir}"/version)
PARENT="${parent_name}":"${parent_version}"

version=$(cat "${thisdir}"/version)
if [[ "${version}" < "${parent_version}" ]]; then
    echo "${parent_version}" > "${thisdir}"/version
    version=${parent_version}
fi
NAME="$(cat "${thisdir}/name"):${version}"

echo
echo =====================================================
echo Creating Dockerfile for "'${NAME}'"...
cat > "${thisdir}"/Dockerfile <<EOF
# Dockerfile for image '${NAME}'
# Generated by 'build.sh'
#
# DO NOT EDIT.

# Based on github.com/gettyimages/docker-spark

FROM ${PARENT}
USER root
EOF

cat >> "${thisdir}"/Dockerfile <<'EOF'

# JAVA
# How to find the latest version of Java:
#   search 'oracle download java'
#   click tab entitled 'Downloads'
#   download the desired file and note the URL in address bar, esp the '-bxx' part for the 'build' number.
#
# TODO:
#   switch to openjdk.
#ARG JAVA_MAJOR_VERSION=8
#ARG JAVA_UPDATE_VERSION=131
#ARG JAVA_VERSION=${JAVA_MAJOR_VERSION}u${JAVA_UPDATE_VERSION}
#ARG JAVA_BUILD_NUMBER=11
#ARG JAVA_BASE_URL=http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION}-b${JAVA_BUILD_NUMBER}
#ARG JAVA_DOWNLOAD_TOKEN=d54c1d3a095b4ff2b6607d096fa80163
#RUN mkdir -p /usr/share/java \
#    && curl -skL --retry 3 --header "Cookie: oraclelicense=accept-securebackup-cookie;" \
#            ${JAVA_BASE_URL}/${JAVA_DOWNLOAD_TOKEN}/server-jre-${JAVA_VERSION}-linux-x64.tar.gz \
#        | tar xz -C /usr/share/java
#ENV JAVA_HOME /usr/share/java/jdk1.${JAVA_MAJOR_VERSION}.0_${JAVA_UPDATE_VERSION}
#ENV PATH $PATH:$JAVA_HOME/bin

# SPARK
# How to find the latest version of spark:
# Go to official Apache Spark site, go to 'download'.
#
ENV SPARK_VERSION 2.2.0
ENV SPARK_HOME /usr/lib/spark
ARG SPARK_PACKAGE=spark-${SPARK_VERSION}-bin-hadoop2.7
RUN mkdir -p ${SPARK_HOME} \
    && curl -skL --retry 3 \
        "https://dist.apache.org/repos/dist/release/spark/spark-${SPARK_VERSION}/${SPARK_PACKAGE}.tgz" \
        | tar xz -C ${SPARK_HOME}
ENV SPARK_HOME ${SPARK_HOME}/${SPARK_PACKAGE}
ENV PATH $PATH:${SPARK_HOME}/bin

# Unpack the downloaded Spark source tar ball, find out the version of `py4j`.
ENV PY4J_VERSION 0.10.4
ENV PYTHONPATH ${PYTHONPATH}:${SPARK_HOME}/python:${SPARK_HOME}/python/lib/py4j-${PY4J_VERSION}-src.zip
ENV SPARK_OPTS --driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=info

# Note：(at least some of) the env varialbes set by these ENV commands are for `root` only.
# To set global env variables, some other approach is needed.
# Hints: /etc/bash.bashrc, /etc/profile.d/, /etc/pam.d/

COPY ./spark-defaults.conf ${SPARK_HOME}/conf
EOF

echo
echo Building image "'${NAME}'"
echo
docker build -t "${NAME}" "${thisdir}"


