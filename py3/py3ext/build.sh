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

#=============================
# Generated by 'build.sh'
#
# DO NOT EDIT.
#=============================

FROM ${PARENT}
EOF

cat >> "${thisdir}"/Dockerfile <<'EOF'

USER root
WORKDIR /

RUN pip install --no-cache-dir --upgrade \
        'cffi>=1.9.1' \
        'cython>=0.25.2' \
        'cppimport>=16.6.24' \
        'easycython>=1.0.4' \
        'pybind11>=2.0.1'

# `pybind11` header files are stored in /usr/local/include/python3.6m/pybind11/

ENV LLVM_VERSION=3.8

# `cmake` is required to build `pybind11` tests.

RUN apt-key adv --keyserver ha.pool.sks-keyservers.net --recv 15CF4D18AF4F7421 \
    && echo "deb http://llvm.org/apt/jessie/ llvm-toolchain-jessie-${LLVM_VERSION} main" > /etc/apt/sources.list.d/llvm.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        libllvm-${LLVM_VERSION} llvm-${LLVM_VERSION}-dev \
        cmake \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && export LLVM_CONFIG=/usr/lib/llvm-${LLVM_VERSION}/bin/llvm-config \
    && pip install --no-cache-dir --upgrade \
        'llvmlite==0.15.0' \
        'numba==0.31.0'

CMD ["/bin/bash"]
EOF

echo
echo Building image "'${NAME}'"
echo
docker build -t "${NAME}" "${thisdir}"


