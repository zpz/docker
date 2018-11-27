set -Eeuo pipefail

thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd $( dirname ${thisfile} ) && pwd )"

(cd "${thisdir}"/py3 && bash build.sh)
(cd "${thisdir}"/py3dev && bash build.sh)
(cd "${thisdir}"/py3x && bash build.sh)
(cd "${thisdir}"/ml && bash build.sh)
#(cd "${thisdir}"/py3r && bash build.sh)
