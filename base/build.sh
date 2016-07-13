set -o nounset
set -o pipefail

thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd "$( dirname "${thisfile}" )" && pwd )"

version=$(cat "${thisdir}"/version)
PARENT="debian:8.5"
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
WORKDIR /


#------------------
# group and user

RUN groupadd --gid 1000 docker-users \
    && mkdir -p /home/docker-user \
    && useradd --uid 1000 --gid docker-users --no-user-group --home /home/docker-user --shell /bin/bash docker-user \
    && chown -R docker-user:docker-users /home/docker-user


#------------------
# System and basic

# 'curl': about 15 MB.
# 'locales': about 16MB.
# 'vim': about 20MB.

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        less \
        locales \
        tree \
        vim \
    \
    && echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen \
    && locale-gen en_US.UTF-8 \
    && /usr/sbin/update-locale LANG=en_US.UTF-8 \
    \
    && curl -skL https://github.com/zpz/linux/archive/master.tar.gz |tar xz -C /tmp/ \
    && mv /tmp/linux-master /tmp/dotfiles \
    && cp /tmp/dotfiles/bash/bashrc /etc/bash.bashrc \
    && chmod +r /etc/bash.bashrc \
    && mkdir -p /etc/vim \
    && cp /tmp/dotfiles/vim/vimrc /etc/vim/vimrc.local \
    && cp -r /tmp/dotfiles/vim/vim/* /etc/vim/ \
    && chmod -R +rX /etc/vim \
    \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    && apt-get -y autoremove \
    && apt-get clean

# Locale
#   default is C.UTF-8

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ENV SHELL=/bin/bash
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

CMD ["/bin/bash"]
EOF

echo
echo Creating image "'${NAME}'"
echo
docker build -t "${NAME}" "${thisdir}"

