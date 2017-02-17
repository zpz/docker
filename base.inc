
#------------------
# group and user

RUN groupadd --gid 1000 docker-users \
    && mkdir -p /home/docker-user \
    && useradd --uid 1000 --gid docker-users --no-user-group --home /home/docker-user --shell /bin/bash docker-user \
    && chown -R docker-user:docker-users /home/docker-user

# If root privilage is needed, install `sudo`, and add
# RUN bash -c "echo -e '1234\1234' | passwd docker-user" \
#   && adduser docker-user admin


#-----------
# Very basic

# 'curl': about 15 MB.
# 'vim': about 20MB.

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        less \
        vim \
    \
    && curl -skL https://github.com/zpz/linux/archive/master.tar.gz |tar xz -C /tmp/ \
    && mv /tmp/linux-master /tmp/dotfiles \
    && cp /tmp/dotfiles/bash/bashrc /etc/bash.bashrc \
    && chmod +r /etc/bash.bashrc \
    && mkdir -p /etc/vim \
    && cp /tmp/dotfiles/vim/vimrc /etc/vim/vimrc.local \
    && cp -r /tmp/dotfiles/vim/vim/* /etc/vim/ \
    && chmod -R +rX /etc/vim \
    \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    && apt-get -y autoremove \
    && apt-get clean

ENV SHELL=/bin/bash
ENV EDITOR vim


#------------------
# entrypoint

#  ENV TINI_VERSION v0.13.2
#  ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
#  RUN chmod +x /usr/bin/tini
#
#  ENTRYPOINT ["/usr/bin/tini", "--"]
#  # TODO: problematic when I terminate some programs within container.

