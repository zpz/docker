thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd "$( dirname "${thisfile}" )" && pwd )"
parentdir="$(dirname "$thisdir")"
dockerdir="$(dirname "$parentdir")"

source "$dockerdir"/util.sh

version="$(cat "$thisdir"/version)"
parent_version="$(cat "$parentdir"/version)"
if [[ "$parent_version" > "$version" ]]; then
    version="$parent_version"
    echo "$version" > "$thisdir"/version
fi

PARENT=zppz/$(basename "$parentdir"):$parent_version
NAME=zppz/$(basename "$thisdir"):"$version"

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

CMD ["python"]
EOF


build_image "$thisdir" "$NAME"

