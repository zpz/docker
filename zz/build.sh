thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd "$( dirname "${thisfile}" )" && pwd )"

version=$(cat "${thisdir}"/version)
PARENT="debian:jessie"
NAME=zppz/$(basename "$thisdir"):"${version}"

echo
echo =====================================================
echo Creating Dockerfile for ${NAME}
cat > "${thisdir}/Dockerfile" <<EOF
# Dockerfile for image '${NAME}'

#===========================
# Generated by 'build.sh'.
#
# DO NOT EDIT.
#===========================

FROM ${PARENT}

EOF

cat >> "${thisdir}/Dockerfile" <<'EOF'
USER root


#------------------
# group and user

ENV GROUP=docker-users
ENV USER=docker-user
ENV HOME=/home/docker-user

RUN groupadd --gid 1000 ${GROUP} \
    && mkdir -p ${HOME} \
    && useradd --uid 1000 --gid ${GROUP} --no-user-group --home ${HOME} --shell /bin/bash ${USER} \
    && chown -R ${USER}:${GROUP} ${HOME}


#------------------
# System and basic

# 'curl': about 15 MB.
# 'locales': about 16MB.

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        less \
        locales \
        tree \
    \
    && echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen \
    && locale-gen en_US.UTF-8 \
    && /usr/sbin/update-locale LANG=en_US.UTF-8 \
    \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    && apt-get -y autoremove \
    && apt-get clean

# Locale
#   default is C.UTF-8

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# bash customization
#
ENV SHELL=/bin/bash
COPY ./dotfiles/bash/bashrc /etc/bash.bashrc
RUN chmod +r /etc/bash.bashrc

#-----
# vim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        vim \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    && apt-get -y autoremove \
    && apt-get clean

COPY ./dotfiles/vim/vimrc /etc/vim/vimrc.local
COPY ./dotfiles/vim/vim/ /etc/vim/
RUN chmod -R +rX /etc/vim

ENV EDITOR vim


#------------------
# entrypoint

ENV TINI_VERSION v0.9.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini

ENTRYPOINT ["/usr/bin/tini", "--"]
# TODO: problematic when I terminate some programs within container.


#-----------
# startup

USER ${USER}
WORKDIR ${HOME}

CMD ["/bin/bash"]
EOF

echo
echo Creating image "'${NAME}'"
echo
curl -sL https://github.com/zpz/linux/archive/master.tar.gz -o - |tar xz -C "${thisdir}"
mv "${thisdir}"/linux-master "${thisdir}"/dotfiles
docker build -t "${NAME}" "${thisdir}"
rm -rf "${thisdir}/dotfiles"

