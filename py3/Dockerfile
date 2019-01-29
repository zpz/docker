ARG PARENT

FROM ${PARENT}
USER root

#---------------
# group and user

RUN groupadd --gid 1000 docker \
    && mkdir -p /home/docker-user \
    && useradd --uid 1000 --gid docker --no-user-group --home /home/docker-user --shell /bin/bash docker-user \
    && chown -R docker-user:docker /home/docker-user \
    && chmod -R u=rwx,g=rwx,o=r /home/docker-user

# Giving 'g=rwx' to /home/docker-user is a hack around mapped-volume permission issues.

# If root privilage is needed, install `sudo`, and add
# RUN usermod -a -G sudo docker-user \
#   && echo 'docker-user ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/docker-user \
#   && chmod 0440 /etc/sudoers.d/docker-user

# Subsequently, when you use `sudo command ...`, the environment is different.
# To preserve environment, use the `-E -H` options.
# However, strangely, `PYTHONPATH` is not preserved.
# You can simply do this:
#   sudo PYTHONPAH=$PYTHONPATH command ...

COPY dotfiles/bash/bashrc /etc/bash.bashrc
RUN chmod +r /etc/bash.bashrc

ENV SHELL=/bin/bash

# COPY dotfiles/pip/pip.conf /etc/xdg/pip/pip.conf
# This controls behavior of `pip` when we use it to install Python packages.
# In particular, the config instructs `pip` to not save cache, hence reducing size
# of the resultant Docker image.
# Without this config, we can use option `--no-cache-dir`  in each use of `pip`.

# COPY dotfiles/apt/apt.conf /etc/apt/apt.conf


COPY bin/* /usr/local/bin/


#-------------------------
# The very basic utilities

RUN apt-get update \
    && apt-get-install \
        apt-utils=1.4.9 \
    && apt-get-install \
        bzip2=1.0.6-8.1 \
        curl=7.52.1-5+deb9u8 \
        less=481-2.1 \
        tree=1.7.0-5 \
        unzip=6.0-21 \
        xz-utils=5.2.2-1.2+b1 \
    && apt-get-clean


#===== BEGIN dev tools =====

#--------------------------------
# A nice editor for writing code.

ENV NVIM_HOME=/etc/xdg/nvim
ENV NVIM_RPLUGIN_MANIFEST=${NVIM_HOME}/rplugin.vim
COPY dotfiles/nvim ${NVIM_HOME}/

ARG NEOVIM_URL=https://github.com/neovim/neovim/releases/download/v0.3.4/nvim-linux64.tar.gz

RUN curl -skL --retry 3 ${NEOVIM_URL} | tar xz -C /tmp \
    && mv /tmp/nvim-linux64 /usr/local/sbin/neovim \
    && ln -s /usr/local/sbin/neovim/bin/nvim /usr/local/bin/nvim \
    \
    && apt-get update \
    && apt-get-install \
        git=1:2.11.0-3+deb9u4 \
        xclip=0.12+svn84-4+b1 \
    \
    && pip-install \
        'neovim==0.3.1' \
        'jedi==0.13.2' \
    \
    && chmod -R +rX ${NVIM_HOME} \
    && mkdir -p ${NVIM_HOME}/bundle \
    && git clone --branch 'v0.10.2' --single-branch --depth 1 https://github.com/VundleVim/Vundle.vim.git ${NVIM_HOME}/bundle/Vundle.vim \
    && nvim +PluginInstall +qall \
    && nvim +UpdateRemotePlugins +qall \
    \
    && ln -s $(which nvim) /usr/local/bin/vim \
    \
    && rm -rf ${NVIM_HOME}/bundle/*/doc \
    && rm -rf ${NVIM_HOME}/bundle/*/test \
    && rm -rf ${NVIM_HOME}/bundle/*/.git \
    && rm -rf ${NVIM_HOME}/bundle/*/.gitignore \
    && rm -rf ${NVIM_HOME}/bundle/*/tests \
    \
    && apt-get-remove git \
    && apt-get-clean \
    && rm -rf /tmp/*

ENV EDITOR vim


#---------------
# C/C++ compiler

ENV GCC_VERSION=8.2.0-14
RUN echo "deb http://ftp.us.debian.org/debian testing main contrib non-free" > /etc/apt/sources.list.d/mygccrepo.list \
    && apt-get update \
    && apt-get-install \
        gcc-8=${GCC_VERSION} \
        g++-8=${GCC_VERSION} \
        make=4.2.1-1.2 \
    && ln -s /usr/bin/gcc-8 /usr/bin/gcc \
    && ln -s /usr/bin/g++-8 /usr/bin/g++ \
    && ldconfig \
    \
    && rm -f /etc/apt/sources.list.d/mygccrepo.list \
    && apt-get-clean \
    && rm -rf /tmp/*


COPY dotfiles/ptpython/config.py /home/docker-user/.ptpython/

RUN pip-install  \
        'line_profiler==2.1.2' \
        'memory_profiler==0.55.0' \
        'ptpython==2.0.4' \
        'coverage==4.5.2' \
        'pylint==2.2.2' \
        'mypy==0.660' \
        'yapf==0.25.0' \
    && chown -R docker-user /home/docker-user/.ptpython

# Use `yapf` to format Python code in-place:
#   yapf -ir -vv --no-local-style .


# `pip install line_profiler` fails on Python 3.7.
# See https://github.com/rkern/line_profiler/issues/132
# Hopefully the fix will be integrated soon.

# Installing `line_profiler` needs gcc.
# Use `snakeviz` to view profiling stats.
# `snakeviz` is not installed in this Docker image as it's better
# installed on the hosting machine 'natively'.

# Other useful packages:
#    flake8
#    pudb
#    pyflakes
#    radon


#===== END dev tools =====


#-----------------------------------------
# Jupyter notebook
#
# TODO:
# it is possible that this config file is not loaded by Jupyter Notebook.
ENV JUPYTER_CONFIG_DIR=/etc/xdg/jupyter/
COPY dotfiles/ipython/ipython_config.py /etc/xdg/ipython/profile_default/
COPY dotfiles/jupyter/jupyter_notebook_config.py ${JUPYTER_CONFIG_DIR}

RUN pip-install \
        'ipython==7.2.0' \
        'notebook==5.7.4' \
        'jupyterlab==0.35.4' \
        'ipywidgets==7.4.2' \
    && chmod +r /etc/xdg/ipython/profile_default/ipython_config.py

# `notebook` requires (and will install if not available) ipython, pyzmq, tornado, jinja2 and some other things.

# Decided to not install Spinx; install it in specific images where needed.
# To generate some graphs such as class hierarchy diagrams with `Sphinx`,
# one needs to install the system package `graphviz` and Python package `graphviz`.


# ------------------------------
# Other widely useful packages


RUN pip-install  \
        'boltons==18.0.1' \
        'cytoolz==0.9.0.1' \
        'pytz==2018.9' \
        'requests==2.21.0' \
        \
        'Faker==1.0.2' \
        'pytest==4.1.1' \
        \
        'numpy==1.16.0' \
        'numba==0.42.0'
