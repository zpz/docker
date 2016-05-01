thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd "$( dirname "${thisfile}" )" && pwd )"
parentdir="$( dirname "$thisdir")"
dockerdir="$parentdir"

source "$dockerdir"/util.sh

version="$(cat "$thisdir"/version)"
TAG="$version"
PARENT="debian:jessie"
NAME=$(basename "$thisdir"):"$TAG"

echo
echo =====================================================
echo Creating Dockerfile for $NAME
cat > "$thisdir"/Dockerfile <<EOF
${HEADER}

FROM ${PARENT}

USER root


#------------------
# group and user

ENV GROUP=docker-users
ENV USER=docker-user
${CREATE_USER}


#----------------------
# System and basic

${INSTALL_BASICS}


#--------------------
# vim

${INSTALL_VIM}


#--------------
# latex

RUN apt-get update \
    && apt-get install -y \
        texlive-full \
        texlive-fonts-recommended \
        texlive-fonts-extra \
        texlive-latex-base \
        texlive-latex-extra \
        texlive-latex-recommended \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    && apt-get -y autoremove \
    && apt-get clean

RUN cd /tmp \
    && curl -sL https://github.com/zpz/latex/archive/master.tar.gz -o - |tar xz \
    && cp latex-master/bin/* /usr/local/bin \
    && chmod +x /usr/local/bin/* \
    && rm -rf /tmp/*


#-----------
# startup

CMD ["/bin/bash"]

USER ${USER}
WORKDIR ${HOME}
EOF


echo
echo building image "$NAME"...
echo
download_dotfiles "$thisdir"
docker build -t "$NAME" "$thisdir"
remove_dotfiles "$thisdir"

