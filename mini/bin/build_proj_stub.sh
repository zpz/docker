thisdir="$( pwd )"
if [ ! -d "${thisdir}/.git" ]; then
    echo "Please `cd` the root level of the repo and try again"
    exit 1
fi

# BRANCH=$(cat "${thisdir}/.git/HEAD")
# BRANCH="${BRANCH##*/}"
if [ -z ${TRAVIS_BRANCH+x} ]; then
    BRANCH=''
else
    BRANCH=${TRAVIS_BRANCH}
fi
if [[ "${BRANCH}" == master ]] || [[ "${BRANCH}" == develop ]]; then
    PUSH=yes
else
    PUSH=no
fi


REPO=$(basename "${thisdir}")


function build-dev {
    builddir="${thisdir}/docker"
    build-image ${builddir} zppz/${REPO}
}


function build-branch {
    name="zppz/${REPO}-${BRANCH}"

    build_dir="/tmp/${REPO}"
    rm -rf ${build_dir}
    mkdir -p ${build_dir}
    cp -rf "${thisdir}" "${build_dir}/src"

    cat > "${build_dir}/Dockerfile" << EOF
ARG PARENT
FROM \${PARENT}
USER root

RUN mkdir -p /tmp/build
COPY src/ /tmp/build

RUN cd /tmp/build \\
    && pip-install . \\
    && rm -rf /opt/${REPO} && mkdir -p /opt/${REPO} \\
    && mkdir -p bin tests \\
    && mv -f bin tests "/opt/${REPO}/" \\
    && cd / \\
    && rm -rf /tmp/build

ENV PATH=/opt/${REPO}/bin:\${PATH}
EOF

    echo zppz/${REPO} > "${build_dir}/parent"

    build-image "${build_dir}" ${name} || return 1
    rm -rf "${build_dir}"
}


if [[ "${BRANCH}" == master ]]; then
    old_branch_img=$(find-latest-image zppz/${REPO}-${BRANCH})
    build-branch || exit 1
    new_branch_img=$(find-latest-image zppz/${REPO}-${BRANCH})
    if [[ "${new_branch_img}" == "${old_branch_img}" ]]; then
        new_branch_img=-
    fi

    if [[ "${new_branch_img}" != - ]] && [[ "${PUSH}" == yes ]]; then
        echo
        echo
        echo "=== pushing image to dockerhub ==="
        docker login --username ${DOCKERHUBUSERNAME} --password ${DOCKERHUBPASSWORD}
        echo
        echo "Pushing '${new_branch_img}'"
        docker push "${new_branch_img}"
    fi

else
    old_dev_img=$(find-latest-image zppz/${REPO})
    build-dev || exit 1
    new_dev_img=$(find-latest-image-local zppz/${REPO})
    if [[ "${new_dev_img}" == "${old_dev_img}" ]]; then
        new_dev_img=-
    fi

    old_branch_img=$(find-latest-image zppz/${REPO}-${BRANCH})
    build-branch || exit 1
    new_branch_img=$(find-latest-image zppz/${REPO}-${BRANCH})
    if [[ "${new_branch_img}" == "${old_branch_img}" ]]; then
        new_branch_img=-
    fi

    if [[ "${new_dev_img}" != - ]] || [[ "${new_branch_img}" != - ]] && [[ "${PUSH}" == yes ]]; then
        echo
        echo
        echo "=== pushing images to dockerhub ==="
        docker login --username ${DOCKERHUBUSERNAME} --password ${DOCKERHUBPASSWORD}
        echo
        if [[ "${new_dev_img}" != - ]]; then
            echo "pushing '${new_dev_img}'..."
            docker push "${new_dev_img}"
        fi
        if [[ "${new_branch_img}" != - ]]; then
            echo "pushing '${new_branch_img}'..."
            docker push "${new_branch_img}"
        fi
    fi
fi
