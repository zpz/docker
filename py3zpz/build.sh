set -Eeuo pipefail

thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd "$( dirname "${thisfile}" )" && pwd )"
parentdir="$( dirname ${thisdir} )"
source "${parentdir}/common.sh"

parent=py3dev
parent="${parent}":$(find-newest-tag ${parent})

cp -r ../dotfiles .
build-simple ${thisdir} ${parent}
rm -rf ./dotfiles
