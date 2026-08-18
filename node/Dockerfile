ARG PARENT


FROM ${PARENT}
ARG PARENT
ENV IMAGE_PARENT=${PARENT}
USER root


#--------------
# Node.js

RUN apt-update \
    && curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt-install nodejs \
    && apt-clean


######################


USER docker-user
WORKDIR /home/docker-user
CMD ["bash"]
