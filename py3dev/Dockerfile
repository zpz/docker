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
    && rm -f /etc/apt/sources.list.d/mygccrepo.list \
    \
    && pip install --no-cache-dir --upgrade \
        'memory_profiler'

# `pip install line_profiler` fails on Python 3.7.
# See https://github.com/rkern/line_profiler/issues/132
# Hopefully the fix will be integrated soon.

# Installing `line_profiler` needs gcc.
# Use `snakeviz` to view profiling stats.
# `snakeviz` is not installed in this Docker image as it's better
# installed on the hosting machine 'natively'.


#------------------------------
# For writing Python extensions


RUN pip install --no-cache-dir --upgrade \
        'cython' \
        'cffi' \
        'pybind11' \
        'llvmlite' \
        'numba'

# `pybind11` header files are stored in /usr/local/include/python3.6m/pybind11/

# Install `astyle` instead of `clang-format`, because
# I don't like the latter's dependency on LLVM.

ARG ASTYLE_VERSION=3.1
ARG ASTYLE_URL=https://sourceforge.net/projects/astyle/files/astyle/astyle%20${ASTYLE_VERSION}/astyle_${ASTYLE_VERSION}_linux.tar.gz/download

RUN curl -skL --retry 3 ${ASTYLE_URL} | tar xz -C /tmp \
    && ( cd /tmp/astyle/build/gcc && make && mv bin/astyle /usr/local/bin)

# A reasonable way to use astyle:
#
# astyle --style=kr --indent-modifiers --indent-switches --pad-oper --add-braces --preserve-date --recursive --suffix=none ./"*.h, *.cc, *.hpp, *.cpp"

# A reasonable way to use clang-format (not installed):
#
# find ./ -iname *.h -o -iname *.cc -iname *.hpp -iname *.cpp \
#    | xargs \
#    clang-format -style="{BasedOnStyle: webkit, IndentWidth: 4, AccessModifierOffset: -2}" -i


#######################
### installing LLVM ###
#######################

# # Have had issues with installing LLVM.
# #
# # Refer to this page:
# #   https://apt.llvm.org
# #
# # This post may be informative:
# #  https://solarianprogrammer.com/2017/12/14/clang-in-docker-container-cpp-17-development/
# #
# # This page lists downloads, including prebuilt binaries (5.0.1 has debian; earlier versions do not):
# #  http://releases.llvm.org/download.html
# #
# # This page might be useful as well:
# #  https://llvm.org/docs/Docker.html
# 
# ENV LLVM_VERSION 5.0
# ENV LLVM_DESKTOP stretch
# 
# # This line used to be useful, but not any more.
# #RUN apt-key adv --keyserver ha.pool.sks-keyservers.net --recv 15CF4D18AF4F7421 \
# 
# # `gnupg2` is needed to use `apt-key add -`.
# # `gnupg2` was removed in debian stretch.
# 
# RUN curl -skL --retry 3 http://apt.llvm.org/llvm-snapshot.gpg.key \
#         | apt-key add - \
#     && echo "deb http://apt.llvm.org/${LLVM_DESKTOP}/ llvm-toolchain-${LLVM_DESKTOP}-${LLVM_VERSION} main" > /etc/apt/sources.list.d/llvm.list \
#     && apt-get update \
#     && apt-get install -y --no-install-recommends \
#         libllvm${LLVM_VERSION} \
#         llvm-${LLVM_VERSION} \
#         llvm-${LLVM_VERSION}-dev \
#         clang-format-${LLVM_VERSION} \
#     && rm -rf /var/lib/apt/lists/* \
#     \
#     && ln -s /usr/bin/clang-format-${LLVM_VERSION} /usr/bin/clang-format \
#     && curl --retry 3 https://github.com/catchorg/Catch2/releases/download/v2.1.2/catch.hpp > /usr/local/include/catch.hpp \
#     && export LLVM_CONFIG=/usr/lib/llvm-${LLVM_VERSION}/bin/llvm-config

# Other packages often useful for software development:
#    autoconf=2.69-8 \
#    automake=1:1.14.1-4+deb8u1 \
#    binutils=2.25-5
#    libtool=2.4.2-1.11 \
#    zlib1g-dev=1:1.2.8.dfsg-2+b1 \
#
# `binutils` contains `gprof`.
# To use `gprof`, use option `-pg` during both compiling and linking.

