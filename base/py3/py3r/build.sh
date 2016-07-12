set -o nounset
set -o pipefail

thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd "$( dirname "${thisfile}" )" && pwd )"
parentdir="$(dirname "${thisdir}")"
parent_name=zppz/$(basename "${parentdir}")
parent_version=$(cat "${parentdir}"/version)
PARENT="${parent_name}":"${parent_version}"

version=$(cat "${thisdir}"/version)
if [[ "${version}" < "${parent_version}" ]]; then
    echo "${parent_version}" > "${thisdir}"/version
    version=${parent_version}
fi
NAME=zppz/$(basename "${thisdir}"):"${version}"

echo
echo =====================================================
echo Creating Dockerfile for $NAME
cat > "${thisdir}/Dockerfile" <<EOF
# Dockerfile for image '${NAME}'

#===========================
# Generated by 'build.sh'.
#
# DO NOT EDIT.
#===========================

# In the intended use cases of this image,
# Python is the primary deveopment environment,
# whereas R is called from Python to make use of certain
# specialized R packages.
#
# One-way Python/R inter-op, namely calling R from Python,
# is provisioned by the Python package 'rpy2'.

FROM ${PARENT}
EOF

cat >> "${thisdir}/Dockerfile" <<'EOF'

USER root


ENV R_BASE_VERSION 3.1.1-1

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        r-base=${R_BASE_VERSION} \
        r-base-dev=${R_BASE_VERSION} \
    \
    && pip install --no-cache-dir --upgrade \
        'rpy2==2.8.2' \
    \
    && apt-get purge -y --auto-remove \
        r-base-dev \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    && apt-get -y autoremove \
    && apt-get clean

COPY ./install.r /usr/local/bin
RUN chmod +x /usr/local/bin/install.r

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
    && install.r \
        futile.logger \
        roxygen2 \
        testthat \
    && apt-get purge -y --auto-remove \
        build-essential \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    && apt-get -y autoremove \
    && apt-get clean


#-------------
# startup

USER ${USER}
WORKDIR ${HOME}

CMD ["/bin/bash"]
EOF


echo
echo Creating image "'${NAME}'"
echo
docker build -t "${NAME}" "${thisdir}"

