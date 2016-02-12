# This image contains some data-centric Python tools
# along with a small set of R tools,
# as well as tools for interactions between Python and R.
# The choice of tools are not generic;
# instead it's tailored to some specific needs.

FROM python:3.5.1-slim


ENV PYTHON_VERSION 3.5.1
ENV R_VERSION 3.2.3-4


RUN echo "deb http://http.debian.net/debian sid main" > /etc/apt/sources.list.d/debian-unstable.list

# Note: official Python image gets the link 'python-config' wrong.

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        ed \
        less \
        locales \
        vim-tiny \
    && apt-get install -y --no-install-recommends \
        r-base=${R_VERSION} \
        r-base-dev=${R_VERSION} \
    && ln -s /usr/bin/vim.tiny /usr/bin/vim \
    && ln -s -f /usr/local/bin/python3-config /usr/local/bin/python-config \
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


#------------
# Python

# NOTE the special treatment for 'matplotlib';
# without the workaround a "time out" error keeps poping up.

RUN apt-get update \
    && pip3 install --upgrade pip setuptools wheel \
    && pip3 install --no-cache-dir requests==2.9.1 \
    && pip3 install --no-cache-dir numpy==1.10.4 \
    && pip3 install --no-cache-dir pandas==0.17.1 \
    && apt-get install -y --no-install-recommends \
        libfreetype6 libfreetype6-dev libxft-dev pkg-config \
    && pip3 --default-timeout=100 install --no-cache-dir matplotlib==1.5.1 \
    && apt-get install -y --no-install-recommends \
        liblapack-dev gfortran \
    && pip3 install --no-cache-dir scipy==0.17.0 \
    && pip3 install --no-cache-dir scikit-learn==0.17 \
    && pip3 install --no-cache-dir ipython==4.1.1 notebook==4.1.0 \
    && apt-get install -y --no-install-recommends \
        libhdf5-8 libhdf5-dev hdf5-tools \
    && pip3 install --no-cache-dir h5py==2.5.0 \
    && pip3 install --no-cache-dir rpy2==2.7.8 \
    && pip3 install --no-cache-dir \
        pytest==2.8.7 \
        sh==1.11 \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    && apt-get -y autoremove \
    && apt-get clean


#------------
# R

RUN cd /tmp \
    && echo 'install.packages(\
        c("roxygen2", "futile.logger", "testthat", "rPython"), \
        repos="http://cran.us.r-project.org", \
        dependencies=c("Depends", "Imports"), \
        clean=TRUE, keep_outputs=FALSE)' > /tmp/packages.R \
    && echo 'source("https://bioconductor.org/biocLite.R")' >> /tmp/packages.R \
    && echo 'biocLite(c("rhdf5"), \
        clean=TRUE, keep_outputs=FALSE)' >> /tmp/packages.R \
    && Rscript /tmp/packages.R \
    && rm -rf /tmp/*

# TODO: rhdf5 installs its own copy of 'small' HDF5.
# How to avoid this?


#--------------
# Environment

RUN echo "alias ..='cd ..'" >> /root/.bashrc \
    && echo "alias back='cd -'" >> /root/.bashrc \
    && echo "alias ls='ls -FGh --color'" >> /root/.bashrc \
    && echo "alias dir='ls -alg --color'" >> /root/.bashrc \
    && echo "alias cp='cp -i'" >> /root/.bashrc \
    && echo "alias rm='rm -i'" >> /root/.bashrc \
    && echo "alias mv='mv -i'" >> /root/.bashrc \
    && echo "source /root/.bashrc" >> /root/.bash_profile


WORKDIR /home

CMD ["/bin/bash"]

