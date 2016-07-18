set -o errexit
set -o nounset
set -o pipefail

thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd "$( dirname "${thisfile}" )" && pwd )"
bindir="${HOME}/bin"


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
    local imgname=$(basename "${thisdir}")
    local version=$(cat "${thisdir}/version")
    local image=zppz/${imgname}:${version}

    local target="${bindir}/${cmdname}"
    check_file "${target}"

    echo "installing '${cmdname}' into '${bindir}'"
    cat > "${target}" <<EOF
#!/usr/bin/env bash

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

