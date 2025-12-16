ARG PARENT


FROM ${PARENT}
ENV IMAGE_PARENT=${PARENT}
USER root


#-----------------
# group and user
#

# About permission related to mapped volumes:
# https://techflare.blog/permission-problems-in-bind-mount-in-docker-volume/

# Remove the user `ubuntu` in ubuntu 24.04 base image
# https://askubuntu.com/questions/1513927/ubuntu-24-04-docker-images-now-includes-user-ubuntu-with-uid-gid-1000
RUN touch /var/mail/ubuntu && chown ubuntu /var/mail/ubuntu && userdel -r ubuntu

RUN useradd --uid 1000 --user-group --groups 100 --home /home/docker-user --create-home --shell /bin/bash docker-user \
    && chown -R docker-user:docker-user /home/docker-user \
    && chmod -R u=rwx,g=rwx,o=r /home/docker-user \
    && rm -f /home/docker-user/.bashrc /home/docker-user/.profile
# Giving 'g=rwx' to /home/docker-user is a hack around mapped-volume permission issues.
# On Linux, if the host user has uid 1000 and is a member of group 100 ("users"),
# then intra-container code should have the same file access permissions as the host account.
# (Now I don't fully understand this. - 22.10.15)
# In this docker stack of utilities, this is mainly for volume-mapping source code 
# so that minor edits to them within the container will have exactly the same effect
# as editing them on the host.


RUN mkdir -p /home/docker-user/mnt/data /home/docker-user/mnt/log /home/docker-user/mnt/tmp \
    && chown -R docker-user:docker-user /home/docker-user/mnt \
    && mkdir -p /tmp

ENV DATADIR=/home/docker-user/mnt/data
ENV LOGDIR=/home/docker-user/mnt/log
ENV TMPDIR=/tmp

# Mount a data volume to /home/docker-user/mnt like this:
#
#   docker run --mount source=my-data-volume,target=/home/docker-user/mnt <image> ...

# Env set by `docker run -e DATADIR=... ` will override the same-named env set here by `ENV ...`.


# # TODO: use `umask` to give broader permission to users in the same group.
# RUN set -eux; \
# 	apt-update; \
# 	apt-install -y gosu; \
# 	gosu nobody true \
#     apt-clean
#
# COPY entrypoint.sh /usr/local/bin/entrypoint.sh
# RUN chmod +x /usr/local/bin/entrypoint.sh
# ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]



#-------------------------
# The very basic utilities

COPY dotfiles/apt/apt.conf /etc/apt/apt.conf
COPY bin/apt-clean bin/apt-install bin/apt-remove bin/apt-update bin/apt-upgrade /usr/local/bin/



RUN apt-update && apt-upgrade \
    && apt-install \
        apt-utils \
        dialog \
    && echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections \
    && apt-install \
        bzip2 \
        curl \
        htop \
        iproute2 \
        iputils-ping \
        less \
        telnet \
        tree \
        unzip \
        xz-utils \
    && DEBIAN_FRONTEND=noninteractive apt-install tzdata \
    && apt-install --reinstall ca-certificates && update-ca-certificates \
    && apt-clean


# `DEBIAN_FRONTEND=noninteractive` suppresses the "geographic area"
# prompt related to `tzdata`.

# `iproute2` provides command `ip`.

# For building, install
#    make gcc g++ libc6 libc6-dev


#-------------------------------
# misc

# COPY dotfiles/bash/bash.bashrc /etc/
RUN curl https://raw.githubusercontent.com/zpz/dotfiles/refs/heads/master/bash/bashrc -o /etc/bash.bashrc
RUN chmod +r /etc/bash.bashrc
RUN rm -f /root/.bashrc /root/.profile



######################


USER docker-user
WORKDIR /home/docker-user
CMD ["bash"]
