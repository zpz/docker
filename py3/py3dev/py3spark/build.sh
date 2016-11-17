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

#=============================
# Generated by 'build.sh'
#
# DO NOT EDIT.
#=============================

# Based on github.com/gettyimages/docker-spark

FROM ${PARENT}
EOF

cat >> "${thisdir}"/Dockerfile <<'EOF'

USER root
WORKDIR /

# JAVA
# How to find the latest version of Java:
#   search 'oracle download java'
#   click tab entitled 'Downloads'$
#   download the desired file and note the URL in address bar, esp the '-bxx' part for the 'build' number.
#
ARG JAVA_MAJOR_VERSION=8
ARG JAVA_UPDATE_VERSION=112
ARG JAVA_VERSION=${JAVA_MAJOR_VERSION}u${JAVA_UPDATE_VERSION}
ARG JAVA_BUILD_NUMBER=15
ENV JAVA_HOME /usr/jdk1.${JAVA_MAJOR_VERSION}.0_${JAVA_UPDATE_VERSION}
ENV PATH $PATH:$JAVA_HOME/bin
RUN curl -skL --retry 3 --header "Cookie: oraclelicense=accept-securebackup-cookie;" \
            "http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION}-b${JAVA_BUILD_NUMBER}/server-jre-${JAVA_VERSION}-linux-x64.tar.gz" \
        | tar xz -C /usr/ \
    && ln -s $JAVA_HOME /usr/java \
    && rm -rf $JAVA_HOME/man

# SPARK
# How to find the latest version of spark:
# Go to official Apache Spark site, go to 'download'.
#
ENV SPARK_VERSION 2.0.2
ENV SPARK_PACKAGE spark-${SPARK_VERSION}-bin-hadoop2.7
ENV SPARK_HOME /usr/local/spark
ENV PATH $PATH:${SPARK_HOME}/bin
RUN curl -skL --retry 3 \
        "https://dist.apache.org/repos/dist/release/spark/spark-${SPARK_VERSION}/${SPARK_PACKAGE}.tgz" \
        | tar xz -C /tmp/ \
    && mv /tmp/${SPARK_PACKAGE} ${SPARK_HOME}

# Unpack the downloaded Spark source tar ball, find out the version of `py4j`.
ENV PYTHONPATH ${PYTHONPATH}:${SPARK_HOME}/python:${SPARK_HOME}/python/lib/py4j-0.10.3-src.zip
ENV SPARK_OPTS --driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=info

CMD ["/bin/bash"]
EOF

echo
echo building image "'${NAME}'"...
echo
docker build -t "${NAME}" "${thisdir}"


