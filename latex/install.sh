set -Eeuo pipefail

bindir="${HOME}/work/bin"


function main {
    if [[ ! -d "${bindir}" ]]; then
        echo "oops! how can you not have directory '${bindir}'? please repair your system and try again!"
        return 1
    fi

    local cmdname="latex"
    local target="${bindir}/${cmdname}"

    echo "installing '${cmdname}' into '${bindir}'"
    cat > "${target}" <<'EOF'
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

function find-newest-tag {
    docker images "$1" --format "{{.Tag}}" | sort | tail -n 1
}

image=latex:$(find-newest-tag latex)

dockeruser=docker-user
dockeruserhome=/home/$dockeruser

docker run --rm -it \
    -u ${dockeruser} \
    -e TZ=America/Los_Angeles \
    -v "$(pwd)":"${dockeruserhome}" \
    -w "${dockeruserhome}" \
    ${image} \
    $@
EOF
    chmod +x "${target}"
}

main

