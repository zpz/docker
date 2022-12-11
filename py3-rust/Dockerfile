ARG PARENT

FROM ${PARENT}
ENV IMAGE_PARENT ${PARENT}
USER root

# RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
RUN apt-update && apt-install rust-all && apt-clean && rm -rf /tmp/*

USER docker-user
