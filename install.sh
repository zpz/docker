# Usage:
#
#   bash install.sh
#
# Recursively walk in subdirectories and install concainter-launching scripts for images.
# A script is installed only if the files `name`, `version`, `install.sh` all exist in the subdirectory.

set -o errexit
set -o pipefail
set -o nounset

function install_one {
    if [[ -f ./install.sh && -f ./version && -f ./name ]]; then
        echo in "'$(pwd)'"
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
    for f in *; do
        if [[ -d "$f" && ! -L "$f" ]]; then
            ( cd "$f"; install_one )
        fi
    done
}


main


