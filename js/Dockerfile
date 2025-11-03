ARG PARENT


FROM ${PARENT}
ENV IMAGE_PARENT=${PARENT}
USER root


#--------------
# Node.js

RUN apt-update \
    && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-install nodejs \
    && apt-clean


######################


USER docker-user
WORKDIR /home/docker-user
CMD ["bash"]
