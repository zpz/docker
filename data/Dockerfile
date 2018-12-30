
ARG PARENT

FROM ${PARENT}
USER root

RUN pip install \
        'pandas' \
        'SQLAlchemy' \
        'sqlparse'

# MySQL
RUN pip install  \
        'PyMySQL'

# Postgres, Redshift

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libpq5 \
        libpq-dev \
    && pip install \
        'psycopg2' \
        'asyncpg' \
        'uvloop' \
    && rm -rf /var/lib/apt/lists/* /tmp/*

# Hive, Impala
# sasl, thrift, thrift-sasl are required by impyla.

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libsasl2-dev \
        libsasl2-modules \
    && pip install \
        'impyla==0.14.0' \
    && rm -rf /var/lib/apt/lists/* /tmp/*

