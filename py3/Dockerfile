ARG PARENT


FROM ${PARENT}
ENV IMAGE_PARENT=${PARENT}
USER root


#-----------------
# group and user
#

# About permission related to mapped volumes:
# https://techflare.blog/permission-problems-in-bind-mount-in-docker-volume/

# Remove the user `ubuntu` in ubuntu 24.04 base image
# https://askubuntu.com/questions/1513927/ubuntu-24-04-docker-images-now-includes-user-ubuntu-with-uid-gid-1000
RUN touch /var/mail/ubuntu && chown ubuntu /var/mail/ubuntu && userdel -r ubuntu

RUN useradd --uid 1000 --user-group --groups 100 --home /home/docker-user --create-home --shell /bin/bash docker-user \
    && chown -R docker-user:docker-user /home/docker-user \
    && chmod -R u=rwx,g=rwx,o=r /home/docker-user \
    && rm -f /home/docker-user/.bashrc /home/docker-user/.profile
# Giving 'g=rwx' to /home/docker-user is a hack around mapped-volume permission issues.
# On Linux, if the host user has uid 1000 and is a member of group 100 ("users"),
# then intra-container code should have the same file access permissions as the host account.
# (Now I don't fully understand this. - 22.10.15)
# In this docker stack of utilities, this is mainly for volume-mapping source code 
# so that minor edits to them within the container will have exactly the same effect
# as editing them on the host.


RUN mkdir -p /home/docker-user/mnt/data /home/docker-user/mnt/log /home/docker-user/mnt/tmp \
    && chown -R docker-user:docker-user /home/docker-user/mnt \
    && mkdir -p /tmp

ENV DATADIR=/home/docker-user/mnt/data
ENV LOGDIR=/home/docker-user/mnt/log
ENV TMPDIR=/tmp

# Mount a data volume to /home/docker-user/mnt like this:
#
#   docker run --mount source=my-data-volume,target=/home/docker-user/mnt <image> ...

# Env set by `docker run -e DATADIR=... ` will override the same-named env set here by `ENV ...`.


# # TODO: use `umask` to give broader permission to users in the same group.
# RUN set -eux; \
# 	apt-update; \
# 	apt-install -y gosu; \
# 	gosu nobody true \
#     apt-clean
#
# COPY entrypoint.sh /usr/local/bin/entrypoint.sh
# RUN chmod +x /usr/local/bin/entrypoint.sh
# ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]



#-------------------------
# The very basic utilities

COPY dotfiles/apt/apt.conf /etc/apt/apt.conf
COPY bin/apt-clean bin/apt-install bin/apt-remove bin/apt-update bin/apt-upgrade /usr/local/bin/



RUN apt-update && apt-upgrade \
    && apt-install \
        apt-utils \
        dialog \
    && echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections \
    && apt-install \
        bzip2 \
        curl \
        htop \
        iproute2 \
        iputils-ping \
        less \
        telnet \
        tree \
        unzip \
        xz-utils \
    && DEBIAN_FRONTEND=noninteractive apt-install tzdata \
    && apt-install --reinstall ca-certificates && update-ca-certificates \
    && apt-clean


# `DEBIAN_FRONTEND=noninteractive` suppresses the "geographic area"
# prompt related to `tzdata`.

# `iproute2` provides command `ip`.

# For building, install
#    make gcc g++ libc6 libc6-dev


#-------------------------------
# misc

# COPY dotfiles/bash/bash.bashrc /etc/
RUN curl https://raw.githubusercontent.com/zpz/dotfiles/refs/heads/master/bash/bashrc -o /etc/bash.bashrc
RUN chmod +r /etc/bash.bashrc
RUN rm -f /root/.bashrc /root/.profile


#--------------
# Python 3

ARG PYTHON_VERSION
ENV PYTHON_VERSION=${PYTHON_VERSION}

RUN apt-update \
    && apt-install \
        python${PYTHON_VERSION} \
        python3-dev \
        python3-pip \
        python${PYTHON_VERSION}-venv \
    && ln -sf /usr/bin/python${PYTHON_VERSION} /usr/bin/python3 \
    && ln -sf /usr/bin/python3 /usr/bin/python \
    && ln -sf /usr/bin/python3-config /usr/bin/python-config \
    && ln -sf /usr/local/lib/python${PYTHON_VERSION} /usr/local/lib/python3 \
    && ln -sf /usr/local/lib/python3 /usr/local/lib/python \
    \
    && apt-install make gcc g++ libc6 libc6-dev \
    && apt-clean

# `python3.x-venv` is required when building Python packages via `build`.

COPY dotfiles/pip/pip.conf /etc/xdg/pip/pip.conf
# This controls behavior of `pip` when we use it to install Python packages.
# In particular, the config instructs `pip` to not save cache, hence reducing size
# of the resultant Docker image.
# Without this config, we can use option `--no-cache-dir`  in each use of `pip`.

COPY bin/pip-install /usr/local/bin/

# RUN pip-install -U pip setuptools

# Enable printing unicode strings:
ENV PYTHONIOENCODING=utf-8

# Some extension packages need to be built.
RUN apt-install make gcc g++ libc6 libc6-dev && apt-clean


#-----------------------------------------
# Jupyter notebook
#

RUN pip-install 'ipywidgets' 'jupyterlab'

# `jupyterlab` requires (and will install if not available)
# ipython, notebook, pyzmq, tornado, jinja2 and some other things.


# TODO:
# it is possible that this config file is not loaded by Jupyter Notebook.
ENV JUPYTER_CONFIG_DIR=/etc/xdg/jupyter
COPY dotfiles/ipython/ipython_config.py /etc/xdg/ipython/profile_default/
COPY dotfiles/jupyter/jupyter_notebook_config.py ${JUPYTER_CONFIG_DIR}/

RUN chmod +r /etc/xdg/ipython/profile_default/ipython_config.py \
    ${JUPYTER_CONFIG_DIR}/jupyter_notebook_config.py

ENV JUPYTER_DATA_DIR=/tmp/.jupyter/data
ENV JUPYTER_RUNTIME_DIR=/tmp/.jupyter/runtime
ENV JUPYTERLAB_WORKSPACES_DIR=/tmp/.jupyter/workspaces
ENV JUPYTERLAB_SETTINGS_DIR=/tmp/.jupyter/settings




#-----------------------------------------------
# Commonly useful packages for Python code development

RUN pip-install \
        build \
        coverage[toml] \
        ptpython \
        pudb \
        pytest \
        pytest-cov \
        pytest-asyncio \
        toml

    # && ln -s /usr/local/bin/pudb3 /usr/local/bin/pudb

COPY dotfiles/ptpython/config.py /etc/xdg/ptpython/
# COPY dotfiles/ptpython/ptpython /usr/local/bin/
# COPY dotfiles/ptpython/ptipython /usr/local/bin/

# Just to be sure; this is not needed if the source scripts
# are already executable.
# RUN chmod +x /usr/local/bin/ptpython /usr/local/bin/ptipython
# `ptipython` requires ipython.


# Use `breakpoint()` to take advantage of the following:
ENV PYTHONBREAKPOINT=pudb.set_trace

# `pudb` needs this:
ENV LC_ALL=C
# refer to: https://stackoverflow.com/questions/14547631/python-locale-error-unsupported-locale-setting

# For pudb's needs:
ENV XDG_CONFIG_HOME=/etc/xdg
COPY dotfiles/pudb/pudb.cfg ${XDG_CONFIG_HOME}/pudb/
RUN chmod -R 777 ${XDG_CONFIG_HOME}/pudb/



######################


USER docker-user
WORKDIR /home/docker-user
CMD ["bash"]
