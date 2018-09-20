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



function def {
    name="$1"
    cd /tmp
    rm -f "${name}"
    echo "#!/usr/bin/env bash" > "${name}"
    echo >> "${name}"
    echo "run-docker ${name} \$@">> "${name}"
    chmod +x "${name}"
    mv -f "${name}" ${bindir}/
}


def py3
def py3dev
