set -o errexit
set -o nounset
set -o pipefail

thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd "$( dirname "${thisfile}" )" && pwd )"
bindir="${HOME}/work/bin"


function check_file {
    local f="$1"
    if [[ -f "${f}" ]]; then
        if ! grep -q 'docker run' "${f}"; then
            echo "'${f}' already exists and it doesn't look like a file I created before; don't know how to proceed!"
            return 1
        fi
    fi
    return 0
}


function main {
    if [[ ! -d "${bindir}" ]]; then
        echo "oops! how can you not have directory '${bindir}'? please repair your system and try again!"
        return 1
    fi

    local dockeruser=docker-user
    local dockeruserhome=/home/"${dockeruser}"

    local cmdname="latex"
    local imgname=$(cat "${thisdir}/name")
    local version=$(cat "${thisdir}/version")
    local image="${imgname}:${version}"

    local target="${bindir}/${cmdname}"
    check_file "${target}"

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

