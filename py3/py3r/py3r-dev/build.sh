thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd "$( dirname "${thisfile}" )" && pwd )"
parentdir="$(dirname "$thisdir")"
dockerdir="$(dirname "$(dirname "$parentdir")")"

source "$dockerdir"/util.sh

version=$(cat "$thisdir"/version)
parent_version=$(cat "$parentdir"/version)
if [[ "$version" < "$parent_version" ]]; then
    version=$parent_version
    echo "$parent_version" > "$thisdir"/version
fi

PARENT=zppz/$(basename "$parentdir"):"$parent_version"
NAME=zppz/$(basename "$thisdir"):"$version"

echo
echo =====================================================
echo Creating Dockerfile for $NAME
cat > "$thisdir"/Dockerfile <<EOF
${HEADER}

FROM ${PARENT}

USER root


#-------------------
# development tools

${INSTALL_VIM}

${INSTALL_GIT}

${INSTALL_PY_DEV}

${INSTALL_R_DEV}


#-------------
# startup

USER ${USER}
WORKDIR ${HOME}

CMD ["/bin/bash"]
EOF


build_image "$thisdir" "$NAME"
