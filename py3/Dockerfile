ARG PARENT


FROM ${PARENT}
ENV IMAGE_PARENT=${PARENT}
USER root


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
