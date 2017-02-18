set -o nounset
set -o pipefail

thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd "$( dirname "${thisfile}" )" && pwd )"
PARENT=debian:jessie

version=$(cat "${thisdir}"/version)
NAME="$(cat "${thisdir}/name"):${version}"

echo
echo =====================================================
echo Creating Dockerfile for ${NAME}
cat > "${thisdir}/Dockerfile" <<EOF
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


#--------------
# latex

# textlive-latex-extra provides 'lastpage', among others.

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        texlive-base \
        texlive-fonts-recommended \
        texlive-latex-base \
        texlive-latex-extra \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    && apt-get -y autoremove \
    && apt-get clean


RUN curl -skL https://github.com/zpz/latex/archive/master.tar.gz -o - |tar xz -C /tmp/ \
    && mv /tmp/latex-master/bin/* /usr/local/bin/ \
    && mkdir -p /usr/local/share/texmf/tex/latex \
    && mv /tmp/latex-master/sty /usr/local/share/texmf/tex/latex/zz \
    && chmod +x /usr/local/bin/* \
    && texhash \
    && rm -rf /tmp/*


# RUN apt-get update \
#     && apt-get install -y --no-install-recommends \
#         build-essential \
#     && curl -sL http://ftp.math.utah.edu/pub/bibclean/bibclean-2.17.tar.gz -o - |tar xz -C /tmp/ \
#     && (cd /tmp/bibclean-2.17 && ./configure && make all check install) \
#     && curl -sL http://ftp.math.utah.edu/pub/bibparse/bibparse-1.11.tar.gz -o - |tar xz -C /tmp/ \
#     && (cd /tmp/bibparse-1.11 && ./configure && make all check install) \
#     && curl -sL http://ftp.math.utah.edu/pub/biblabel/biblabel-0.09.tar.gz -o - |tar xz -C /tmp/ \
#     && (cd /tmp/biblabel-0.09 && ./configure && make all check install ) \
#     && curl -sL http://ftp.math.utah.edu/pub/biborder/biborder-0.17.tar.gz -o - |tar xz -C /tmp/ \
#     && (cd /tmp/biborder-0.17 && ./configure && make all check install ) \
#     && apt-get purge -y --auto-remove \
#         build-essential \
#     && rm -rf /var/lib/apt/lists/* \
#     && apt-get -y autoremove \
#     && apt-get clean
#     \
#     && curl -sL https://github.com/zpz/latex/archive/master.tar.gz -o - |tar xz -C /tmp/ \
#     && cp /tmp/latex-master/bin/* /usr/local/bin \
#     && mv /tmp/latex-master/sty /usr/share/texmf/tex/latex/zz \
#     && chmod +x /usr/local/bin/* \
#     && rm -rf /tmp/*

EOF

cat "$(dirname "${thisdir}")/base.in" >> "${thisdir}/Dockerfile"

cat >> "${thisdir}/Dockerfile" <<'EOF'

#-----------
# startup

CMD ["/bin/bash"]
EOF


echo
echo Building image "'${NAME}'"
echo
docker build -t "${NAME}" "${thisdir}"

