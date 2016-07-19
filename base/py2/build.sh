set -o nounset
set -o pipefail

thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd "$( dirname "${thisfile}" )" && pwd )"
parentdir="$(dirname "${thisdir}")"
parent_name=zppz/$(basename "${parentdir}")
parent_version=$(cat "${parentdir}"/version)
PARENT="${parent_name}:${parent_version}"

version=$(cat "${thisdir}"/version)
if [[ "${version}" < "${parent_version}" ]]; then
    echo "${parent_version}" > "${thisdir}"/version
    version=${parent_version}
fi
NAME=zppz/$(basename "${thisdir}"):"${version}"


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
EOF

cat >> "${thisdir}/Dockerfile" <<'EOF'

USER root
WORKDIR /


#-------------------
# Adapted content of the offical image python:2.7.12-slim
# adpatations:
#   install (and eventually uninstall) buildDeps  (refer to the Dockerfile of offiical python:3-slim
#   --enable-loadable-sqlite-extensions  for configure
#   install libsqlite3-0
#   use option -k for curl

# remove several traces of debian python
RUN apt-get purge -y python.*

# gpg: key 18ADD4FF: public key "Benjamin Peterson <benjamin@python.org>" imported
ENV GPG_KEY C01E1CAD5EA2C4F0B8E3571504C367C218ADD4FF

ENV PYTHON_VERSION 2.7.12

# if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
ENV PYTHON_PIP_VERSION 8.1.2

RUN set -ex \
	&& curl -fkSL "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz" -o python.tar.xz \
	&& curl -fkSL "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz.asc" -o python.tar.xz.asc \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_KEY" \
	&& gpg --batch --verify python.tar.xz.asc python.tar.xz \
	&& rm -r "$GNUPGHOME" python.tar.xz.asc \
    && apt-get update \
    && buildDeps=' \
            gcc \
            libbz2-dev \
            libc6-dev \
            liblzma-dev \
            libncurses-dev \
            libreadline-dev \
            libsqlite3-dev \
            libssl-dev \
            make \
            xz-utils \
            zlib1g-dev \
            ' \
    && apt-get install -y --no-install-recommends $buildDeps \
    && apt-get install -y --no-install-recommends libsqlite3-0 \
	&& mkdir -p /usr/src/python \
	&& tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz \
	&& rm python.tar.xz \
	\
	&& cd /usr/src/python \
	&& ./configure \
		--enable-shared \
        --enable-loadable-sqlite-extensions \
		--enable-unicode=ucs4 \
	&& make -j$(nproc) \
	&& make install \
	&& ldconfig \
	&& curl -fkSL 'https://bootstrap.pypa.io/get-pip.py' | python2 \
	&& pip install --no-cache-dir --upgrade pip==$PYTHON_PIP_VERSION \
	&& [ "$(pip list | awk -F '[ ()]+' '$1 == "pip" { print $2; exit }')" = "$PYTHON_PIP_VERSION" ] \
	&& find /usr/local -depth \
		\( \
		    \( -type d -a -name test -o -name tests \) \
		    -o \
		    \( -type f -a -name '*.pyc' -o -name '*.pyo' \) \
		\) -exec rm -rf '{}' + \
	&& rm -rf /usr/src/python ~/.cache \
    && apt-get purge -y --auto-remove $buildDeps \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    && apt-get -y autoremove \
    && apt-get clean


#----------------------------------
# Some more, including dev tools.

RUN pip install --no-cache-dir --upgrade \
        'ipython==5.0.0' \
        'pytest==2.9.2' \
        'requests==2.10.0' \
        'sh==1.11' \
        'toolz==0.8.0' \
    && ln -s /usr/local/bin/py.test /usr/local/bin/pytest \
    && pip install --no-cache-dir --upgrade \
        'ipdb==0.10.1' \
        'pudb==2016.2' \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
    && pip install --no-cache-dir --upgrade \
        'line_profiler==1.0' \
    && apt-get purge -y --auto-remove \
        build-essential \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    && apt-get -y autoremove \
    && apt-get clean


CMD ["python"]
EOF

echo
echo Building image "'${NAME}'"...
echo
docker build -t "${NAME}" "${thisdir}"


