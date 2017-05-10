set -o nounset
set -o pipefail

thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd "$( dirname "${thisfile}" )" && pwd )"

PARENT="openjdk:8-jdk"
version=$(cat "${thisdir}"/version)
NAME="$(cat "${thisdir}/name"):${version}"

echo
echo =====================================================
echo Creating Dockerfile for ${NAME}
cat > "${thisdir}/Dockerfile" <<EOF
# Dockerfile for image '${NAME}'

#===========================
# Generated by 'build.sh'.
#
# DO NOT EDIT.
#===========================

FROM ${PARENT}
USER root
EOF

cat "$(dirname "${thisdir}")/base.in" >> "${thisdir}/Dockerfile"

cat >> "${thisdir}/Dockerfile" <<'EOF'
# 11 Mb
ENV MAVEN_VERSION 3.5.0
ENV MAVEN_HOME /usr/share/maven
ARG MAVEN_BASE_URL=http://www-eu.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries
RUN mkdir -p ${MAVEN_HOME} \
    && curl -skL --retry 3 ${MAVEN_BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
        | tar xz -C ${MAVEN_HOME}
ENV PATH ${PATH}:${MAVEN_HOME}/apache-maven-${MAVEN_VERSION}/bin

# 80 Mb
ENV GRADLE_VERSION 3.5
ENV GRADLE_HOME /usr/share/gradle
ARG GRADLE_BASE_URL=https://services.gradle.org/distributions
RUN mkdir -p ${GRADLE_HOME} \
    && curl -skL --retry 3 ${GRADLE_BASE_URL}/gradle-${GRADLE_VERSION}-bin.zip \
        -o ${GRADLE_HOME}/gradle.zip \
    && (cd ${GRADLE_HOME}; unzip gradle.zip; rm -f gradle.zip)
ENV PATH ${PATH}:${GRADLE_HOME}/gradle-${GRADLE_VERSION}/bin

# 21 Mb
ENV SCALA_VERSION 2.12.2
ENV SCALA_HOME /usr/share/scala
ARG SCALA_BASE_URL=https://downloads.lightbend.com/scala/${SCALA_VERSION}
RUN mkdir -p ${SCALA_HOME} \
    && curl -skL --retry 3 ${SCALA_BASE_URL}/scala-${SCALA_VERSION}.tgz \
        | tar xz -C ${SCALA_HOME}
ENV PATH ${PATH}:${SCALA_HOME}/scala-${SCALA_VERSION}/bin


ENV KOTLIN_VERSION 1.1
ENV KOTLIN_HOME /usr/share/kotlin
ARG KOTLIN_BASE_URL=https://github.com/JetBrains/kotlin/releases/download/v${KOTLIN_VERSION}
RUN mkdir -p ${KOTLIN_HOME} \
    && curl -skL --retry 3 ${KOTLIN_BASE_URL}/kotlin-compiler-${KOTLIN_VERSION}.zip \
        -o ${KOTLIN_HOME}/kotlin.zip \
    && (cd ${KOTLIN_HOME}; unzip kotlin.zip; rm -f kotlin.zip)
ENV PATH ${PATH}:${KOTLIN_HOME}/kotlinc/bin
EOF

echo
echo Building image "'${NAME}'"
echo
docker build -t "${NAME}" "${thisdir}"

