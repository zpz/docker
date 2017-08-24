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
    version="${parent_version}"
    echo "${version}" > "${thisdir}"/version
fi
NAME="$(cat "${thisdir}/name"):${version}"


echo
echo =====================================================
echo Creating Dockerfile for "'${NAME}'"...
cat > "${thisdir}"/Dockerfile <<EOF
# Dockerfile for image '${NAME}'.
# Generated by 'build.sh'.
#
# DO NOT EDIT.

FROM ${PARENT}
USER root
EOF

cat >> "$thisdir"/Dockerfile <<'EOF'

RUN pip install --no-cache-dir --upgrade \
        'pandas==0.20.3' \
        'SQLAlchemy==1.1.13' \
        'sqlparse==0.2.3'

# MySQL
#
# RUN pip install --no-cache-dir --upgrade \
#         PyMySQL==0.7.11

# Postgres, Redshift
#
# RUN apt-get update \
#     && apt-get install -y --no-install-recommends \
#         libpq5 \
#         libpq-dev \
#     && pip install --no-cache-dir --upgrade \
#         'psycopg2==2.7.3' \
#         'asyncpg==0.12.0' \
#         'uvloop==0.8.0' \
#     && rm -rf /var/lib/apt/lists/* /tmp/*

# Hive, Impala
# sasl, thrift, thrift-sasl are required by impyla.
#
# RUN apt-get update \
#     && apt-get install -y --no-install-recommends \
#         gcc \
#         libsasl2-dev \
#         libsasl2-modules \
#     && pip install --no-cache-dir --upgrade \
#         'impyla==0.14.0' \
#     && apt-get purge -y --auto-remove \
#         gcc \
#     && rm -rf /var/lib/apt/lists/* /tmp/* \
#     && apt-get -y autoremove \
#     && apt-get clean

EOF

echo
echo building image "'${NAME}'"...
echo
docker build -t "${NAME}" "${thisdir}"



