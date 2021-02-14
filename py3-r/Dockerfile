# In the intended use cases of this image,
# Python is the primary deveopment environment,
# whereas R is called from Python to make use of certain
# specialized R packages.
#
# One-way Python/R inter-op, namely calling R from Python,
# is provisioned by the Python package 'rpy2'.

# For instructions on installing R, go to
#   https://cloud.r-project.org
#   click 'Download R for Linux'
#   then click 'debian'
#
# The direct URL seems to be
#   https://cran.r-project.org/bin/linux/debian/
#
# How to install R from a custom server:
# 1. add source to '/etc/apt/sources.list' by 'echo .. >> '.
# 2. apt-get update
#       this should fail with error 'NO_PUBKEY xyz'
# 3. get key by
#       'apt-key adv --keyserver keyserver.ubuntu.com --recv-keys xyz'
# 4. apt-get-update
#       this should succeed
# 5. apt-get install r-base
#
# If we want to specify exact R version, then
#
# 5. get R version number by 'apt-cache show r-base'
# 6. specify version number in 'apt-get install'

ARG PARENT

FROM ${PARENT}
USER root

ENV IMAGE_PARENT ${PARENT}

ENV R_VERSION=4.0.2

RUN apt-update \
    && apt-install \
        r-base=${R_VERSION}-1build1 \
        r-base-dev=${R_VERSION}-1build1 \
    \
    && pip-install rpy2==2.9.5 \
    \
    && apt-clean \
    && rm -rf /tmp/*

COPY ./install.r /usr/local/bin
COPY ./install.version.r /usr/local/bin

RUN install.r versions
RUN install.version.r roxygen2 7.1.1
RUN install.version.r futile.logger 1.4.3
RUN install.version.r testthat

