ARG PARENT

FROM ${PARENT}
ENV IMAGE_PARENT ${PARENT}
USER root

RUN apt-update && apt-install gcc g++ libc6-dev && apt-clean && rm -rf /tmp/*

USER docker-user
