thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd "$( dirname "${thisfile}" )" && pwd )"
parentdir="$(dirname "$thisdir")"
dockerdir="$(expr "$thisdir" : '\(.*/docker\).*')"

source "$dockerdir"/util.sh

version=$(cat "$thisdir"/version)
TAG=$version
PARENT="python:3.5.1-slim"
NAME=zppz/$(basename "$thisdir"):"$TAG"

echo
echo ==============================================
echo creating Dockerfile for $NAME...
cat > "$thisdir"/Dockerfile <<EOF
${HEADER}

FROM ${PARENT}

USER root


#------------------
# group and user

ENV GROUP=docker-users
ENV USER=docker-user
${CREATE_USER}


#------------------
# System and basic

${INSTALL_SYS_BASICS}


#------------------
# entrypoint

${INSTALL_TINI}


#------------------
# Python

# offical Python image gets the link 'python-config' wrong.
RUN ln -s -f /usr/local/bin/python3-config /usr/local/bin/python-config

${INSTALL_PY_BASICS}


#---------------
# startup

USER \${USER}
WORKDIR \${HOME}

CMD ["python"]
EOF


build_image "$thisdir" "$NAME"

