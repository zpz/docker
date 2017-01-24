set -o nounset
set -o pipefail

thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd "$( dirname "${thisfile}" )" && pwd )"

PARENT="python:3.5.2-slim"

version=$(cat "${thisdir}"/version)
NAME="$(cat "${thisdir}/name"):${version}"


echo
echo =====================================================
echo Creating Dockerfile for "'${NAME}'"
cat > "${thisdir}"/Dockerfile <<EOF
# Dockerfile for image '${NAME}'

#===========================
# Generated by 'build.sh'.
#
# DO NOT EDIT.
#===========================

FROM ${PARENT}

USER root
WORKDIR /

EOF

cat "$(dirname "${thisdir}")/img_dev_base" >> "${thisdir}/Dockerfile"

cat >> "${thisdir}/Dockerfile" <<'EOF'

RUN pip install --no-cache-dir --upgrade \
        'ipython==5.1.0' \
        'pytest==3.0.5' \
        'numpy==1.12.0' \
        'requests==2.12.4'

CMD ["python"]
EOF

echo
echo Building image "'${NAME}'"
echo
docker build -t "${NAME}" "${thisdir}"

