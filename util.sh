# Must have 'USER root' somewhere before this.
read -rd '' INSTALL_SYS_BASICS <<'EOF'
#------------------
# group and user

ENV GROUP=docker-users
ENV USER=docker-user
ENV HOME=/home/${USER}

RUN groupadd --gid 1000 ${GROUP} \
    && mkdir -p ${HOME} \
    && useradd --uid 1000 --gid ${GROUP} --no-user-group --home ${HOME} --shell /bin/bash ${USER} \
    && chown -R ${USER}:${GROUP} ${HOME}


#------------------
# System and basic

# 'curl': about 15 MB.
# 'locales': about 16MB.

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        less \
        locales \
    \
    && echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen \
    && locale-gen en_US.UTF-8 \
    && /usr/sbin/update-locale LANG=en_US.UTF-8 \
    \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    && apt-get -y autoremove \
    && apt-get clean

# Locale
#   default is C.UTF-8

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# bash customization
#
ENV SHELL=/bin/bash
COPY ./dotfiles/bash/bashrc /etc/bash.bashrc
RUN chmod +r /etc/bash.bashrc

#------------------
# entrypoint

ENV TINI_VERSION v0.9.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini

ENTRYPOINT ["/usr/bin/tini", "--"]
# TODO: problematic when I terminate some programs within container.
EOF


read -rd '' INSTALL_VIM <<'EOF'
#------------------
# vim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        vim \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    && apt-get -y autoremove \
    && apt-get clean

COPY ./dotfiles/vim/vimrc /etc/vim/vimrc.local
COPY ./dotfiles/vim/vim/ /etc/vim/
RUN chmod -R +rX /etc/vim

ENV EDITOR vim
EOF


read -rd '' INSTALL_GIT <<'EOF'
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    && apt-get -y autoremove \
    && apt-get clean

COPY ./dotfiles/git/gitconfig /etc/gitconfig
RUN chmod +r /etc/gitconfig
EOF


read -rd '' INSTALL_R_HDF5 <<'EOF'
# TODO: it seems 'rhdf5' installs its own copy of small HDF5.
# How to avoid this?

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libhdf5-dev \
    \
    && echo 'source("https://bioconductor.org/biocLite.R")' > /tmp/packages.R \
    && echo 'biocLite(c("rhdf5"), clean=TRUE, keep_output=FALSE)' >> /tmp/packages.R \
    && Rscript /tmp/packages.R \
    \
    && apt-get purge -y --auto-remove \
        libhdf5-dev \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    && apt-get -y autoremove \
    && apt-get clean
EOF

