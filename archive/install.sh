#!/usr/bin/env bash

read -r -d '' USAGE <<'EOF'
Usage:
    bash install.sh docker_img_name docker_img_version
EOF

if [[ $# < 2 ]]; then
    echo $USAGE
    exit 1
fi

imgname="$1"
imgversion="$2"
shift
shift
args="$@"

cmd="${imgname##*/}"

bindir="${HOME}/work/bin"
target="${bindir}/${cmd}"


if [[ $(uname) == Linux && $(id -u) != 1000 ]]; then
    USER=$(id -u)
    userarg="-e USER=${USER} -u ${USER}:docker -v /etc/group:/etc/group:ro -v /etc/passwd:/etc/passwd:ro"
else
    USER=docker-user
    userarg="-e USER=${USER} -u ${USER}"
fi

dockerhomedir='/home/docker-user'
dockerworkdir="${dockerhomedir}/work"
hostworkdir="${HOME}/work"

echo "installing ${cmd} into ${bindir}"

cat > "${target}" <<EOF
#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

workdir="${dockerworkdir}"

imgname="${imgname}"
imgversion="${imgversion}"

ARGS="\\
    ${args} \\
    ${userarg} \\
    -e HOME="${dockerhomedir}" \\
    -v "${hostworkdir}":"${dockerworkdir}" \\
    -e CFGDIR="${dockerworkdir}/config" \\
    -e LOGDIR="${dockerworkdir}/log" \\
    -e DATADIR="${dockerworkdir}/data" \\
    -e TMPDIR="${dockerworkdir}/tmp" \\
    -e NOTIFYDIR="${dockerworkdir}/notify" \\
    -e IMAGE_NAME="${imgname}" \\
    -e IMAGE_VERSION="${imgversion}" \\
    --rm -it --init \\
    -w "${dockerworkdir}" \\
    -e TZ=America/Los_Angeles"
EOF

cat >> "${target}" <<'EOF'

if (( $# > 0 )); then
    if [[ "$1" == "notebook" ]]; then
        ARGS="${ARGS} \
    --expose=8888 \
    -p 8888:8888"
        shift
        command="jupyter notebook --port=8888 --no-browser --ip=0.0.0.0 --NotebookApp.notebook_dir='${workdir}' --NotebookApp.token='' $@"
    else
        command="$@"
    fi
else
    command=/bin/bash
fi
docker run ${ARGS} ${imgname}:${imgversion} ${command}
EOF

chmod +x "${target}"
