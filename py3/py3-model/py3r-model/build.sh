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
${HEADER}

# In the intended use cases of this image,
# Python is the primary deveopment environment,
# whereas R is called from Python to make use of certain
# specialized R packages.
#
# One-way Python/R inter-op, namely calling R from Python,
# is provisioned by the Package package 'rpy2'.

FROM ${PARENT}

USER root


#-------------
# R

${INSTALL_R_BASICS}


#-------------
# startup

USER ${USER}
WORKDIr ${HOME}

CMD ["/bin/bash"]
EOF


build_image "$thisdir" "$NAME"

