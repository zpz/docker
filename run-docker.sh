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

# You may want to hard-code the following variables in the deployed copy
# of this script.
#
# : "${abc:?}"    # error if $abc is either undefined or empty
# : "${abc?}"     # error if $abc is undefined; empty is ok
# : "${abc:=def}"  # set $abc to 'def' if undefined or empty

: "${ECR_URL:?}"
: "${HIVE_SERVER_URL:?}"
: "${POSTGRES_SERVER_URL:?}"
: "${SLACK_MARSALERTS_WEBHOOK_URL:?}"
: "${SLACK_MARSINFO_WEBHOOK_URL:?}"
: "${LIVY_SERVER_URL:?}"
: "${DASK_SCHEDULER_URL:?}"


set +o errexit
read -r -d '' USAGE <<'EOF'
Usage:
   run-docker [--local] image-name [command [...] ]
   run-docker [--local] image-name pipeline [-v] py-script-name [...]
where 

`image-name` is like 'mars', 'mars-dev', 'mars-lightly', 'svr-dev', etc.

`command` is command to be run within the container, followed by arguments to the command.
(Default: /bin/bash)

`py-script-name`: name of the Python script, including the extension '.py'.
This script must reside directly under the 'script' folder in the projects repository
(should not be in sub-directories under 'scripts'). This does not have to be a
recurrent *pipeline*; it's just a Python script to be run.

`...`: additional arguments for `command` or `py-script-name`.

If `--local` is present, use local image and do not try to pull the latest from AWS.

All Docker options appear before `image-name`; after `image-name` are command and it arguments.
EOF
set -o errexit
# 'read' returns non-zero; see 
# https://stackoverflow.com/questions/33281837/bash-read-function-returns-error-code-when-using-new-line-delimiter 


imagename=""
uselocal="no"
command=/bin/bash
args=""

