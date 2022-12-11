ARG PARENT=ubuntu:20.04

FROM ${PARENT}
ENV IMAGE_PARENT ${PARENT}
USER root

COPY dotfiles/apt/apt.conf /etc/apt/apt.conf
COPY bin/apt-clean bin/apt-install /bin/apt-remove /bin/apt-update /usr/local/bin/


#-------------------------
# The very basic utilities

RUN apt-update \
    && apt-install \
        apt-utils \
        dialog \
    && echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections \
    && apt-install \
        bzip2 \
        curl \
        iproute2 \
        iputils-ping \
        less \
        make \
        telnet \
        unzip \
        xz-utils \
    && DEBIAN_FRONTEND=noninteractive apt-install tzdata \
    && apt-clean


# `DEBIAN_FRONTEND=noninteractive` suppresses the "geographic area"
# prompt related to `tzdata`.

# `iproute2` provides command `ip`.


#-------------------------------
# misc

COPY dotfiles/bash/bash.bashrc /etc/
RUN chmod +r /etc/bash.bashrc
RUN rm -f /root/.bashrc /root/.profile


#--------------
# Python 3

ENV PYTHON_VERSION=3.8

RUN apt-update \
    && apt-install \
        python3 \
        python3-dev \
        python3-pip \
        python${PYTHON_VERSION}-venv \
    && ln -sf /usr/bin/python3 /usr/bin/python \
    && ln -sf /usr/bin/pip3 /usr/bin/pip \
    && ln -sf /usr/bin/pip3 /usr/bin/pip3.8 \
    && ln -sf /usr/bin/python3-config /usr/bin/python-config \
    && ln -sf /usr/local/lib/python${PYTHON_VERSION} /usr/local/lib/python \
    && ln -sf /usr/local/lib/python${PYTHON_VERSION} /usr/local/lib/python3 \
    && apt-clean

# `python3.8-venv` is required when building Python packages via `build`.

COPY dotfiles/pip/pip.conf /etc/xdg/pip/pip.conf
# This controls behavior of `pip` when we use it to install Python packages.
# In particular, the config instructs `pip` to not save cache, hence reducing size
# of the resultant Docker image.
# Without this config, we can use option `--no-cache-dir`  in each use of `pip`.

COPY bin/pip-install /usr/local/bin/

# RUN pip-install -U pip setuptools
RUN pip-install -U pip

# Enable printing unicode strings:
ENV PYTHONIOENCODING=utf-8


#-----------------------------------------------
# Commonly useful packages for Python code development

RUN pip-install \
        build \
        coverage[toml] \
        flake8 \
        ptpython \
        pudb \
        pylint \
        pylint-exit \
        pytest \
        pytest-asyncio \
        pytest-cov \
        pytest-mock \
        pytest-pudb \
        pytest-xdist \
        toml \
        Flake8-pyproject

    # && ln -s /usr/local/bin/pudb3 /usr/local/bin/pudb

# New problem on 22/9/7:
# somehow /usr/local/bin/ptpython and /usr/local/bin/ptipython lose executable flag
# (what would be added by `chmod +x`) in containers.

COPY dotfiles/ptpython/config.py /etc/xdg/ptpython/
COPY dotfiles/ptpython/ptpython /usr/local/bin/
COPY dotfiles/ptpython/ptipython /usr/local/bin/

# Just to be sure; this is not needed if the source scripts
# are already executable.
RUN chmod +x /usr/local/bin/ptpython /usr/local/bin/ptipython
# `ptipython` requires ipython, which is not installed in this image.


# Use `breakpoint()` to take advantage of the following:
ENV PYTHONBREAKPOINT=pudb.set_trace

# `pudb` needs this:
ENV LC_ALL=C
# refer to: https://stackoverflow.com/questions/14547631/python-locale-error-unsupported-locale-setting

# For pudb's needs:
ENV XDG_CONFIG_HOME /etc/xdg
COPY dotfiles/pudb/pudb.cfg ${XDG_CONFIG_HOME}/pudb/
RUN chmod -R 777 ${XDG_CONFIG_HOME}/pudb/

#-----------------------------------------
# Jupyter notebook
#
# TODO:
# it is possible that this config file is not loaded by Jupyter Notebook.
# ENV JUPYTER_CONFIG_DIR=/etc/xdg/jupyter/
# COPY dotfiles/ipython/ipython_config.py /etc/xdg/ipython/profile_default/
# COPY dotfiles/jupyter/jupyter_notebook_config.py ${JUPYTER_CONFIG_DIR}

# RUN pip-install \
#         'ipywidgets' \
#         'jupyterlab' \
#     && chmod +r /etc/xdg/ipython/profile_default/ipython_config.py

# `jupyterlab` requires (and will install if not available)
# ipython, notebook, pyzmq, tornado, jinja2 and some other things.


#-----------------
# group and user
#

# About permission related to mapped volumes:
# https://techflare.blog/permission-problems-in-bind-mount-in-docker-volume/

RUN useradd --uid 1000 --user-group --groups 100 --home /home/docker-user --create-home --shell /bin/bash docker-user \
    && chown -R docker-user:docker-user /home/docker-user \
    && chmod -R u=rwx,g=rwx,o=r /home/docker-user
# Giving 'g=rwx' to /home/docker-user is a hack around mapped-volume permission issues.
# On Linux, if the host user has uid 1000 and is a member of group 100 ("users"),
# then intra-container code should have the same file access permissions as the host account.
# (Now I don't fully understand this. - 22.10.15)

RUN rm -f /home/docker-user/.bashrc /home/docker-user/.profile

RUN mkdir -p /home/docker-user/mnt/data /home/docker-user/mnt/log /home/docker-user/mnt/tmp \
    && chown -R docker-user:docker-user /home/docker-user/mnt

# In usage, mount a data volume to /home/docker-user/mnt like this
#   docker run --mount source=my-data-volume,target=/home/docker-user/mnt <image> ...
# then there will be no write-permission issues.

ENV DATADIR=/home/docker-user/mnt/data
ENV LOGDIR=/home/docker-user/mnt/log
ENV TMPDIR=/home/docker-user/mnt/tmp

# Env set by `docker run -e X=y ...` will override the same env se here by ENV.


# TODO: use `umask` to give broader permission to users in the same group.

# RUN set -eux; \
# 	apt-update; \
# 	apt-install -y gosu; \
# 	gosu nobody true \
#     apt-clean

# COPY entrypoint.sh /usr/local/bin/entrypoint.sh
# RUN chmod +x /usr/local/bin/entrypoint.sh
# ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# CMD ["/bin/bash"]

WORKDIR /home/docker-user
USER docker-user
