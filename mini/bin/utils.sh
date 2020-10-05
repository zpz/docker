# There are two ways to specify an image name (except for tag):
#   python
#   zppz/xyz
#
# The first one means the "official image" 'python'.
# The second one includes namespace such as 'zppz'.
# The name may be followed by ':tag', such as
#
#   zppz/xyz:20200318

set -Eeuo pipefail


function number-smaller-than {
    local left=$1
    local right=$2
    # Inputs are integer or floating point numbers;
    # can be a mix of types.
    awk 'BEGIN { print ('${left}' < '${right}') ? "yes" : "no" }'
}

function get-image-tags-local {
    # Input is image name w/o tag.
    # Returns space separated list of tags;
    # '-' if not found.
    local name="$1"
    if [[ "${name}" == *:* ]]; then
        >&2 echo "image name '${name}' already contains tag"
        return 1
    fi
    local tags=$(docker images "${name}" --format "{{.Tag}}" ) || return 1
    if [[ "${tags}" == '' ]]; then
        echo -
    else
        echo $(echo "${tags}")
    fi
}


function get-image-tags-remote {
    # Analogous `get-image-tags-local`.
    #
    # For an "official" image, the image name should be 'library/xyz'.
    # However, the API response is not complete.
    # For now, just work on 'zppz/' images only.
    local name="$1"
    if [[ "${name}" == *:* ]]; then
        >&2 echo "image name '${name}' already contains tag"
        return 1
    fi
    if [[ "${name}" != zppz/* ]]; then
        >&2 echo "image name '${name}' is not in the 'zppz' namespace; not supported at present"
        return 1
    fi
    local url=https://hub.docker.com/v2/repositories/${name}/tags
    local tags="$(curl -L -s ${url} | tr -d '{}[]"' | tr ',' '\n' | grep name)" || return 1
    if [[ "$tags" == "" ]]; then
        echo -
    else
        tags="$(echo $tags | sed 's/name: //g' | sed 's/results: //g')" || return 1
        echo "${tags}"
    fi
}


function has-image-local {
    # Input is image name with tag.
    # Returns whether this image exists locally.

    local name="$1"
    if [[ "${name}" != *:* ]]; then
        >&2 echo "input image '${name}' does not contain tag"
        return 1
    fi
    local tag=$(docker images "${name}" --format "{{.Tag}}" ) || return 1
    if [[ "${tag}" != '' ]]; then
        echo yes
    else
        echo no
    fi
}


function has-image-remote {
    local name="$1"
    if [[ "${name}" != *:* ]]; then
        >&2 echo "input image '${name}' does not contain tag"
        return 1
    fi
    if [[ "${name}" != zppz/* ]]; then
        # In this case, the function `get-image-tags-remote`
        # is not reliable, so just return 'yes'.
        echo yes
    else
        local tag="${name##*:}"
        name="${name%:*}"
        local tags=$(get-image-tags-remote "${name}") || return 1
        if [[ "${tags}" == *" ${tag} "* ]]; then
            echo yes
        else
            echo no
        fi
    fi
}


function find-latest-image-local {
    # Find Docker image of specified name with the latest tag on local machine.
    #
    # For a non-zppz image, must specify exact tag.
    # In this case, this function checks whether that image exists.
    #
    # Returns full image name with tag.
    # Returns '-' if not found

    local name="$1"
    if [[ "${name}" == zppz/* ]]; then
        if [[ "${name}" == *:* ]]; then
            local z=$(has-image-local "${name}") || return 1
            if [[ "${z}" == yes ]]; then
                echo "${name}"
            else
                echo -
            fi
        else
            local tag=$(docker images "${name}" --format "{{.Tag}}" | sort | tail -n 1) || return 1
            if [[ "${tag}" == '' ]]; then
                echo -
            else
                echo "${name}:${tag}"
            fi
        fi
    else
        if [[ "${name}" != *:* ]]; then
            >&2 echo "image '${name}' must have its exact tag specified"
            return 1
        fi

        local z=$(has-image-local "${name}") || return 1
        if [[ "${z}" == yes ]]; then
            echo "${name#library/}"
        else
            echo -
        fi
    fi
}


function find-latest-image-remote {
    local name="$1"
    if [[ "${name}" == *:* ]]; then
        local z=$(has-image-remote "${name}") || return 1
        if [[ "${z}" == yes ]]; then
            echo "${name}"
        else
            echo -
        fi
    else
        if [[ "${name}" != zppz/* ]]; then
            >&2 echo "image '${name}' must have its exact tag specified"
            return 1
        fi
        local tags="$(get-image-tags-remote ${name})" || return 1
        if [[ "${tags}" != '-' ]]; then
            local tag=$(echo "${tags}" | tr ' ' '\n' | sort -r | head -n 1) || return 1
            echo "${name}:${tag}"
        else
            echo -
        fi
    fi
}


function find-latest-image {
    local name="$1"
    local localimg=$(find-latest-image-local "${name}") || return 1
    local remoteimg=$(find-latest-image-remote "${name}") || return 1
    if [[ "${localimg}" == - ]]; then
        echo "${remoteimg}"
    elif [[ "${remoteimg}" == - ]]; then
        echo "${localimg}"
    elif [[ "${localimg}" < "${remoteimg}" ]]; then
        echo "${remoteimg}"
    else
        echo "${localimg}"
    fi
}


function find-image-id-local {
    # Input is a full image name including namespace and tag.
    local name="$1"
    docker images "${name}" --format "{{.ID}}"
}


function find-image-id-remote {
    # Input is a full image name including namespace and tag.
    local name="$1"
    local tag="${name##*:}"
    >&2 echo "getting manifest of remote image ${name}"
    curl -v --silent -H 'Accept: application/vnd.docker.distribution.manifest.v2+json' ${name}/manifest/${tag} 2>&1 \
        | awk '/config/,/}/' | grep digest | grep -o 'sha256:[0-9a-z]*'
}


function get-image-layers-local {
    local name="$1"
    if [[ ${name} != *:* ]]; then
        >&2 echo "input image '${name}' does not contain tag"
        return 1
    fi
    >&2 echo "getting manifest of local image '${name}'"
    DOCKER_CLI_EXPERIMENTAL=enabled docker manifest inspect ${name} \
        | awk '/layers/,/]/' | grep digest | grep -o 'sha256:[0-9a-z]*' | tr '\n' ' '
}


function get-image-layers-remote {
    local name="$1"
    if [[ ${name} != *:* ]]; then
        >&2 echo "input image '${name}' does not contain tag"
        return 1
    fi
    local tag="${name##*:}"
    curl --silent -H 'Accept application/vnd.docker.distribution.manifest.v2+json' ${name}/manifests/${tag} 2>&1 \
        | awk '/layers/,/]/' | grep digest | grep -o 'sha256:[0-9a-z]*' | tr '\n' ' '
}


function build-image {
    local BUILDDIR="$1"
    local NAME="$2"
    local parent="$3"
    local VERSION="$4"

    local PARENT=$(find-latest-image ${parent}) || return 1
    if [[ "${PARENT}" == - ]]; then
        >&2 echo "Unable to find parent image '${parent}'"
        return 1
    fi

    local old_img=$(find-latest-image ${NAME}) || return 1
    if [[ "${old_img}" != - ]] && [[ $(has-image-local "${old_img}") == no ]]; then
        echo
        docker pull ${old_img} || return 1
    fi

    local FULLNAME="${NAME}:${VERSION}"

    echo
    echo
    echo "=== build image ${FULLNAME}"
    echo "       based on ${PARENT} ==="
    echo "=== $(date) ==="
    echo

    cp -f ${BUILDDIR}/Dockerfile ${BUILDDIR}/_Dockerfile
    echo >> ${BUILDDIR}/_Dockerfile
    echo "ENV IMAGE_PARENT=${PARENT}" >> ${BUILDDIR}/_Dockerfile
    docker build --build-arg PARENT="${PARENT}" -t "${FULLNAME}" "${BUILDDIR}" -f ${BUILDDIR}/_Dockerfile >&2 || return 1
    rm -r ${BUILDDIR}/_Dockerfile

    local new_img="${FULLNAME}"
    if [[ "${old_img}" != - ]]; then
        local old_id=$(find-image-id-local "${old_img}") || return 1
        local new_id=$(find-image-id-local "${new_img}") || return 1
        echo
        echo "old_img: ${old_img}"
        echo "new_img: ${new_img}"
        echo "old_id: ${old_id}"
        echo "new_id: ${new_id}"
        if [[ "${old_id}" == "${new_id}" ]]; then
            echo
            echo "Newly built image is identical to an older build; discarding the new tag..."
            docker rmi "${new_img}"
        else
            echo "Deleting the old image..."
            docker rmi "${old_img}"
        fi
    fi
}


function pull-latest-image {
    local imagename="$1"

    if [[ "${imagename}" == *:* ]]; then
        if [[ $(has-image-local ${imagename}) == no ]]; then
            docker pull ${imagename}
        fi
        return 0
    fi

    local image_remote=$(find-latest-image-remote ${imagename}) || exit 1
    if [[ "${image_remote}" == - ]]; then
        return 0
    fi

    local image_local=$(find-latest-image-local ${imagename}) || exit 1
    if [[ ${image_local} == - ]]; then
        docker pull ${imagename}
    fi

    if [[ "${image_remote}" < "${image_local}" || "${image_remote}" == "${image_local}" ]]; then
        return 0
    fi
    
    local id_local=$(get-image-layers-local ${image_local})
    local id_remote=$(get-image-layers-remote ${image_remote})
    if [[ "${id_local}" == "${id_remote}" ]]; then
        echo "Local image ${image_local} is identical to remote image ${image_remote}; adding remote tag to local image"
        docker tag ${image_local} ${image_remote}
        return 0
    fi

    local imgids_local=$(docker images -aq ${imagename})
    docker pull ${image_remote}
    echo
    echo "Deleting the older images:"
    echo "${imgids_local}"
    docker rmi ${imgids_local} || true
}


function push-image {
    local name="$1"

    local img_remote=$(find-latest-image-remote ${name}) || return 1
    local img_local=$(find-latest-image-local ${name}) || return 1
    if [[ "${img_remote}" != - ]]; then
        local id_remote=$(get-image-layers-remote ${img_remote}) || return 1
        local id_local=$(get-image-layers-local ${img_local}) || return 1

        echo
        echo "remote image: ${img_remote}"
        echo "remote id: ${id_remote}"
        echo "local image: ${img_local}"
        echo "local id: ${id_local}"
        echo

        if [[ "${id_remote}" == "${id_local}" ]]; then
            echo "local version and remote version are identical; no need to push"
            return 0
        fi
    fi

    echo
    echo "pushing ${img_local} to dockerhub"
    docker push ${img_local}

    # docker login --username ${DOCKERHUBUSERNAME} --password ${DOCKERHUBPASSWORD} || return 1

    local id_remote_new=$(get-image-layers-remote ${img_local}) || return 1
    echo
    echo "new remote image: ${img_local}"
    echo "new remote id: ${id_remote_new}"
}




function get_mem_limit {
    local mem=
    # available memory in GB.
    if [[ $(uname) == Linux ]]; then
        mem=$(free -g | grep Mem)
        mem=${mem##* }
    elif [[ $(uname) == Darwin ]]; then
        # https://apple.stackexchange.com/questions/4286/is-there-a-mac-os-x-terminal-version-of-the-free-command-in-linux-systems
        FREE_BLOCKS=$(vm_stat | grep free | awk '{ print $3 }' | sed 's/\.//')
        INACTIVE_BLOCKS=$(vm_stat | grep inactive | awk '{ print $3 }' | sed 's/\.//')
        SPECULATIVE_BLOCKS=$(vm_stat | grep speculative | awk '{ print $3 }' | sed 's/\.//')
        FREE=$((($FREE_BLOCKS+SPECULATIVE_BLOCKS)*4096/1048576))
        INACTIVE=$(($INACTIVE_BLOCKS*4096/1048576))
        TOTAL=$((($FREE+$INACTIVE)/1024))
        mem=${TOTAL}
    else
        >&2 echo "platform $(uname) is not supported"
        return 1
    fi
    local mem_limit=$(($mem*3/4))
    if [[ $(number-smaller-than $mem 6) == yes ]]; then
        >&2 echo "only ${mem_limit}GB memory available"
    fi
    echo "${mem_limit}"g
}


function run_docker {
    local imagename=""
    local name=""
    local command=''
    local args=""
    local opts=""
    local with_pythonpath=yes
    local daemon_mode=no
    local as_root=no
    local use_local=no
    local nb_port=8888
    local memory_limit=$(get_mem_limit)
    local shm_size=4g
    local no_host_binds=no
    local restart=
    local z

    local hostdatadir=''
    local hostlogdir=''
    local hosttmpdir=''
    local hostsrcdir=''
    local hostcfgdir=''

    # Parse arguments.
    # Before the argument for image name,
    # some arguments are consumed by this script;
    # the rest are stored to be passed on to the command `docker run`.
    # After the argument for image name,
    # the first is the command to be executed in the container,
    # others are arguments to the command.
    while [[ $# > 0 ]]; do
        if [[ "${imagename}" == "" ]]; then
            if [[ "$1" == -v ]]; then
                shift
                opts="${opts} -v $1"
            elif [[ "$1" == -p ]]; then
                shift
                opts="${opts} -p $1"
            elif [[ "$1" == --network=* ]]; then
                z="$1"
                z="${z#*=}"
                opts="${opts} --network $z"
            elif [[ "$1" == --network ]]; then
                shift
                opts="${opts} --network $1"
            elif [[ "$1" == -e ]]; then
                shift
                opts="${opts} -e $1"
            elif [[ "$1" == --memory=* ]]; then
                memory_limit="$1"
                memory_limit="${memory_limit#*=}"
            elif [[ "$1" == --memory ]]; then
                shift
                memory_limit="$1"
            elif [[ "$1" == --shm-size=* ]]; then
                shm_size="$1"
                shm_size="${shm_size#*=}"
            elif [[ "$1" == --shm-size ]]; then
                shift
                shm_size="$1"
            elif [[ "$1" == --nb_port ]]; then
                shift
                nb_port="$1"
            elif [[ "$1" == --nb_port=* ]]; then
                nb_port="$1"
                nb_port="${nb_port#*=}"
            elif [[ "$1" == --no-pythonpath ]]; then
                # Do not put `~/src/src` on `$PYTHONPATH`.
                # This has an effect only in the 'development' mode, i.e.
                # when launching an image whose name does not end with '-[branchname]'.
                with_pythonpath=no
            elif [[ "$1" == --no-host-binds ]]; then
                # This is for running tests.
                no_host_binds=yes
            elif [[ "$1" == --root ]]; then
                as_root=yes
            elif [[ "$1" == --local ]]; then
                use_local=yes
            elif [[ "$1" == --name ]]; then
                shift
                name="$1"
            elif [[ "$1" == --name=* ]]; then
                name="$1"
                name="${name#*=}"
            elif [[ "$1" == --restart ]]; then
                shift
                opts="${opts} --restart $1"
                restart="$1"
            elif [[ "$1" == --restart=* ]]; then
                opts="${opts} $1"
                restart="$1"
                restart="${restart#*=}"
            elif [[ "$1" == "-d" ]] || [[ "$1" == "--detach" ]]; then
                opts="${opts} $1"
                daemon_mode=yes

            elif [[ "$1" == --hostdatadir ]]; then
                shift
                hostdatadir="$1"
            elif [[ "$1" == --hostdatadir=* ]]; then
                hostdatadir="$1"
                hostdatadir="${hostdatadir#*=}"
            elif [[ "$1" == --hostlogdir ]]; then
                shift
                hostlogdir="$1"
            elif [[ "$1" == --hostlogdir=* ]]; then
                hostlogdir="$1"
                hostlogdir="${hostlogdir#*=}"
            elif [[ "$1" == --hosttmpdir ]]; then
                shift
                hosttmpdir="$1"
            elif [[ "$1" == --hosttmpdir=* ]]; then
                hosttmpdir="$1"
                hosttmpdir="${hosttmpdir#*=}"
            elif [[ "$1" == --hostsrcdir ]]; then
                shift
                hostsrcdir="$1"
            elif [[ "$1" == --hostsrcdir=* ]]; then
                hostsrcdir="$1"
                hostsrcdir="${hostsrcdir#*=}"
            elif [[ "$1" == --hostcfgdir ]]; then
                shift
                hostcfgdir="$1"
            elif [[ "$1" == --hostcfgdir=* ]]; then
                hostcfgdir="$1"
                hostcfgdir="${hostcfgdir#*=}"

            elif [[ "$1" == -* ]]; then
                # Every other argument is captured and passed on to `docker run`.
                # For example, if there is an option called `--volume` which sets
                # something called 'volume', you may specify it like this
                #
                #   --volume=30
                #
                # You can not do
                #
                #   --volume 30
                #
                # because `run-docker` does not explicitly capture this option,
                # hence it does not know this option has two parts.
                # The same idea applies to other options.
                opts="${opts} $1"
            else
                imagename="$1"
            fi
            shift
        else
            # After `imagename`.
            command="$1"
            shift
            if [[ $# > 0 ]]; then
                args="$@"
            fi
            break
        fi
    done

    if [[ "${imagename}" == "" ]]; then
        echo "${USAGE}"
        exit 1
    fi

    local is_ext_image=no
    local is_dev_image=no
    local is_base_image=no
    local is_interactive=no

    if [[ ${imagename} != zppz/* ]]; then
        is_ext_image=yes
        if [[ ${imagename} != *:* ]]; then
            >&2 echo "external image '${imagename}' must have tag specified"
            exit 1
        fi
    fi

    if [[ ${use_local} == no ]]; then
        pull-latest-image ${imagename}
    else
        opts="${opts} -e DOCKER_LOCAL_MODE=1"
    fi

    if [[ ${imagename} != *:* ]]; then
        imagename=$(find-latest-image-local ${imagename}) || exit 1
    fi

    local imageversion=${imagename##*:}
    local imagenamespace
    imagename=${imagename%:*}
    local imagefullname="${imagename}"
    if [[ "${imagename}" == */* ]]; then
        imagenamespace=${imagename%%/*}
        imagename=${imagename#*/}
        # Now `imagename` contains neither namespace nor tag.
    else
        imagenamespace=''
    fi

    if [[ ${command} == '' ]]; then
        if [[ ${imagename} == mini ]]; then
            command=/bin/sh
        else
            command=/bin/bash
        fi
    fi

    if [[ "${args}" == '' ]] \
          && [[ " /bin/bash /bin/sh bash sh python ptpython ptipython ipython " == *" ${command} "* ]]; then
        is_interactive=yes
        opts="${opts} -it"
    fi

    local dockerhomedir

    if [[ "${as_root}" == yes ]] \
            || [[ "${is_ext_image}" == yes ]] \
            || [[ "${imagename}" == mini ]] \
            || [[ "$(id -un)" == root ]]; then
        dockerhomedir=/root
        opts="${opts} -e USER=root -u root"
    elif [[ $(uname) == Linux ]]; then
        dockerhomedir="/home/$(id -un)"
        opts="${opts} -e USER=$(id -un) -u $(id -u):$(id -g) -v /etc/passwd:/etc/passwd:ro"
    elif [[ $(uname) == Darwin ]]; then
        dockerhomedir=/home/docker-user
        opts="${opts} -e USER=docker-user -u docker-user"
    else
        >&2 echo "Platform $(uname) is not supported"
        exit 1
    fi

    local BASE_IMAGES="dl jekyll mini py3r latex ml py3"

    local hostworkdir="${HOME}/work"
    mkdir -p ${hostworkdir}

    reponame="${imagename}"

    if [[ " ${BASE_IMAGES} " == *" ${imagename} "* ]]; then
        is_base_image=yes
    elif [[ "${is_ext_image}" == no ]]; then
        if [ -d "${hostworkdir}/src/${reponame}" ]; then
            is_dev_image=yes
        fi
    fi

    if [[ ${name} == '' ]]; then
        name="$(whoami)-$(TZ=America/Los_Angeles date +%Y%m%d-%H%M%S)"
    fi

    opts="${opts}
    -e HOME=${dockerhomedir}
    -e IMAGE_NAME=${imagename}
    -e IMAGE_VERSION=${imageversion}
    -e TZ=America/Los_Angeles
    --memory ${memory_limit}
    --shm-size ${shm_size}
    --name ${name}
    --init"

    if [ -z "${restart}" ] && [[ ${daemon_mode} == no ]]; then
        opts="${opts} --rm"
    fi

    opts="${opts} -e HOST_UNAME=$(uname) -e HOST_WHOAMI=$(whoami)"
    if [[ "$(uname)" == Linux ]]; then
        # opts="${opts} -e HOST_IP=$(hostname -i)"
        opts="${opts} -e HOST_IP=$(ip route get 1 | awk '{gsub("^.*src ",""); print $1; exit}')"
    fi

    if [[ "${is_ext_image}" == no ]] && [[ "${is_base_image}" == no ]]; then
        if [[ "${no_host_binds}" == no ]]; then
            if [[ "${hostdatadir}" == '' ]]; then
                hostdatadir=${hostworkdir}/data
            fi
            mkdir -p ${hostdatadir}
            opts="${opts} -v ${hostdatadir}:${dockerhomedir}/data"
            opts="${opts} -e DATADIR=${dockerhomedir}/data"

            if [[ "${hostlogdir}" == '' ]]; then
                hostlogdir=${hostworkdir}/log
            fi
            mkdir -p ${hostlogdir}
            opts="${opts} -v ${hostlogdir}:${dockerhomedir}/log"
            opts="${opts} -e LOGDIR=${dockerhomedir}/log"

            if [[ "${hostcfgdir}" == '' ]]; then
                hostcfgdir=${hostworkdir}/cfg
            fi
            mkdir -p ${hostcfgdir}
            opts="${opts} -v ${hostcfgdir}:${dockerhomedir}/cfg"
            opts="${opts} -e CFGDIR=${dockerhomedir}/cfg"
        else
            opts="${opts} -e DATADIR=/tmp -e LOGDIR=/tmp -e CFGDIR=/tmp"
        fi
    fi

    if [[ "${no_host_binds}" == no ]]; then
        if [[ "${hosttmpdir}" == '' ]]; then
            hosttmpdir=${hostworkdir}/tmp
        fi
        mkdir -p ${hosttmpdir}
        opts="${opts} -v ${hosttmpdir}:${dockerhomedir}/tmp"
        opts="${opts} -e TMPDIR=${dockerhomedir}/tmp"
    else
        opts="${opts} -e TMPDIR=/tmp"
    fi

    if [[ "${is_dev_image}" == yes ]]; then
        if [[ "${hostsrcdir}" == '' ]]; then
            hostsrcdir="${hostworkdir}/src/${reponame}"
        fi

        if [[ "${no_host_binds}" == no ]]; then
            opts="${opts} -v ${hostsrcdir}:${dockerhomedir}/src"
        fi

        if [[ "${with_pythonpath}" == yes ]]; then
            opts="${opts} -e PYTHONPATH=${dockerhomedir}/src/src"
        fi
    fi

    if [[ "${command}" == "notebook" ]]; then
        opts="${opts} --expose=${nb_port} -p ${nb_port}:${nb_port}"
        opts="${opts} -e JUPYTER_DATA_DIR=/tmp/.jupyter/data"
        opts="${opts} -e JUPYTER_RUNTIME_DIR=/tmp/.jupyter/runtime"
        command="jupyter notebook --port=${nb_port} --no-browser --ip=0.0.0.0 --NotebookApp.notebook_dir='${dockerhomedir}' --NotebookApp.token=''"
    elif [[ "${command}" == "py.test" ]]; then
        args="-p no:cacheprovider ${args}"
    fi

    if [[ "${command}" == notebook ]] || [[ "${is_dev_image}" == no ]]; then
        opts="${opts} --workdir ${dockerhomedir}"
    else
        opts="${opts} --workdir ${dockerhomedir}/src"
    fi

    docker run ${opts} \
        ${imagefullname}:${imageversion} \
        ${command} ${args}
}
