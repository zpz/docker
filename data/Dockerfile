
ARG PARENT

FROM ${PARENT}
USER root

RUN pip-install \
        'pandas' \
        'SQLAlchemy' \
        'sqlparse' \
        'avro-python3'

# MySQL
RUN pip-install  \
        'PyMySQL'

# Postgres, Redshift

RUN apt-get update \
    && apt-get-install \
        libpq5 \
        libpq-dev \
    && pip-install \
        'psycopg2' \
        'asyncpg' \
        'uvloop' \
    && apt-get-clean

# Hive, Impala
# sasl, thrift, thrift-sasl are required by impyla.

RUN apt-get update \
    && apt-get-install \
        libsasl2-dev \
        libsasl2-modules \
    && pip-install \
        'impyla==0.14.0' \
    && apt-get-clean

