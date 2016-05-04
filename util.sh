function download_dotfiles() {
    dest=$1
    curl -sL https://github.com/zpz/linux/archive/master.tar.gz -o - |tar xz -C "$dest"
    mv "$dest"/linux-master "$dest"/dotfiles
}


function remove_dotfiles() {
    dest=$1
    rm -rf "$dest"/dotfiles
}


function build_image() {
    dest="$1"
    name="$2"
    echo
    echo building image "$name"...
    echo
    download_dotfiles "$dest"
    docker build -t "$name" "$dest"
    remove_dotfiles "$dest"
}


read -rd '' HEADER <<'EOF'
#==================================
# Generated by 'build.sh'.
#
# DO NOT EDIT.
#==================================
EOF


read -rd '' CREATE_USER <<'EOF'
ENV HOME=/home/${USER}

RUN groupadd --gid 1000 ${GROUP} \
    && mkdir -p ${HOME} \
    && useradd --uid 1000 --gid ${GROUP} --no-user-group --home ${HOME} --shell /bin/bash ${USER} \
    && chown -R ${USER}:${GROUP} ${HOME}
EOF


read -rd '' INSTALL_SYS_BASICS <<'EOF'
# 'curl': about 15 MB.
# 'locales': about 16MB.

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        less \
        locales \
    \
    && echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen \
    && locale-gen en_US.UTF-8 \
    && /usr/sbin/update-locale LANG=en_US.UTF-8 \
    \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    && apt-get -y autoremove \
    && apt-get clean

# Locale
#   default is C.UTF-8

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# bash customization
#
ENV SHELL=/bin/bash
COPY ./dotfiles/bash/bashrc /etc/bash.bashrc
RUN chmod +r /etc/bash.bashrc
EOF


read -rd '' INSTALL_TINI <<'EOF'
ENV TINI_VERSION v0.9.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini

ENTRYPOINT ["/usr/bin/tini", "--"]
# TODO: problematic when I terminate some programs within container.
EOF


read -rd '' INSTALL_VIM <<'EOF'
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        vim \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    && apt-get -y autoremove \
    && apt-get clean

COPY ./dotfiles/vim/vimrc /etc/vim/vimrc.local
COPY ./dotfiles/vim/vim/ /etc/vim/
RUN chmod -R +rX /etc/vim

ENV EDITOR vim
EOF


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


read -rd '' INSTALL_PY_BASICS <<'EOF'
RUN pip install --no-cache-dir --upgrade \
        pip \
        setuptools \
        wheel \
    && pip install --no-cache-dir --upgrade \
        'ipython==4.2.0' \
        'pytest==2.9.1' \
        'requests==2.10.0' \
        'sh==1.11' \
        'toolz==0.7.4' \
    && ln -s /usr/local/bin/py.test /usr/local/bin/pytest
EOF


read -rd '' INSTALL_PY_DEV <<'EOF'
RUN pip install --no-cache-dir --upgrade \
        'ipdb==0.10.0' \
        'pylint==1.5.5' \
        'pytest-cov==2.2.1' \
        'pudb==2016.1' \
        'yapf==0.7.1' \
    \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        pkg-config \
    && pip install --no-cache-dir --upgrade \
        'line_profiler==1.0' \
        'notebook==4.2.0' \
    && apt-get purge -y --auto-remove \
        build-essential \
        pkg-config \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    && apt-get -y autoremove \
    && apt-get clean

# notebook will install ipython, pyzmq, tornado, jinja2 and some other things.

ENV NOTEBOOKPORT 8888
EXPOSE $NOTEBOOKPORT

RUN echo '#!/usr/bin/env bash' > /usr/local/bin/notebook \
    && echo >> /usr/local/bin/notebook \
    && echo 'jupyter notebook --port=$NOTEBOOKPORT --no-browser --ip=0.0.0.0' >> /usr/local/bin/notebook \
    && chmod +x /usr/local/bin/notebook
EOF


read -rd '' INSTALL_PY_DATA <<'EOF'
RUN pip install --no-cache-dir --upgrade \
        'numpy==1.11.0' \
        'sqlalchemy==1.0.12' \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        pkg-config \
    && pip install --no-cache-dir --upgrade \
        'pandas==0.18.0' \
    && apt-get purge -y --auto-remove \
        build-essential \
        pkg-config \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    && apt-get -y autoremove \
    && apt-get clean
