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


RUN apt-update \
    && apt-install \
        r-base \
        r-base-dev \
    \
    && pip-install rpy2 \
    \
    && apt-clean \
    && rm -rf /tmp/*

COPY ./install.r /usr/local/bin
COPY ./install.version.r /usr/local/bin

RUN chmod +x /usr/local/bin/install.r /usr/local/bin/install.version.r
RUN install.r versions