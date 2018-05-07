set -o nounset
set -o pipefail

thisfile="${BASH_SOURCE[0]}"
thisdir=$( cd "$( dirname "${thisfile}" )" && pwd )
parentdir=$(dirname "${thisdir}")
parent_name=$(cat "${parentdir}"/name)
parent_version=$(cat "${parentdir}"/version)
PARENT="${parent_name}":"${parent_version}"

name=$(cat "${thisdir}/name")
version=$(date +%Y%m%d)
NAME="${name}:${version}"

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
        'numpy' \
        'keras' \
        'pandas' \
        'scikit-learn' \
        'scipy' \
        'statsmodels' \
        'tensorflow' \
        'torch' \
        'torchvision'

RUN pip install --no-cache-dir --upgrade \
        'bokeh' \
        'holoviews' \
        'matplotlib'

EOF

echo
echo Building image "'${NAME}'"
echo
docker build -t "${NAME}" "${thisdir}"
rm -f ${thisdir}/Dockerfile
echo ${version} > ${thisdir}/version

echo
python ../../../pyinstall.py \
    --cmd=py3ml \
    --dockercmd=ptpython \
    --options="-it --rm"