EOF


read -rd '' INSTALL_PY_PLOT <<'EOF'
# freetype and xft are required by matplotlib
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        pkg-config \
        libfreetype6 \
        libfreetype6-dev \
        libxft-dev \
    && pip install --no-cache-dir --upgrade \
        'matplotlib==1.5.1' \
        'bokeh==0.11.1' \
    && apt-get purge -y --auto-remove \
        build-essential \
        pkg-config \
        libfreetype6-dev \
        libxft-dev \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    && apt-get autoremove -y \
    && apt-get clean
EOF


read -rd '' INSTALL_PY_MODEL <<'EOF'
# lapack and gfortran are required by scipy and a couple others.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        pkg-config \
        liblapack3 \
        liblapack-dev \
        gfortran \
    \
    && pip install --no-cache-dir --upgrade \
        'scipy==0.17.0' \
    && pip install --no-cache-dir --upgrade \
        'cvxpy==0.4.0' \
        'patsy==0.4.1' \
        'scikit-learn==0.17.1' \
        'statsmodels==0.6.1' \
    \
    && pip install --no-cache-dir --upgrade \
        'seaborn==0.7.0' \
    \
    && apt-get purge -y --auto-remove \
        build-essential \
        pkg-config \
        liblapack-dev \
        gfortran \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    && apt-get autoremove -y \
    && apt-get clean

#RUN pip install --no-cache-dir --upgrade \
#    https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-0.8.0-cp34-cp34m-linux_x86_64.whl

#       'skdata==0.0.4' \
RUN pip install --no-cache-dir --upgrade \
        'pydataset==0.2.0'
EOF


read -rd '' INSTALL_R_BASICS <<'EOF'
# ENV R_VERSION 3.2.4-revised-1
# To find the latest R version available, in a container launched on the 'base' image above, do this:
# > echo "deb http://http.debian.net/debian sid main" > /etc/apt/sources.list.d/debian-unstable.list
# > apt-get update
# > apt-cache -t unstable search r-base
# > apt-cache -t unstable show r-base
#
# RUN echo "deb http://http.debian.net/debian sid main" > /etc/apt/sources.list.d/debian-unstable.list \
#     && apt-get update \
#     && apt-get install -y --no-install-recommends \
#         build-essential \
#         pkg-config \
#         libreadline6 \
#         libreadline6-dev \
#     \
#     && apt-get install -t unstable -y --no-install-recommends \
#         r-base=${R_VERSION} \
#         r-base-dev=${R_VERSION} \

ENV R_VERSION 3.1.1-1

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        pkg-config \
        libreadline6 \
        libreadline6-dev \
    \
    && apt-get install -y --no-install-recommends \
        r-base=${R_VERSION} \
        r-base-dev=${R_VERSION} \
    && echo 'install.packages(\
        c("futile.logger", "testthat"), \
        repos="http://cran.us.r-project.org", \
        dependencies=c("Depends", "Imports"), \
        clean=TRUE, keep_outputs=FALSE)' > /tmp/packages.R \
    && Rscript /tmp/packages.R \
    \
    && pip3 install --no-cache-dir --upgrade \
        'rpy2==2.7.8' \
    \
    && apt-get purge -y --auto-remove \
        build-essential \
        pkg-config \
        libreadline6-dev \
        r-base-dev \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    && apt-get -y autoremove \
    && apt-get clean
EOF


read -rd '' INSTALL_R_DEV <<'EOF'
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        pkg-config \
    \
    && echo 'install.packages(\
        c("roxygen2"), \
        repos="http://cran.us.r-project.org", \
        dependencies=c("Depends", "Imports"), \
        clean=TRUE, keep_outputs=FALSE)' > /tmp/packages.R \
    && Rscript /tmp/packages.R \
    \
    && apt-get purge -y --auto-remove \
        build-essential \
        pkg-config \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    && apt-get -y autoremove \
    && apt-get clean
EOF



read -rd '' INSTALL_HDF5 <<'EOF'
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        pkg-config \
        libhdf5-8 \
        libhdf5-dev \
        hdf5-tools \
    \
    && pip3 install --no-cache-dir --upgrade \
        'h5py==2.6.0' \
    \
    && apt-get purge -y --auto-remove \
        build-essential \
        pkg-config \
        libhdf5-dev \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    && apt-get -y autoremove \
    && apt-get clean
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

