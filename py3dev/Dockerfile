ARG PARENT

FROM ${PARENT}
USER root


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
    && apt-get install -y --no-install-recommends --allow-unauthenticated \
        git \
        xclip \
    \
    && pip install --no-cache-dir --upgrade \
        neovim \
        jedi \
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
    && apt-get purge -y --auto-remove \
        git \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/*

ENV EDITOR vim


#-----------------------------------------
# Jupyter notebook
#
# TODO:
# it is possible that this config file is not loaded by Jupyter Notebook.
ENV JUPYTER_CONFIG_DIR=/etc/xdg/jupyter/
COPY dotfiles/ipython/ipython_config.py /etc/xdg/ipython/profile_default/
COPY dotfiles/jupyter/jupyter_notebook_config.py ${JUPYTER_CONFIG_DIR}

RUN pip install --no-cache-dir --upgrade \
        'ipython' \
        'notebook' \
        'jupyterlab' \
    && chmod +r /etc/xdg/ipython/profile_default/ipython_config.py

# `notebook` requires (and will install if not available) ipython, pyzmq, tornado, jinja2 and some other things.

# Decided to not install Spinx; install it in specific images where needed.
# To generate some graphs such as class hierarchy diagrams with `Sphinx`,
# one needs to install the system package `graphviz` and Python package `graphviz`.

# Other useful packages:
#    boltons
#    Faker
#    flake8
#    pudb
#    pyflakes
#    radon


#---------------
# C/C++ compiler

RUN echo "deb http://ftp.us.debian.org/debian testing main contrib non-free" > /etc/apt/sources.list.d/mygccrepo.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        gcc-8 \
        g++-8 \
        make \
    && ln -s /usr/bin/gcc-8 /usr/bin/gcc \
    && ln -s /usr/bin/g++-8 /usr/bin/g++ \
    && ldconfig \
    \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    && rm -f /etc/apt/sources.list.d/mygccrepo.list