# Parse arguments. After mandatory arguments are obtained,
# remaining arguments are stored, to be passed on.
while [[ $# > 0 ]]; do
    if [[ "${imagename}" == "" ]]; then
        if [[ "$1" == -* ]]; then
            # Docker and image option.
            if [[ "$1" == '--local' ]]; then
                uselocal="yes"
                shift
            else
                echo unknown option "$1" >&2
                echo "${USAGE}"
                exit 1
            fi
        else
            imagename="$1"
            shift
        fi
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


# Check whether the latest version of the Docker image on AWS is available locally.
# If not, pull it from AWS and tag appropriately.
if [[ "${uselocal}" == "no" ]]; then
    imageversion=$(pull_aws_latest "${imagename}")
    docker tag "${imagename}:${imageversion}" "${imagename}:latest"
    echo using latest image "${imagename}:${imageversion}" in sync with AWS
else
    echo using local image "${imagename}:latest"
    imageversion=latest
fi

if [[ "${imagename}" == *-* ]]; then
    projname="${imagename%%-*}"
    # Delete longest match of "-*" from back of string.

    variantname="${imagename#*-}"
    # Delete shortest match of "*-" from front of string.
else
    projname="${imagename}"
    variantname=""
fi

if [[ "${command}" == "pipeline" ]]; then
    scriptname=$(set -- $args; if [[ "$1" == '-v' ]]; then echo "$2"; else echo "$1"; fi)
fi


opts=""

if [[ $(uname) == Linux && $(id -u) != 1000 ]]; then
    # Gateway Linux box.
    # Other Linux machines --- not tested.
    uid=$(id -u)
    dockeruser=${uid}
    opts="${opts} -e USER=${dockeruser} -u ${dockeruser}:docker -v /etc/group:/etc/group:ro -v /etc/passwd:/etc/passwd:ro"
else
    dockeruser='docker-user'
    opts="${opts} -e USER=${dockeruser} -u ${dockeruser}"

    # Your (a particular user's) AWS keys are picked up from the content of `$HOME/.aws/`.
    # This directory usually exists on your development machine.
    # These AWS keys are per person.
    #
    # Do not do this on a gateway machine (the branch above).
    : "${AWS_ACCOUNT_ID:?}"
    : "${AWS_DEFAULT_REGION:=us-east-1}"
    : "${AWS_DEFAULT_OUTPUT:=json}"
    aws_key=$(grep aws_access_key_id ${HOME}/.aws/credentials)
    aws_key=${aws_key#*= *}
    aws_secret=$(grep aws_secret_access_key ${HOME}/.aws/credentials)
    aws_secret=${aws_secret#*= *}
    opts="${opts} -e AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID}"
    opts="${opts} -e AWS_ACCESS_KEY_ID=${aws_key} -e AWS_SECRET_ACCESS_KEY=${aws_secret}"
    opts="${opts} -e AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} -e AWS_DEFAULT_OUTPUT=${AWS_DEFAULT_OUTPUT}"
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

opts="${opts}
-e HIVE_SERVER_URL=${HIVE_SERVER_URL}
-e POSTGRES_SERVER_URL=${POSTGRES_SERVER_URL}
-e SLACK_MARSALERTS_WEBHOOK_URL=${SLACK_MARSALERTS_WEBHOOK_URL}
-e SLACK_MARSINFO_WEBHOOK_URL=${SLACK_MARSINFO_WEBHOOK_URL}
-e LIVY_SERVER_URL=${LIVY_SERVER_URL}
-e DASK_SCHEDULER_URL=${DASK_SCHEDULER_URL}"


LOGDIR=log/"${imagename}"
if [[ "${command}" == "pipeline" ]]; then
    LOGDIR="${LOGDIR}/${scriptname}"
fi
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

NOTIFYDIR="notify/${imagename}"
mkdir -p "${hostworkdir}/${NOTIFYDIR}"
opts="${opts} -v ${hostworkdir}/${NOTIFYDIR}:${dockerworkdir}/${NOTIFYDIR}"
opts="${opts} -e NOTIFYDIR=${dockerworkdir}/${NOTIFYDIR}"

TMPDIR="tmp"
mkdir -p "${hostworkdir}/${TMPDIR}"
opts="${opts} -v ${hostworkdir}/${TMPDIR}:${dockerworkdir}/${TMPDIR}"
opts="${opts} -e TMPDIR=${dockerworkdir}/${TMPDIR}"


if [[ "${variantname}" == "dev" ]]; then
    SRCDIR="src/${projname}"
    opts="${opts} -v ${hostworkdir}/${SRCDIR}:${dockerworkdir}/${SRCDIR}"
    opts="${opts} -e SRCDIR=${dockerworkdir}/${SRCDIR}"
    opts="${opts} -e PYTHONPATH=${dockerworkdir}/src/${projname}"
fi

if [[ "${command}" == "notebook" ]]; then
    opts="${opts} --expose=8888 -p 8888:8888"
    command="jupyter notebook --port=8888 --no-browser --ip=0.0.0.0 --NotebookApp.notebook_dir='${dockerworkdir}' --NotebookApp.token=''"
elif [[ "${command}" == "pipeline" ]]; then
    if [[ "${variantname}" == "dev" ]]; then
        opts="${opts} -e SCRIPTDIR=${dockerworkdir}/src/${projname}/scripts"
    else
        opts="${opts} -e SCRIPTDIR=/usr/local/bin/groundtruth/${projname}"
    fi
elif [[ "${command}" == "dask-scheduler" ]]; then
    if [[ "${args}" != "" ]]; then
        echo arguments "'${args}'" are not recognized by command "'${command}'" >&2
        exit 1
    fi
    opts="${opts} --expose=8786 -p 8786:8786 --expose=8787 -p 8787:8787"
    args="--bokeh-port 8787"
elif [[ "${command}" == "dask-worker" ]]; then
    if [[ "${args}" != "" ]]; then
        echo arguments "'${args}'" are not recognized by command "'${command}'" >&2
        exit 1
    fi
    mkdir -p ${hostworkdir}/dask-worker-space
    opts="${opts} -v ${hostworkdir}/dask-worker-space:${dockerworkdir}/dask-worker-space"
    args="${DASK_SCHEDULER_URL}"
else
    opts="${opts} -it"
fi

# DEBUG
if [[ "${command}" == "pipeline" ]]; then
    notify_slack mars-info 'launching pipeline' "${imagename}:${imageversion} ${command} ${args}"
    # This may fail if "${args}" contains double quotes.
fi

#set -x
docker run ${opts} ${imagename}:${imageversion} ${command} ${args}
