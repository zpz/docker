set -o errexit
set -o pipefail
set -o nounset

function install_one {
    if [[ -f ./install.sh ]]; then
        echo in "'$(pwd)'"
        if [[ -f ./build.sh ]]; then
            if [[ "$(cat ./name)" != *'/'* ]]; then
                bash ./build.sh
                echo
            fi
        fi
        bash ./install.sh
        echo
    fi
    for f in *; do
        if [[ -d "$f" && ! -L "$f" ]]; then
            ( cd "$f"; install_one )
        fi
    done
}


function main {
    local thisfile="${BASH_SOURCE[0]}"
    local thisdir=$( cd "$( dirname "${thisfile}" )" && pwd )
    ( cd "${thisdir}/py2"; install_one )
    ( cd "${thisdir}/py3"; install_one )
    ( cd "${thisdir}/latex"; install_one )
    ( cd "${thisdir}/jdk"; install_one )
    ( cd "${thisdir}/jekyll"; install_one )
}


main


