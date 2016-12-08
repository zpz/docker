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

# This is a catch-all image for learning purposes.

#=============================
# Generated by 'build.sh'
#
# DO NOT EDIT.
#=============================

FROM ${PARENT}
EOF

cat >> "${thisdir}"/Dockerfile <<'EOF'

USER root
WORKDIR /

RUN pip install --no-cache-dir --upgrade \
        'arrow==0.8.0' \
        'bokeh==0.12.3' \
        'fastavro==0.11.1' \
        'numpy==1.11.2' \
        'pandas==0.19.1' \
        'toolz==0.8.0'

# freetype and xft are required by matplotlib

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libfreetype6 \
        libfreetype6-dev \
        libxft-dev \
    && pip install --no-cache-dir --upgrade \
        'matplotlib==2.0.0b4' \
    && apt-get purge -y --auto-remove \
        libfreetype6-dev \
        libxft-dev \
    && pip install --no-cache-dir --upgrade \
        'seaborn==0.7.1' \
    && apt-get install -y --no-install-recommends \
        liblapack3 \
        liblapack-dev \
        gfortran \
    && pip install --no-cache-dir --upgrade \
        'scipy==0.18.1' \
    && apt-get purge -y --auto-remove \
        liblapack-dev \
        gfortran \
    && pip install --no-cache-dir --upgrade \
        'patsy==0.4.1' \
        'statsmodels==0.8.0rc1' \
    && pip install --no-cache-dir --upgrade \
        'scikit-learn==0.18' \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    && apt-get autoremove -y \
    && apt-get clean -y

CMD ["/bin/bash"]
EOF

echo
echo Building image "'${NAME}'"
echo
docker build -t "${NAME}" "${thisdir}"


