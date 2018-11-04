ARG PARENT

FROM $PARENT
USER root


COPY dotfiles/bash/bashrc /etc/bash.bashrc
RUN chmod +r /etc/bash.bashrc
ENV SHELL=/bin/bash

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


