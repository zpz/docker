ARG PARENT

FROM ${PARENT}
ENV IMAGE_PARENT ${PARENT}
USER root

RUN apt-update && apt-install gcc g++ libc6-dev && apt-clean && rm -rf /tmp/*

# Insall RocksDB dependencies for Python packages `bigdict` or `rocksdb`.
RUN apt-update && apt-install librocksdb-dev libsnappy-dev libbz2-dev liblz4-dev && apt-clean

USER docker-user
