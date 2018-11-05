# This script uses functions defined in './common.sh',
# which will be inserted by 'install.sh'.
#
# Do not run this script directly.
# Instead, run 'run-docker' after calling 'install.sh',
# or use the several specialized commands installed by 'install.sh'.
#
# However, if you see a bunch of function definitions above this,
# you are looking at a version that has './common.sh' appended to
# './run-docker.sh'. In that case, this script is ready for use.


# set -Eeuo pipefail
set -o errexit
set -o nounset
set -o pipefail

# For all the directory and file names touched by this script,
# space in the name is not supported.
# Do not use space in directory and file names in ${HOME}/work and under it.


USAGE=$(cat <<'EOF'
Usage:
   run-docker image-name [command [...] ]
where 

`image-name` is like 'py3', 'py3-dev', etc.

`command` is command to be run within the container, followed by arguments to the command.
(Default: /bin/bash)
EOF
)


if [[ $# < 1 ]]; then
    echo "${USAGE}"
    exit 1
fi


imagename=""
command=/bin/bash
args=""
opts=""

# Parse arguments. After mandatory arguments are obtained,
# remaining arguments are stored, to be passed on.
while [[ $# > 0 ]]; do
    if [[ "${imagename}" == "" ]]; then
        if [[ "$1" == -v ]]; then
            shift
            opts="${opts} -v $1"
        elif [[ "$1" == -p ]]; then
            shift
            opts="${opts} -p $1"
        elif [[ "$1" == --network ]]; then
            shift
            opts="${opts} --network $1"
        elif [[ "$1" == -* ]]; then
            opts="${opts} $1"
        else
            imagename="$1"
        fi
        shift
    else
        # After `image-name`.
        command="$1"
        shift
        args="$@"
        break
    fi
done


if [[ "${imagename}" == "" ]]; then
    echo "${USAGE}"
    exit 1
fi


imageversion=$(find-newest-tag "${imagename}")


if [[ $(uname) == Linux && $(id -u) != 1000 ]]; then
    # Other Linux machines --- not tested.
    uid=$(id -u)
    dockeruser=${uid}
    opts="${opts} -e USER=${dockeruser} -u ${dockeruser}:docker -v /etc/group:/etc/group:ro -v /etc/passwd:/etc/passwd:ro"
else
    dockeruser='docker-user'
    opts="${opts} -e USER=${dockeruser} -u ${dockeruser}"
fi


dockerhomedir='/home/docker-user'
dockerworkdir="${dockerhomedir}/work"
hostworkdir="${HOME}/work"

opts="${opts}
-e HOME=${dockerhomedir}
--workdir ${dockerworkdir}
-e IMAGE_NAME=${imagename}
-e IMAGE_VERSION=${imageversion}
-w ${dockerworkdir}
-e TZ=America/Los_Angeles
--rm --init"


LOGDIR=log/"${imagename}"
mkdir -p "${hostworkdir}/${LOGDIR}"
opts="${opts} -v ${hostworkdir}/${LOGDIR}:${dockerworkdir}/${LOGDIR}"
opts="${opts} -e LOGDIR=${dockerworkdir}/${LOGDIR}"

DATADIR="data/${imagename}"
mkdir -p "${hostworkdir}/${DATADIR}"
opts="${opts} -v ${hostworkdir}/${DATADIR}:${dockerworkdir}/${DATADIR}"
opts="${opts} -e DATADIR=${dockerworkdir}/${DATADIR}"

CFGDIR="config/${imagename}"
mkdir -p "${hostworkdir}/${CFGDIR}"
opts="${opts} -v ${hostworkdir}/${CFGDIR}:${dockerworkdir}/${CFGDIR}"
opts="${opts} -e CFGDIR=${dockerworkdir}/${CFGDIR}"

TMPDIR="tmp"
mkdir -p "${hostworkdir}/${TMPDIR}"
opts="${opts} -v ${hostworkdir}/${TMPDIR}:${dockerworkdir}/${TMPDIR}"
opts="${opts} -e TMPDIR=${dockerworkdir}/${TMPDIR}"


if [[ "${command}" == "notebook" ]]; then
    opts="${opts} --expose=8888 -p 8888:8888"
    command="jupyter notebook --port=8888 --no-browser --ip=0.0.0.0 --NotebookApp.notebook_dir='${dockerworkdir}' --NotebookApp.token=''"
elif [[ "${command}" == "py.test" ]]; then
    args="-p no:cacheprovider ${args}"
else
    opts="${opts} -it"
fi


#set -x
docker run ${opts} ${imagename}:${imageversion} ${command} ${args}
