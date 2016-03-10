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

FROM zppz/py3:0.1

USER root

ENV R_VERSION 3.2.3.20160306-1
# To find the latest R version available, in a container launched on the 'base' image above, do this:
# > echo "deb http://http.debian.net/debian sid main" > /etc/apt/sources.list.d/debian-unstable.list
# > apt-get update
# > apt-cache -t unstable search r-base
# > apt-cache -t unstable show r-base

# h5py requires numpy.

# TODO: it seems 'rhdf5' installs its own copy of small HDF5. How to
# avoid this?

RUN echo "deb http://http.debian.net/debian sid main" > /etc/apt/sources.list.d/debian-unstable.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential pkg-config \
        libhdf5-8 libhdf5-dev hdf5-tools \
    \
    && apt-get install -t unstable -y --no-install-recommends \
        r-base-core=${R_VERSION} \
        r-base-dev=${R_VERSION} \
    && echo >> /root/.bashrc \
    && echo "alias R='/usr/bin/R --no-save'" >> /root/.bashrc \
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

WORKDIR /

CMD ["/bin/bash"]

