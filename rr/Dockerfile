FROM debian:jessie

USER root


#-----------------
# System and basic

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        less \
        locales \
        vim \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    && apt-get -y autoremove \
    && apt-get clean


#--------------------
# Locale
# default is C.UTF-8

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen en_US.utf8 \
    && /usr/sbin/update-locale LANG=en_US.UTF-8


#-----------------
# R

ENV R_VERSION 3.2.4-1
# To find the latest R version available, in a container launched on the 'base' image above, do this:
# > echo "deb http://http.debian.net/debian sid main" > /etc/apt/sources.list.d/debian-unstable.list
# > apt-get update
# > apt-cache -t unstable search r-base
# > apt-cache -t unstable show r-base

RUN echo "deb http://http.debian.net/debian sid main" > /etc/apt/sources.list.d/debian-unstable.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential pkg-config \
    && apt-get install -t unstable -y --no-install-recommends \
        r-base-core=${R_VERSION} \
        r-base-dev=${R_VERSION} \
    && apt-get purge -y --auto-remove \
        build-essential \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    && apt-get -y autoremove \
    && apt-get clean

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential pkg-config \
    && echo 'install.packages(\
        c("devtools", "futile.logger", "roxygen2", "testthat"), \
        repos="http://cran.us.r-project.org", \
        dependencies=c("Depends", "Imports"), \
        clean=TRUE, keep_outputs=FALSE)' > /tmp/packages.R \
    && Rscript /tmp/packages.R \
    \
    && apt-get purge -y --auto-remove \
        build-essential \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    && apt-get -y autoremove \
    && apt-get clean

# TODO
# R package installation had errors.


#----------------------------
# bash and vim customization

COPY dotfiles/bashrc /etc/bash.bashrc
COPY dotfiles/vimrc /etc/vim/vimrc.local
COPY dotfiles/vim/ /etc/vim/


WORKDIR /

CMD ["/usr/bin/R", "--no-save"]

