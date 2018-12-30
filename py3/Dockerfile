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
COPY pip-install /usr/local/bin

# COPY dotfiles/apt/apt.conf /etc/apt/apt.conf
COPY apt-get-install /usr/local/bin
COPY apt-get-remove /usr/local/bin
COPY apt-get-clean /usr/local/bin


#-------------------------
# The very basic utilities

RUN apt-get update \
    && apt-get-install --allow-unauthenticated \
        apt-utils \
    && apt-get-install --allow-unauthenticated \
        bzip2 \
        curl \
        less \
        tree \
        unzip \
        xz-utils \
    && apt-get-clean


#===== BEGIN dev tools =====

#--------------------------------
# A nice editor for writing code.

ENV NVIM_HOME=/etc/xdg/nvim
ENV NVIM_RPLUGIN_MANIFEST=${NVIM_HOME}/rplugin.vim
COPY dotfiles/nvim ${NVIM_HOME}/

ARG NEOVIM_URL=https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.tar.gz

RUN curl -skL --retry 3 ${NEOVIM_URL} | tar xz -C /tmp \
    && mv /tmp/nvim-linux64 /usr/local/sbin/neovim \
    && ln -s /usr/local/sbin/neovim/bin/nvim /usr/local/bin/nvim \
    \
    && apt-get update \
    && apt-get-install --allow-unauthenticated \
        git \
        xclip \
    \
    && pip-install \
        'neovim' \
        'jedi' \
    \
    && chmod -R +rX ${NVIM_HOME} \
    && mkdir -p ${NVIM_HOME}/bundle \
    && git clone https://github.com/VundleVim/Vundle.vim.git ${NVIM_HOME}/bundle/Vundle.vim \
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

RUN echo "deb http://ftp.us.debian.org/debian testing main contrib non-free" > /etc/apt/sources.list.d/mygccrepo.list \
    && apt-get update \
    && apt-get-install \
        gcc-8 \
        g++-8 \
        make \
    && ln -s /usr/bin/gcc-8 /usr/bin/gcc \
    && ln -s /usr/bin/g++-8 /usr/bin/g++ \
    && ldconfig \
    \
    && rm -f /etc/apt/sources.list.d/mygccrepo.list \
    && apt-get-clean \
    && rm -rf /tmp/*


COPY dotfiles/ptpython/config.py /home/docker-user/.ptpython/

RUN pip-install  \
        'line_profiler' \
        'memory_profiler' \
        'ptpython' \
        'coverage' \
        'pylint' \
        'mypy' \
        'twine' \
        'readme-renderer[md]' \
        'yapf' \
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
        'ipython' \
        'notebook' \
        'jupyterlab' \
        'ipywidgets' \
    && chmod +r /etc/xdg/ipython/profile_default/ipython_config.py

# `notebook` requires (and will install if not available) ipython, pyzmq, tornado, jinja2 and some other things.

# Decided to not install Spinx; install it in specific images where needed.
# To generate some graphs such as class hierarchy diagrams with `Sphinx`,
# one needs to install the system package `graphviz` and Python package `graphviz`.


# ------------------------------
# Other useful packages


RUN pip-install  \
        'boltons' \
        'cytoolz' \
        'pytz' \
        'requests' \
        \
        'Faker' \
        'pytest' \
        \
        'numpy' \
        'pandas' \
        'scipy' \
        \
        'distributed' \
        'dask'
