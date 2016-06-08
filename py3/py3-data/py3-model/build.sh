thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd "$( dirname "${thisfile}" )" && pwd )"
parentdir="$(dirname "$thisdir")"
dockerdir="$(expr "$thisdir" : '\(.*/docker\).*')"

source "$dockerdir"/util.sh

version=$(cat "$thisdir"/version)
parent_version=$(cat "$parentdir"/version)
if [[ "$version" < "$parent_version" ]]; then
    echo "$parent_version" > "$thisdir"/version
    version=$parent_version
fi

PARENT=zppz/$(basename "$parentdir"):"$parent_version"
NAME=zppz/$(basename "$thisdir"):"$version"

echo
echo =====================================================
echo Creating Dockerfile for $NAME
cat > "$thisdir"/Dockerfile <<EOF
# Dockerfile for image '${NAME}'

${HEADER}

FROM ${PARENT}

USER root


#--------------------------
# Python modeling packages

${INSTALL_PY_MODEL}

#-------------
# startup

USER \${USER}
WORKDIr \${HOME}

CMD ["python"]
EOF


build_image "$thisdir" "$NAME"

