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

# RUN apt-get update \
#     && apt-get install -y --no-install-recommends \
#         gnupg2 \
#         dirmngr \
#     \
#     && echo 'deb http://cloud.r-project.org/bin/linux/debian stretch-cran35/' > /etc/apt/sources.list.d/myrrepo.list \
#     && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys FCAE2A0E115C3D8A \
#     && apt-get update \
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        r-base \
        r-base-dev \
    \
    && pip install --no-cache-dir --upgrade \
        'rpy2' \
    \
    && apt-get remove --purge -y \
        r-base-dev \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/*
#     && rm -rf /var/lib/apt/lists/* /tmp/* \
#     && rm -f /etc/apt/sources.list.d/myrrepo.list

# `gnupg2` and `dirmngr` are needed to run `apt-key`.

COPY ./install.r /usr/local/bin
COPY ./install.version.r /usr/local/bin

RUN chmod +x /usr/local/bin/install.r /usr/local/bin/install.version.r
RUN install.r versions
