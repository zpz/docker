set -Eeuo pipefail

thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd "$( dirname "${thisfile}" )" && pwd )"
parentdir="$( dirname ${thisdir} )"
source "${parentdir}/common.sh"

parent=debian:stretch

rm -rf ./dotfiles
cp -r ../dotfiles .
build-simple ${thisdir} ${parent}
rm -rf ./dotfiles
