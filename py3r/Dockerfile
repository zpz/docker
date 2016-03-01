# This image contains basic Python and R installation along with
# tools for deveopment as well as interactions between Python and R.
# In the intended use cases, Python is the primary deveopment
# environment, whereas R is called from Python to make use of certain
# specialized R packages.
#
# Two ways of Python/R inter-op are provisioned:
# one is to call R from within Python using the Python package "rpy2";
# the other is to use HDF5 data files as an intermediancy.
# For the latter mechanism, Python package "h5py" and R package "rhdf5"
# are provided.

# Note: official Python image gets the link 'python-config' wrong.
# Do not leave 'build-essential' in an image; it makes huge images.
# h5py requires numpy.

# TODO: it seems 'rhdf5' installs its own copy of small HDF5. How to
# avoid this?


FROM python:3.5.1-slim


ENV R_VERSION 3.2.3-6


RUN echo "deb http://http.debian.net/debian sid main" > /etc/apt/sources.list.d/debian-unstable.list

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        less \
        locales \
        vim \
    && ln -s -f /usr/local/bin/python3-config /usr/local/bin/python-config \
    \
    && pip3 install --no-cache-dir --upgrade \
        pip \
        setuptools \
        wheel \
    && pip3 install --no-cache-dir --upgrade \
        ipython==4.1.1 \
        pytest==2.8.7 \
        sh==1.11 \
    \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    && apt-get -y autoremove \
    && apt-get clean


RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential pkg-config \
        libhdf5-8 libhdf5-dev hdf5-tools \
    \
    && apt-get install -t unstable -y --no-install-recommends \
        r-base-core=${R_VERSION} \
        r-base-dev=${R_VERSION} \
    && echo 'install.packages(\
        c("devtools", "futile.logger", "roxygen2", "testthat"), \
        repos="http://cran.us.r-project.org", \
        dependencies=c("Depends", "Imports"), \
        clean=TRUE, keep_outputs=FALSE)' > /tmp/packages.R \
    && echo 'source("https://bioconductor.org/biocLite.R")' > /tmp/packages.R \
    && echo 'biocLite(c("rhdf5"), clean=TRUE, keep_output=FALSE)' >> /tmp/packages.R \
    && Rscript /tmp/packages.R \
    \
    && pip3 install --no-cache-dir --upgrade rpy2==2.7.8 \
    && pip3 install --no-cache-dir --upgrade numpy==1.10.4 \
    && pip3 install --no-cache-dir --upgrade h5py==2.5.0 \
    \
    && apt-get purge -y --auto-remove build-essential libhdf5-dev \
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


#--------------
# Environment

COPY ./bashrc /root/.bashrc
COPY ./bash_profile /root/.bash_profile
COPY ./vimrc /root/.vimrc

WORKDIR /home

CMD ["/bin/bash"]


# Additional, to be merged into sections above

RUN echo "alias R='/usr/bin/R --no-save'" >> /root/.bashrc

