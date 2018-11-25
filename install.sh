#!/usr/bin/env bash

set -Eeuo pipefail

thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd $( dirname ${thisfile} ) && pwd )"

bindir="${HOME}/work/bin"
mkdir -p "${bindir}"

(
    cd /tmp
    rm -f run-docker
    echo "#!/usr/bin/env bash" > run-docker
    echo >> run-docker
    echo >> run-docker
    cat "${thisdir}/common.sh" >> run-docker
    echo >> run-docker
    echo >> run-docker
    cat "${thisdir}/run-docker.sh" >> run-docker
    chmod +x run-docker
    mv -f run-docker ${bindir}/
)



function install {
    cmd="$1"
    shift
    img="$cmd"
    opts=""
    if [[ $# > 0 ]]; then
        img="$1"
        shift
        opts="$@"
    fi

    cd /tmp
    rm -f "${cmd}"
    echo "#!/usr/bin/env bash" > "${cmd}"
    echo >> "${cmd}"
    echo "run-docker ${opts} ${img} \$@">> "${cmd}"
    chmod +x "${cmd}"
    mv -f "${cmd}" ${bindir}/
}


install py3
install ml
install py3x py3x \
    -e PYTHONPATH=/home/docker-user/work/src/github-zpz/py-extensions/src \
    -v ~/work/src/github-zpz/py-extensions:/home/docker-user/work/src/github-zpz/py-extensions

