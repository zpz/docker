
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

