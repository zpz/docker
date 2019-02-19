# On Linux, run this script with `sudo`.
# On Mac, run w/o `sudo`.

# Where to put neovim config files?
# There is some confusion.
# 
# System-wide, there is /etc/xdg/nvim/ and /usr/local/share/nvim/.
# 
# User local, on Mac there is ~/.local/share/nvim/ and ~/.config/nvim/;
# on Linux there is ~/.local/share/nvim/.
#
# On Linux, do not use ~/.config/nvim.
#
# This script installs things locally for the current user.

# If the installed `nvim` is not working properly,
# check the installed `init.vim` file.
# Also check that the installed `$NVIM_CMD` is on the system path.

thisfile="$0"
thisdir="$( cd $( dirname ${thisfile} ) && pwd )"

platform=$(uname -s)
if [[ ${platform} != Linux ]] && [[ ${platform} != Darwin ]]; then
    echo "Platform '${platform}' is not supported."
    exit 1
fi

if [[ "${platform}" == Linux ]]; then
    NVIM_HOME=/etc/xdg/nvim
else
    NVIM_HOME=~/.local/share/nvim
    NVIM_CFG=~/.config/nvim
fi
NVIM_CMD=/usr/local/bin/nvim

NVIM_RPLUGIN_MANIFEST=${NVIM_HOME}/rplugin.vim

if [ -d ${NVIM_HOME} ]; then
    echo "Directory ${NVIM_HOME} exists, suggesting 'neovim' is installed. Please un-install first."
    exit 1
fi

if [[ "${platform}" == Darwin ]] && [ -d ${NVIM_CFG} ]; then
    echo "Directory ${NVIM_CFG} exists, suggesting 'neovim' is installed. Please un-install first."
    exit 1
fi

if [ -f ${NVIM_CMD} ]; then
    echo "${NVIM_CMD} exists. Please un-install first."
    exit 1
fi


function clean-up {
    rm -rf ${NVIM_HOME} ${NVIM_CFG}
    rm -f ${NVIM_CMD}
}


function check-status {
    status=$1
    if [[ ${status} != 0 ]]; then
        clean-up
        exit ${status}
    fi
}


if [[ "${platform}" == Linux ]]; then
    # NEOVIM_URL=https://github.com/neovim/neovim/releases/download/v0.3.4/nvim-linux64.tar.gz
    # curl -skL --retry 3 ${NEOVIM_URL} | tar xz -C /tmp \
    #     && mkdir -p /usr/local/sbin \
    #     && mv /tmp/nvim-linux64 /usr/local/sbin/neovim \
    #     && ln -s /usr/local/sbin/neovim/bin/nvim /usr/local/bin/nvim

    NEOVIM_URL=https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage
    curl -kL --retry 3 ${NEOVIM_URL} -o ${NVIM_CMD} \
        && chmod +x ${NVIM_CMD}
else
    brew install neovim
fi

set -x

check-status $?

mkdir -p ${NVIM_HOME} \
    && cp -rf "${thisdir}/dotfiles/"* ${NVIM_HOME}/ \
    && chmod -R +rX ${NVIM_HOME} \
    && if [[ ${platform} == Darwin ]]; then mv ${NVIM_HOME}/init.vim ${NVIM_CFG}/ ; fi

check-status $?


mkdir -p ${NVIM_HOME}/bundle \
    && git clone --branch 'v0.10.2' --single-branch --depth 1 https://github.com/VundleVim/Vundle.vim.git ${NVIM_HOME}/bundle/Vundle.vim \
    && nvim +PluginInstall +qall \
    && nvim +UpdateRemotePlugins +qall \
    \
    && rm -rf ${NVIM_HOME}/bundle/*/doc \
    && rm -rf ${NVIM_HOME}/bundle/*/test \
    && rm -rf ${NVIM_HOME}/bundle/*/.git \
    && rm -rf ${NVIM_HOME}/bundle/*/.gitignore \
    && rm -rf ${NVIM_HOME}/bundle/*/tests

check-status $?

if [[ ${USER} == root ]]; then
    u=${HOME##*/}
    chown -R $u ${HOME}/.local/share/nvim
fi

pip3 install --no-cache-dir pynvim jedi

# apt-get install --no-install-recommends --no-upgrade -y xclip
