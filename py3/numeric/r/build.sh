set -o nounset
set -o pipefail

thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd "$( dirname "${thisfile}" )" && pwd )"
parentdir="$(dirname "${thisdir}")"
parent_name="$(cat "${parentdir}/name")"
parent_version="$(cat "${parentdir}/version")"
PARENT="${parent_name}":"${parent_version}"

version="$(cat "${thisdir}/version")"
if [[ "${version}" < "${parent_version}" ]]; then
    echo "${parent_version}" > "${thisdir}"/version
    version=${parent_version}
fi
NAME="$(cat "${thisdir}/name"):${version}"

echo
echo =====================================================
echo Creating Dockerfile for $NAME
cat > "${thisdir}/Dockerfile" <<EOF
# Dockerfile for image '${NAME}'
# Generated by 'build.sh'.
#
# DO NOT EDIT.

# In the intended use cases of this image,
# Python is the primary deveopment environment,
# whereas R is called from Python to make use of certain
# specialized R packages.
#
# One-way Python/R inter-op, namely calling R from Python,
# is provisioned by the Python package 'rpy2'.

# For instructions on installing R, go to
#   https://cloud.r-project.org
#   click 'Download R for Linux'
#   then click 'debian'
#
# The direct URL seems to be
#   https://cran.r-project.org/bin/linux/debian/
#
# How to install R from a custom server:
# 1. add source to '/etc/apt/sources.list' by 'echo .. >> '.
# 2. apt-get update
#       this should fail with error 'NO_PUBKEY xyz'
# 3. get key by
#       'apt-key adv --keyserver keyserver.ubuntu.com --recv-keys xyz'
# 4. apt-get-update
#       this should succeed
# 5. get R version number by 'apt-cache show r-base'
# 6. specify version number in 'apt-get install'


FROM ${PARENT}
USER root
EOF

cat >> "${thisdir}/Dockerfile" <<'EOF'

ENV R_BASE_VERSION 3.4.1-2~jessiecran.0

COPY ./install.r /usr/local/bin
RUN chmod +x /usr/local/bin/install.r

RUN echo 'deb http://cran.rstudio.com/bin/linux/debian jessie-cran34/' >> /etc/apt/sources.list \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys FCAE2A0E115C3D8A \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        r-base=${R_BASE_VERSION} \
        r-base-dev=${R_BASE_VERSION} \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    \
    && pip install --no-cache-dir --upgrade \
        'rpy2==2.9.0'

RUN install.r \
        futile.logger \
        testthat \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        libxml2 libxml2-dev \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    && install.r BH xml2 roxygen2

# This image contains `gcc`, `g++`, `gfortran`.
EOF


echo
echo Building image "'${NAME}'"
echo
docker build -t "${NAME}" "${thisdir}"
