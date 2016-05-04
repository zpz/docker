thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd "$( dirname "${thisfile}" )" && pwd )"
parentdir="$( dirname "$thisdir")"
dockerdir="$parentdir"

source "$dockerdir"/util.sh

version="$(cat "$thisdir"/version)"
TAG="$version"
PARENT="debian:jessie"
NAME=zppz/$(basename "$thisdir"):"$TAG"

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

${INSTALL_SYS_BASICS}


#--------------------
# vim

${INSTALL_VIM}
EOF

cat >> "$thisdir"/Dockerfile <<'EOF'

#--------------
# latex

# textlive-latex-extra provides 'lastpage', among others.

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        texlive-base \
        texlive-fonts-recommended \
        texlive-latex-base \
        texlive-latex-extra \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    && apt-get -y autoremove \
    && apt-get clean

COPY ./bin/ /usr/local/bin/
RUN chmod +x /usr/local/bin/*


#-----------
# startup

USER ${USER}
WORKDIR ${HOME}

CMD ["/bin/bash"]
EOF

curl -sL https://github.com/zpz/latex/archive/master.tar.gz -o - |tar xz -C /tmp/
mv /tmp/latex-master/bin "$thisdir"/bin
build_image "$thisdir" "$NAME"
rm -rf "$thisdir"/bin /tmp/latex-master

