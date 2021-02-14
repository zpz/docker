ARG PARENT=ubuntu:20.10

FROM ${PARENT}
USER root

ENV IMAGE_PARENT ${PARENT}

COPY dotfiles/apt/apt.conf /etc/apt/apt.conf
COPY bin/* /usr/local/bin/


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
        daemontools \
        iproute2 \
        iputils-ping \
        less \
        telnet \
        unzip \
        xz-utils \
    && DEBIAN_FRONTEND=noninteractive apt-install tzdata \
    && apt-clean


# `DEBIAN_FRONTEND=noninteractive` suppresses the "geographic area"
# prompt related to `tzdata`.

# `iproute2` provides command `ip`.
# `daemontools` provides `multilog`, used by our script `logged`.


#-------------------------------
# misc

COPY dotfiles/bash/bash.bashrc /etc/
RUN chmod +r /etc/bash.bashrc
RUN rm -f /root/.bashrc /root/.profile


#-----------------
# group and user
#

RUN groupadd --gid 1000 docker \
    && mkdir -p /home/docker-user \
    && useradd --uid 1000 --gid docker --no-user-group --home /home/docker-user --shell /bin/bash docker-user \
    && chown -R docker-user:docker /home/docker-user \
    && chmod -R u=rwx,g=rwx,o=r /home/docker-user

# Giving 'g=rwx' to /home/docker-user is a hack around mapped-volume permission issues.

USER root


#--------------
# Python 3

ENV PYTHON_VERSION=3.8

RUN apt-update \
    && apt-install \
        python3 \
        python3-dev \
        python3-pip \
    && ln -sf /usr/bin/python3 /usr/bin/python \
    && ln -sf /usr/bin/pip3 /usr/bin/pip \
    && ln -sf /usr/bin/python3-config /usr/bin/python-config \
    && ln -sf /usr/local/lib/python${PYTHON_VERSION} /usr/local/lib/python \
    && ln -sf /usr/local/lib/python${PYTHON_VERSION} /usr/local/lib/python3 \
    && apt-clean

COPY dotfiles/pip/pip.conf /etc/xdg/pip/pip.conf
# This controls behavior of `pip` when we use it to install Python packages.
# In particular, the config instructs `pip` to not save cache, hence reducing size
# of the resultant Docker image.
# Without this config, we can use option `--no-cache-dir`  in each use of `pip`.

RUN pip-install -U pip setuptools

# Enable printing unicode strings:
ENV PYTHONIOENCODING=utf-8


#-----------------------------------------------
# Commonly useful packages for code development

RUN pip-install \
        bandit \
        mypy \
        ptpython \
        pyflakes \
        pudb \
        pytest \
        pytest-asyncio \
        pytest-cov \
        pytest-pudb \
    && ln -s /usr/local/bin/pudb3 /usr/local/bin/pudb

COPY dotfiles/ptpython/config.py /etc/xdg/ptpython/
COPY dotfiles/ptpython/ptpython /usr/local/bin/
COPY dotfiles/ptpython/ptipython /usr/local/bin/

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
ENV JUPYTER_CONFIG_DIR=/etc/xdg/jupyter/
COPY dotfiles/ipython/ipython_config.py /etc/xdg/ipython/profile_default/
COPY dotfiles/jupyter/jupyter_notebook_config.py ${JUPYTER_CONFIG_DIR}

RUN pip-install \
        'ipywidgets' \
        'jupyterlab' \
    && chmod +r /etc/xdg/ipython/profile_default/ipython_config.py

# `jupyterlab` requires (and will install if not available)
# ipython, notebook, pyzmq, tornado, jinja2 and some other things.
