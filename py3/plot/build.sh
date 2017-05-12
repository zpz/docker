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

FROM ${PARENT}
USER root
EOF

cat >> "${thisdir}"/Dockerfile <<'EOF'

# freetype and xft are required by matplotlib

RUN pip install --no-cache-dir --upgrade \
        'bokeh==0.12.5' \
        'pandas==0.20.1' \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        libfreetype6 \
        libfreetype6-dev \
        libxft-dev \
        tcl \
        tk \
    && pip install --no-cache-dir --upgrade \
        'matplotlib==2.0.2' \
        'seaborn==0.7.1' \
    && apt-get purge -y --auto-remove \
        libfreetype6-dev \
        libxft-dev \
    && rm -rf /var/lib/apt/lists/* /tmp/*
EOF

echo
echo Building image "'${NAME}'"
echo
docker build -t "${NAME}" "${thisdir}"


