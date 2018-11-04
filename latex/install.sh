set -Eeuo pipefail

thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd "$( dirname "${thisfile}" )" && pwd )"
parentdir="$( dirname ${thisdir} )"
source "${parentdir}/common.sh"

NAME=$(basename $thisdir)
TAG=$(find-newest-tag $NAME)

bindir="${HOME}/work/bin"


function main {
    if [[ ! -d "${bindir}" ]]; then
        echo "oops! how can you not have directory '${bindir}'? please repair your system and try again!"
        return 1
    fi

    local dockeruser=root
    local dockeruserhome=/root

    local cmdname="latex"
    local imgname=$NAME
    local version=$TAG
    local image="${imgname}:${version}"

    local target="${bindir}/${cmdname}"

    echo "installing '${cmdname}' into '${bindir}'"
    cat > "${target}" <<EOF
#!/usr/bin/env bash

# Usage: in the directory that contains the LaTeX source file, type
#
#   $ latex
#
# This is the present script and NOT the LaTeX engine command.
# This will land in within a container, and the current directory
# as well as all children recursively are mapped to the home direcotry
# in the container.
#
# From there, do
#
#   $ tex2pdf source.tex
#
# to process, where 'source.tex' is the source file.

docker run --rm -it \\
    -e TZ=America/Los_Angeles \\
    -v "\$(pwd)":'${dockeruserhome}' \\
    -u ${dockeruser} \\
    -w ${dockeruserhome} \\
    ${image} \\
    \$@
EOF
    chmod +x "${target}"
}

main

