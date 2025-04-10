ARG PARENT

FROM ${PARENT}
ENV IMAGE_PARENT ${PARENT}
USER root

RUN apt-update && apt-install make gcc g++ libc6 libc6-dev && apt-clean && rm -rf /tmp/*

USER docker-user
