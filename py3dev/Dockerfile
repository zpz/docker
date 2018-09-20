ARG PARENT

FROM ${PARENT}
USER root


# The section below installs important tools for Python development, such as
# documentation, testing, code analysis, code formatting,
# IPython, Jupyter Notebook.

# TODO:
# it is possible that this config file is not loaded by Jupyter Notebook.
ENV JUPYTER_CONFIG_DIR=/etc/xdg/jupyter/
COPY dotfiles/ipython/ipython_config.py /etc/xdg/ipython/profile_default/
COPY dotfiles/jupyter/jupyter_notebook_config.py ${JUPYTER_CONFIG_DIR}
COPY dotfiles/ptpython/config.py /home/docker-user/.ptpython/

RUN pip install --no-cache-dir --upgrade \
        'coverage' \
        'mypy' \
        'ptpython' \
        'pylint' \
        'pytest' \
        'Sphinx' \
        'yapf' \
    && pip install --no-cache-dir --upgrade \
        'ipython' \
        'notebook' \
        'jupyterlab' \
    && chmod +r /etc/xdg/ipython/profile_default/ipython_config.py \
    && chown -R docker-user /home/docker-user/.ptpython

# Use `yapf` to format Python code in-pace:
#   yapf -ir -vv --no-local-style .

# `notebook` requires (and will install if not available) ipython, pyzmq, tornado, jinja2 and some other things.

# To generate some graphs such as class hierarchy diagrams with `Sphinx`,
# one needs to install the system package `graphviz` and Python package `graphviz`.

# Other useful packages:
#    boltons
#    Faker
#    flake8
#    ipdb
#    pudb
#    pyflakes
#    radon

RUN echo "deb http://ftp.us.debian.org/debian testing main contrib non-free" > /etc/apt/sources.list.d/mygccrepo.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        gcc-8 \
        g++-8 \
        make \
    && ln -s /usr/bin/gcc-8 /usr/bin/gcc \
    && ln -s /usr/bin/g++-8 /usr/bin/g++ \
    \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    && rm -f /etc/apt/sources.list.d/mygccrepo.list \
    \
    && pip install --no-cache-dir --upgrade \
        'line_profiler' \
        'memory_profiler'

# Installing `line_profiler` needs gcc.
# Use `snakeviz` to view profiling stats.
# `snakeviz` is not installed in this Docker image as it's better
# installed on the hosting machine 'natively'.


RUN pip install --no-cache-dir --upgrade \
        'cytoolz' \
        'dask' \
        'distributed'