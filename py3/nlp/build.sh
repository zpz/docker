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

# This is a catch-all image for learning purposes.

#=============================
# Generated by 'build.sh'
#
# DO NOT EDIT.
#=============================

FROM ${PARENT}
USER root
EOF

cat >> "${thisdir}"/Dockerfile <<'EOF'

RUN pip install --no-cache-dir --upgrade \
        'textblob==0.12.0' \
    && python -m nltk.downloader -d /usr/share/nltk_data \
        brown punkt wordnet averaged_perceptron_tagger \
        conll2000 movie_reviews

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        gcc \
        g++ \
        libgomp1 \
    && pip install --no-cache-dir --upgrade \
        'spacy==1.8.2' \
    && apt-get purge -y --auto-remove \
        gcc \
        g++ \
    && rm -rf /var/lib/apt/lists/* /tmp/*

RUN python -m spacy download en
EOF

echo
echo Building image "'${NAME}'"
echo
docker build -t "${NAME}" "${thisdir}"


