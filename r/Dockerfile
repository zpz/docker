FROM debian:jessie

USER root
ENV HOME=/root

ENV R_VERSION 3.2.3.20160303-1
# To find the latest R version available, in a container launched on the 'base' image above, do this:
# > echo "deb http://http.debian.net/debian sid main" > /etc/apt/sources.list.d/debian-unstable.list
# > apt-get update
# > apt-cache -t unstable search r-base
# > apt-cache -t unstable show r-base

RUN echo "deb http://http.debian.net/debian sid main" > /etc/apt/sources.list.d/debian-unstable.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        less \
        locales \
        vim \
    && mkdir -p ${HOME}/.vim/colors \
    && apt-get install -y --no-install-recommends \
        build-essential pkg-config \
    && apt-get install -t unstable -y --no-install-recommends \
        r-base-core=${R_VERSION} \
        r-base-dev=${R_VERSION} \
    && echo >> /root/.bashrc \
    && echo "alias R='/usr/bin/R --no-save'" >> /root/.bashrc \
    \
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

#--------
# Locale

ENV TZ=America/Los_Angeles
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen en_US.utf8 \
    && /usr/sbin/update-locale LANG=en_US.UTF-8

#-------------
# bash and vim

COPY ./bashrc ${HOME}/.bashrc
COPY ./bash_profile ${HOME}/.bash_profile
COPY ./vimrc ${HOME}/.vimrc
COPY ./vimcolors/* ${HOME}/.vim/colors/


WORKDIR ${HOME}

CMD ["/usr/bin/R --no-save"]

