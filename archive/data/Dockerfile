
ARG PARENT

FROM ${PARENT}
USER root

RUN pip-install \
        'sqlparse==0.2.4' \
        'avro-python3==1.8.2'

# MySQL
RUN pip-install  \
        'PyMySQL==0.9.3'

# Postgres, Redshift
RUN apt-update \
    && apt-install \
        libpq5=9.6.10-0+deb9u1 \
        libpq-dev=9.6.10-0+deb9u1 \
    && pip-install \
        'psycopg2==2.7.7' \
        'asyncpg==0.18.3' \
    && apt-clean

# Hive, Impala
# sasl, thrift, thrift-sasl are required by impyla.
#
# `impyla` has some issue with `thrift_sasl`.
# Don't upgrae the versions of the following block until
# the issue is resolved. (There is a Github issue about that
# which I can't find at the moment.)
RUN apt-update \
    && apt-install \
        libsasl2-dev \
        libsasl2-modules \
    && pip-install \
        'sasl==0.2.1' \
        'thrift==0.11.0' \
        'thrift_sasl==0.2.1' \
        'impyla==0.14.0' \
    && apt-clean

# Check out alternative `pyhive`.
