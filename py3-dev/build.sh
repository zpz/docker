thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd "$( dirname "${thisfile}" )" && pwd )"
parentdir="$(dirname "$thisdir")"
dockerdir="$parentdir"

source "$dockerdir"/util.sh

version="$(cat "$parentdir"/py3/version)"
TAG=$version
PARENT="py3:"$TAG
NAME=$(basename "$thisdir"):"$TAG"

echo
echo ==============================================
echo creating Dockerfile for $NAME...
cat > "$thisdir"/Dockerfile <<EOF
${HEADER}

FROM ${PARENT}

USER root


#------------------
# development tools

${INSTALL_VIM}

${INSTALL_GIT}

${INSTALL_PY_DEV}


#-------------
# startup

USER ${USER}
WORKDIR ${HOME}
EOF


echo
echo building image "$NAME"...
echo
download_dotfiles "$thisdir"
docker build -t "$NAME" "$thisdir"
remove_dotfiles "$thisdir"

