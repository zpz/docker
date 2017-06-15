set -o nounset
set -o pipefail

thisfile="${BASH_SOURCE[0]}"
thisdir=$( cd "$( dirname "${thisfile}" )" && pwd )
parentdir=$(dirname "${thisdir}")
parent_name=$(cat "${parentdir}"/name)
parent_version=$(cat "${parentdir}"/version)
PARENT="${parent_name}":"${parent_version}"

version=$(cat "${thisdir}"/version)
if [[ "${version}" < "${parent_version}" ]]; then
    echo "${parent_version}" > "${thisdir}"/version
    version=${parent_version}
fi
NAME="$(cat "${thisdir}/name"):${version}"

echo
echo =====================================================
echo Creating Dockerfile for "'${NAME}'"...
cat > "${thisdir}"/Dockerfile <<EOF
# Dockerfile for image '${NAME}'
# Generated by 'build.sh'
#
# DO NOT EDIT.

FROM ${PARENT}
USER root
EOF

cat >> "${thisdir}"/Dockerfile <<'EOF'

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        cmake \
        gcc \
        g++ \
        libc6-dev \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    && pip install --no-cache-dir --upgrade \
        'cffi==1.10.0' \
        'cython==0.25.2' \
        'easycython==1.0.7' \
        'pybind11==2.1.1'

# `cmake` is required to build `pybind11` tests.
# `pybind11` header files are stored in /usr/local/include/python3.5m/pybind11/

ENV LLVM_VERSION=4.0

#RUN apt-key adv --keyserver ha.pool.sks-keyservers.net --recv 15CF4D18AF4F7421 \
RUN curl -skL --retry 3 http://apt.llvm.org/llvm-snapshot.gpg.key \
        | apt-key add - \
    && echo "deb http://apt.llvm.org/jessie/ llvm-toolchain-jessie-${LLVM_VERSION} main" > /etc/apt/sources.list.d/llvm.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        libllvm-${LLVM_VERSION} llvm-${LLVM_VERSION}-dev \
    && rm -rf /var/lib/apt/lists/* \
    && export LLVM_CONFIG=/usr/lib/llvm-${LLVM_VERSION}/bin/llvm-config \
    && pip install --no-cache-dir --upgrade \
        'llvmlite==0.18.0' \
        'numba==0.33.0' \
EOF

echo
echo Building image "'${NAME}'"
echo
docker build -t "${NAME}" "${thisdir}"


