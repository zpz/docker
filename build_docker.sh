set -Eeuo pipefail

thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd $( dirname ${thisfile} ) && pwd )"

source "${thisdir}/mini/bin/utils.sh"


function main {
    local img
    local IMG
    local builddir
    local parent
    for img in "${IMAGES[@]}"; do
        IMG="${NAMESPACE}/${img}"
        builddir="${thisdir}/${img}"
        parent="$(cat ${builddir}/parent)"
        build-image $builddir ${IMG} ${parent} ${TIMESTAMP} || return 1
        if [[ ${PUSH} == yes ]]; then
            push-image ${IMG}
        fi
    done
}


NAMESPACE=zppz
TIMESTAMP=$(${thisdir}/mini/bin/make-ts-tag)

# The images are pushed to Dockerhub only when built at github
# by the integrated Travis-CI in branch `master`.

# if [ -z ${TRAVIS_BRANCH+x} ]; then
#     BRANCH=''
#     PUSH=no
# else
#     BRANCH=${TRAVIS_BRANCH}
#     PUSH=yes
# fi
PUSH=no

IMAGES=( mini py3 py3r )
main
