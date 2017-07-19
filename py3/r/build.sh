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


FROM ${PARENT}
USER root
EOF

cat >> "${thisdir}/Dockerfile" <<'EOF'

ENV R_BASE_VERSION 3.3.3-1~jessiecran.0

COPY ./install.r /usr/local/bin
RUN chmod +x /usr/local/bin/install.r

RUN apt-key adv --keyserver keys.gnupg.net --recv-key 6212B7B7931C4BB16280BA1306F90DE5381BA480 \
    && echo 'deb http://cran.rstudio.com/bin/linux/debian jessie-cran3/' >> /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        r-base=${R_BASE_VERSION} \
        r-base-dev=${R_BASE_VERSION} \
    && install.r \
        futile.logger \
        roxygen2 \
        testthat \
    \
    && pip install --no-cache-dir --upgrade \
        'rpy2==2.8.6' \
    \
    && rm -rf /var/lib/apt/lists/* /tmp/*
EOF


echo
echo Building image "'${NAME}'"
echo
docker build -t "${NAME}" "${thisdir}"

