ARG PARENT

FROM ${PARENT}
USER root


COPY dotfiles/apt/apt.conf /etc/apt/apt.conf
COPY bin/apt-update bin/apt-install bin/apt-remove bin/apt-clean /usr/local/bin/


#-------------------------
# The very basic utilities

RUN apt-update \
    && apt-install \
        bzip2 \
        curl \
        less \
        unzip \
        xz-utils \
        apt-utils \
    && apt-clean


#---------------
# C/C++ compiler

RUN apt-update \
    && apt-install \
        gcc-8 \
        g++-8 \
        libc6-dev \
        make \
    && ln -s /usr/bin/gcc-8 /usr/bin/gcc \
    && ln -s /usr/bin/g++-8 /usr/bin/g++ \
    && ln -s /usr/bin/x86_64-linux-gnu-cpp-8 /usr/bin/x86_64-linux-gnu-cpp \
    && ln -s /usr/bin/x86_64-linux-gnu-g++-8 /usr/bin/x86_64-linux-gnu-g++ \
    && ln -s /usr/bin/x86_64-linux-gnu-gcc-8 /usr/bin/x86_64-linux-gnu-gcc \
    && ln -s /usr/bin/x86_64-linux-gnu-gcc-ar-8 /usr/bin/x86_64-linux-gnu-gcc-ar \
    && ln -s /usr/bin/x86_64-linux-gnu-gcc-nm-8 /usr/bin/x86_64-linux-gnu-gcc-nm \
    && ln -s /usr/bin/x86_64-linux-gnu-gcc-ranlib-8 /usr/bin/x86_64-linux-gnu-gcc-ranlib \
    && ln -s /usr/bin/x86_64-linux-gnu-gcov-8 /usr/bin/x86_64-linux-gnu-gcov \
    && ln -s /usr/bin/x86_64-linux-gnu-gcov-dump-8 /usr/bin/x86_64-linux-gnu-gcov-dump \
    && ln -s /usr/bin/x86_64-linux-gnu-gcov-tool-8 /usr/bin/x86_64-linux-gnu-gcov-tool \
    && ldconfig \
    \
    && apt-clean


#--------------
# Python 3

RUN apt-update \
    && apt-install \
        python3 \
        python3-dev \
        python3-pip \
    && ln -s /usr/bin/python3 /usr/bin/python \
    && ln -s /usr/bin/pip3 /usr/bin/pip \
    && ln -s /usr/bin/python3-config /usr/bin/python-config \
    && apt-clean

COPY bin/pip-install /usr/local/bin/
COPY dotfiles/pip/pip.conf /etc/xdg/pip/pip.conf
# This controls behavior of `pip` when we use it to install Python packages.
# In particular, the config instructs `pip` to not save cache, hence reducing size
# of the resultant Docker image.
# Without this config, we can use option `--no-cache-dir`  in each use of `pip`.


#--------------------
# Very commonly useful packages for code development,
# which are not dependencies for code execution.

RUN pip-install \
        'pip' \
        'setuptools'

RUN pip-install  \
        'ptpython' \
        'pylint' \
        'mypy' \
        'black' \
        'pytest'

COPY dotfiles/ptpython/config.py /etc/xdg/ptpython/
COPY dotfiles/ptpython/ptpython /usr/local/bin/
COPY dotfiles/ptpython/ptipython /usr/local/bin/


# Use `yapf` to format Python code in-place:
#   yapf -ir -vv --no-local-style .
#
# Also check out `black`.

# `pip install line_profiler` fails on Python 3.7.
# See https://github.com/rkern/line_profiler/issues/132
# Hopefully the fix will be integrated soon.
#
# Check out alternatives `pprofile` and `pyflame`.
#
# For other profilers, refer to
#  https://devopedia.org/profiling-python-code


# Installing `line_profiler` needs gcc.
# Use `snakeviz` to view profiling stats.
# `snakeviz` is not installed in this Docker image as it's better
# installed on the hosting machine 'natively'.

# Other useful packages:
#    coverage
#    flake8
#    pudb
#    pyflakes
#    radon
#    memory_profiler

# Decided to not install Spinx; install it in specific images where needed.
# To generate some graphs such as class hierarchy diagrams with `Sphinx`,
# one needs to install the system package `graphviz` and Python package `graphviz`.


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


#-----------------
# group and user
#
# Put this section at the end so that the installations above
# do not accidentally assume existence of this particular user.

RUN groupadd --gid 1000 docker \
    && mkdir -p /home/docker-user \
    && useradd --uid 1000 --gid docker --no-user-group --home /home/docker-user --shell /bin/bash docker-user \
    && chown -R docker-user:docker /home/docker-user \
    && chmod -R u=rwx,g=rwx,o=r /home/docker-user

# Giving 'g=rwx' to /home/docker-user is a hack around mapped-volume permission issues.


COPY dotfiles/bash/bash.bashrc /etc/
RUN chmod +r /etc/bash.bashrc

ENV SHELL=/bin/bash