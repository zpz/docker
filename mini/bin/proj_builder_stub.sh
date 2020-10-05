thisdir="$( pwd )"


function build-dev {
    local timestamp="$1"
    local name="$2"
    local builddir="${thisdir}/docker"
    local parent
    if [[ "${PARENT}" == '' ]]; then
        parent=$(cat "${builddir}/parent") || return 1
    else
        parent="${PARENT}"
    fi
    build-image ${builddir} ${name} ${parent} ${timestamp} || return 1
}


function build-branch {
    local timestamp="$1"
    local name="$2"
    local build_dir="/tmp/${REPO}"
    rm -rf ${build_dir}
    mkdir -p ${build_dir}/src
    [ -d ${thisdir}/src ] && cp -R ${thisdir}/src ${build_dir}/src/src
    [ -d ${thisdir}/bin ] && cp -R ${thisdir}/bin ${build_dir}/src/bin
    [ -d ${thisdir}/sysbin ] && cp -R ${thisdir}/sysbin ${build_dir}/src/sysbin
    [ -d ${thisdir}/tests ] && cp -R ${thisdir}/tests ${build_dir}/src/tests
    [ -f ${thisdir}/setup.py ] && cp ${thisdir}/setup.py ${build_dir}/src/
    [ -f ${thisdir}/setup.cfg ] && cp ${thisdir}/setup.cfg ${build_dir}/src/
    [ -f ${thisdir}/MANIFEST.in ] && cp ${thisdir}/MANIFEST.in ${build_dir}/src/
    [ -f ${thisdir}/install.sh ] && cp ${thisdir}/install.sh ${build_dir}/src/

    cat > "${build_dir}/Dockerfile" << EOF
ARG PARENT
FROM \${PARENT}
USER root

RUN mkdir -p /tmp/build
COPY src/ /tmp/build

RUN cd /tmp/build \\
    && ( if [ -f install.sh ]; then bash install.sh; elif [ -f setup.py ]; then pip-install . ; fi) \\
    && rm -rf /opt/${REPO} && mkdir -p /opt/${REPO} \\
    && ( if [ -d bin ]; then mv -f bin "/opt/${REPO}/"; fi ) \\
    && ( if [ -d tests ]; then mv -f tests "/opt/${REPO}/"; fi ) \\
    && ( if [ -d sysbin ]; then mkdir -p /opt/bin && mv -f sysbin/* "/opt/bin/"; fi ) \\
    && cd / \\
    && rm -rf /tmp/build
EOF

    local name="${NAMESPACE}/${NAME}-${BRANCH}"

    # A project image's branched version is built on top of its
    # 'dev' version. The only addition to the parent image is to
    # install the repo's code (typically a Python package) in
    # the image.
    local parent="${NAMESPACE}/${NAME}"

    build-image "${build_dir}" ${name} ${parent} ${timestamp} || return 1
    rm -rf "${build_dir}"
}


REPO=$(basename "${thisdir}")
NAMESPACE=$(cat "${thisdir}/docker/namespace") || exit 

NAME=
PARENT=
TIMESTAMP=
run_tests=yes
verbose_tests=
cov_fail_under=1
test_log_level=info
while [[ $# > 0 ]]; do
    if [[ "$1" == --name=* ]]; then
        NAME="$1"
        NAME="${NAME#--name=}"
        shift
    elif [[ "$1" == --name ]]; then
        shift
        if [[ $# == 0 ]]; then
            >&2 echo "image name expected following --name"
            exit 1
        fi
        NAME="$1"
        shift
    elif [[ "$1" == --parent=* ]]; then
        PARENT="$1"
        PARENT="${PARENT#--parent=}"
        shift
    elif [[ "$1" == --parent ]]; then
        shift
        if [[ $# == 0 ]]; then
            >&2 echo "parent name expected following --parent"
            exit 1
        fi
        PARENT="$1"
        shift
    elif [[ "$1" == --timestamp=* ]]; then
        TIMESTAMP="$1"
        TIMESTAMP="${TIMESTAMP#--timestamp=}"
        shift
    elif [[ "$1" == --timestamp ]]; then
        shift
        if [[ $# == 0 ]]; then
            >&2 echo "timestamp expected following --timestamp"
            exit 1
        fi
        TIMESTAMP="$1"
        shift
    elif [[ "$1" == --no-tests ]]; then
        run_tests=no
        shift
    elif [[ "$1" == --test-log-level=* ]]; then
        test_log_level="$1"
        test_log_level="${test_log_level#--test-log-level=}"
        shift
    elif [[ "$1" == --test-log-level ]]; then
        shift
        if [[ $# == 0 ]]; then
            >&2 echo "--test-log-level is missing argument"
            exit 1
        fi
        test_log_level="$1"
        shift
    elif [[ "$1" == --cov-fail-under=* ]]; then
        cov_fail_under="$1"
        cov_fail_under="${cov_fail_under#--cov-fail-under=}"
        shift
    elif [[ "$1" == --cov-fail-under ]]; then
        shift
        if [[ $# == 0 ]]; then
            >&2 echo "covarage requirement expected following --cov-fail-under"
            exit 1
        fi
        cov_fail_under="$1"
        shift
    else
        >&2 echo "unknown argument '$@'"
        exit 1
    fi
done

if [[ ("${NAME}" == '' && "${PARENT}" != '' ) || ("${NAME}" != '' && "${PARENT}" == '') ]]; then
    >&2 echo "WARNING! Usually --name and --parent are either both missing or both present, but you specified only one:"
    if [[ "${NAME}" == '' ]]; then
        >&2 echo "--parent="${PARENT}
    else
        >&2 echo "--name="${NAME}
    fi
fi

if [[ "${NAME}" == '' ]]; then
    NAME="${REPO}"
fi

if [[ "${TIMESTAMP}" == '' ]]; then
    >&2 echo "timestamp is missing!"
    exit 1
fi

start_time=$(date)

echo
echo '############################'
echo "start building dev image"
echo '----------------------------'
echo
dev_img_name="${NAMESPACE}/${NAME}"
build-dev ${TIMESTAMP} ${dev_img_name} || exit 1
echo


if [ -z ${TRAVIS_BRANCH+x} ]; then
    if [ -d "${thisdir}/.git" ]; then
        BRANCH=$(cat "${thisdir}/.git/HEAD")
        BRANCH="${BRANCH##*/}"
    else
        BRANCH=branch
    fi
    PUSH=no
else
    # `TRAVIS_BRANCH` is defined; this is happening on Github.
    BRANCH=${TRAVIS_BRANCH}
    PUSH=yes
fi
PUSH=no

echo
echo '############################'
echo "start building branch image"
echo '----------------------------'
echo
branch_img_name="${NAMESPACE}/${NAME}-${BRANCH}"
build-branch ${TIMESTAMP} ${branch_img_name} || exit 1
echo


if [[ "${run_tests}" == yes ]]; then
    ver=$(find-latest-image-local ${branch_img_name})
    ver="${ver#*:}"
    if [[ "${ver}" != ${TIMESTAMP} ]]; then
        >&2 echo "Could not find the newly built image. Was it deleted b/c it is identical to an older one?"
        >&2 echo "Proceed to run tests in the older image"
    fi
    echo
    echo '###########################'
    echo "run tests in branch image ${branch_img_name}:${ver}"
    echo '---------------------------'
    echo
    rm -rf /tmp/docker-build-tests
    mkdir -p /tmp/docker-build-tests/{data,log,cfg,tmp,src}
    run_docker \
        --workdir=/tmp \
        ${branch_img_name}:${ver} \
        py.test -s --log-cli-level info -v --showlocals \
        /opt/${REPO}/tests \
        --cov=/usr/local/lib/python3.8/dist-packages/${REPO//-/_} \
        --cov-fail-under ${cov_fail_under}
    if [[ $? == 0 ]]; then
        rm -rf /tmp/docker-build-tests
        echo
        echo TESTS PASSED
        echo
    else
        rm -rf /tmp/docker-build-tests
        echo
        echo TESTS FAILED
        echo
        exit 1
    fi
fi


if [[ "${PUSH}" == yes ]]; then
    echo
    echo
    echo '#######################'
    echo 'start pushing dev image'
    echo '-----------------------'
    echo
    push-image ${dev_img_name}
    echo
    echo
    echo '##########################'
    echo 'start pushing branch image'
    echo '--------------------------'
    echo
    push-image ${branch_img_name}
fi


end_time=$(date)
echo
echo "Started at ${start_time}"
echo "Finished at ${end_time}"
echo