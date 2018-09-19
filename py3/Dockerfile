ARG PARENT

FROM ${PARENT}
USER root

#------------------
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

#-------------------------
# The very basic utilities

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bzip2 \
        curl \
        less \
        tree \
        unzip \
        xz-utils \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/*

COPY dotfiles/bash/bashrc /etc/bash.bashrc
RUN chmod +r /etc/bash.bashrc


ENV SHELL=/bin/bash


#------------------
# editor

ENV NVIM_HOME=/etc/xdg/nvim
ENV NVIM_RPLUGIN_MANIFEST=${NVIM_HOME}/rplugin.vim
COPY dotfiles/nvim ${NVIM_HOME}/

ARG NEOVIM_URL=https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.tar.gz

RUN curl -skL --retry 3 ${NEOVIM_URL} | tar xz -C /tmp \
    && mv /tmp/nvim-linux64 /usr/local/sbin/neovim \
    && ln -s /usr/local/sbin/neovim/bin/nvim /usr/local/bin/nvim \
    \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
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



CMD ["/bin/bash"]
WORKDIR /