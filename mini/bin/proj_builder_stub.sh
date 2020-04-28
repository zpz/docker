thisdir="$( pwd )"


function build-dev {
    timestamp="$1"
    local name="${NAMESPACE}/${NAME}"
    local builddir="${thisdir}/docker"
    local parent
    if [[ "${PARENT}" == '' ]]; then
        parent=$(cat "${builddir}/parent") || return 1
    else
        parent="${PARENT}"
    fi
    build-image ${builddir} ${name} ${parent} ${timestamp} || return 1
    if [[ ${PUSH} == yes ]]; then
        push-image ${name}
    fi
}


function build-branch {
    timestamp="$1"
    local build_dir="/tmp/${REPO}"
    rm -rf ${build_dir}
    mkdir -p ${build_dir}/src
    [ -d ${thisdir}/src ] && cp -R ${thisdir}/src ${build_dir}/src/src
    [ -d ${thisdir}/bin ] && cp -R ${thisdir}/bin ${build_dir}/src/bin
    [ -d ${thisdir}/sysbin ] && cp -R ${thisdir}/sysbin ${build_dir}/src/sysbin
    [ -d ${thisdir}/tests ] && cp -R ${thisdir}/tests ${build_dir}/src/tests
    [ -d ${thisdir}/setup.py ] && cp -R ${thisdir}/setup.py ${build_dir}/src/
    [ -d ${thisdir}/setup.cfg ] && cp -R ${thisdir}/setup.cfg ${build_dir}/src/
    [ -d ${thisdir}/MANIFEST.in ] && cp -R ${thisdir}/MANIFEST.in ${build_dir}/src/
    [ -d ${thisdir}/install.sh ] && cp -R ${thisdir}/install.sh ${build_dir}/src/

    cat > "${build_dir}/Dockerfile" << EOF
ARG PARENT
FROM \${PARENT}
USER root

RUN mkdir -p /tmp/build
COPY src/ /tmp/build

RUN cd /tmp/build \\
    && ( if [ -f install.sh ]; then bash install.sh; elif [ -f setup_py ]; then pip-install . ; fi) \\
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

    if [[ "${PUSH}" == yes ]]; then
        push-image ${name}
    fi
}


REPO=$(basename "${thisdir}")
NAMESPACE=$(cat "${thisdir}/docker/namespace") || exit 


PUSH=no
if [ -z ${TRAVIS_BRANCH+x} ]; then
    if [ -d "${thisdir}/.git" ]; then
        BRANCH=$(cat "${thisdir}/.git/HEAD")
        BRANCH="${BRANCH##*/}"
    else
        BRANCH=branch
    fi
else
    # `TRAVIS_BRANCH` is defined; this is happening on Github.
    BRANCH=${TRAVIS_BRANCH}
    PUSH=yes
fi

NAME=
PARENT=
TIMESTAMP=
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
    else
        >&2 echo "unknown argument '$@'"
        exit 1
    fi
done

if [[ "${TIMESTAMP}" == '' ]]; then
    >&2 echo "timestamp is missing!"
    exit 1
fi

if [[ "${NAME}" == '' ]]; then
    NAME="${REPO}"
fi

start_time=$(date)

echo "start building dev image"
echo
build-dev ${TIMESTAMP} || exit 1
echo

echo "start building branch image"
echo
build-branch ${TIMESTAMP} || exit 1

end_time=$(date)
echo
echo "Started at ${start_time}"
echo "Finished at ${end_time}"
