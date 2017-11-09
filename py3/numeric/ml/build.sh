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

RUN pip install --no-cache-dir --upgrade \
        'scikit-learn==0.19.1'
EOF

echo
echo Building image "'${NAME}'"
echo
docker build -t "${NAME}" "${thisdir}"


