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

# apt-utils=1.4.9

RUN apt-update \
    && apt-install \
        bzip2=1.0.6-8.1 \
        curl=7.52.1-5+deb9u9 \
        less=481-2.1 \
        tree=1.7.0-5 \
        unzip=6.0-21 \
        xz-utils=5.2.2-1.2+b1 \
    && apt-clean


#===== BEGIN dev tools =====

#---------------
# C/C++ compiler

# ENV GCC_VERSION=8.2.0-15
# RUN echo "deb http://ftp.us.debian.org/debian testing main contrib non-free" > /etc/apt/sources.list.d/mygccrepo.list \
#     && apt-update \
#     && apt-install \
#         gcc-8=${GCC_VERSION} \
#         g++-8=${GCC_VERSION} \
#         make=4.2.1-1.2 \
#     && ln -s /usr/bin/gcc-8 /usr/bin/gcc \
#     && ln -s /usr/bin/g++-8 /usr/bin/g++ \
#     && ldconfig \
#     \
#     && rm -f /etc/apt/sources.list.d/mygccrepo.list \
#     && apt-clean \
#     && rm -rf /tmp/*

ENV GCC_VERSION=6.3.0-18+deb9u1
RUN apt-update \
    && apt-install \
        gcc-6=${GCC_VERSION} \
        g++-6=${GCC_VERSION} \
        libc6-dev=2.24-11+deb9u4 \
        make=4.1-9.1 \
    && ln -s /usr/bin/gcc-6 /usr/bin/gcc \
    && ln -s /usr/bin/g++-6 /usr/bin/g++ \
    && ldconfig \
    \
    && apt-clean

# Install `astyle` instead of `clang-format`, because
# I don't like the latter's dependency on LLVM.

# ARG ASTYLE_VERSION=3.1
# ARG ASTYLE_URL=https://sourceforge.net/projects/astyle/files/astyle/astyle%20${ASTYLE_VERSION}/astyle_${ASTYLE_VERSION}_linux.tar.gz/download

# RUN curl -skL --retry 3 ${ASTYLE_URL} | tar xz -C /tmp \
#     && ( cd /tmp/astyle/build/gcc && make && mv bin/astyle /usr/local/bin)

# A reasonable way to use astyle:
#
# astyle --style=kr --indent-modifiers --indent-switches --pad-oper --add-braces --preserve-date --recursive --suffix=none ./"*.h, *.cc, *.hpp, *.cpp"


COPY dotfiles/ptpython/config.py /home/docker-user/.ptpython/

RUN pip-install  \
        'ptpython==2.0.4' \
        'pylint==2.2.2' \
        'mypy==0.670' \
        'yapf==0.26.0' \
        'black==18.9b0' \
    && chown -R docker-user /home/docker-user/.ptpython

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


# ------------------------------
# Other widely useful packages


RUN pip-install  \
        'boltons==18.0.1' \
        'cytoolz==0.9.0.1' \
        'requests==2.21.0' \
        \
        'Faker==1.0.2' \
        'pytest==4.1.1' \
        \
        'numpy==1.16.0' \
        'scipy==1.2.0' \
        'numba==0.42.0'
