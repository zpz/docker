
#----------------------------------
# Software building and development

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        autoconf \
        automake \
        binutils \
        g++ \
        gcc \
        libc6-dev \
        libtool \
        make \
        xz-utils \
        zlib1g-dev \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    && apt-get -y autoremove \
    && apt-get clean

# `binutils` contains `gprof`.
# To use `gprof`, use option `-pg` during both compiling and linking.

# I did not include `git` in this image b/c `push` and `pull`
# would ask for password everytime if used in Docker.