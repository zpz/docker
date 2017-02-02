set -o nounset
set -o pipefail

thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd "$( dirname "${thisfile}" )" && pwd )"

PARENT="python:2.7.13-slim"

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

cat "$(dirname "${thisdir}")/dev_base.inc" >> "${thisdir}/Dockerfile"

cat >> "${thisdir}/Dockerfile" <<'EOF'

RUN pip install --no-cache-dir --upgrade \
        'pytest==3.0.5'

CMD ["python"]
EOF

echo
echo Building image "'${NAME}'"
echo
docker build -t "${NAME}" "${thisdir}"

