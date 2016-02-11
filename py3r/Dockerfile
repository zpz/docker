# This image contains some data-centric Python tools
# along with a small set of R tools,
# as well as tools for interactions between Python and R.
# The choice of tools are not generic;
# instead it's tailored to some specific needs.

FROM python:3.5.1-slim


ENV R_BASE_VERSION 3.2.3

RUN echo "deb http://http.debian.net/debian sid main" > /etc/apt/sources.list.d/debian-unstable.list

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        ed \
        less \
        locales \
        vim-tiny \
    && ln -s /usr/bin/vim.tiny /usr/bin/vim \
    && apt-get install -y --no-install-recommends \
        build-essential \
        libfreetype6 libfreetype6-dev libxft-dev pkg-config    # for matplotlib \
        liblapack liblapack-dev gfortran    # for scipy \
        libreadline-dev    # for rPython \
    && apt-get install -y --no-install-recommends -t unstable \
        r-base=${R_BASE_VERSION} \
        r-base-dev=${R_BASE_VERSION} \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    && apt-get -y autoremove && \
    && apt-get clean


RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen en_US.utf8 \
    && /usr/sbin/update-locale LANG=en_US.UTF-8


ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8


RUN echo 'install.packages(c("roxygen2", "futile.logger", "testthat", "rpython"), \
        repos="http://cran.us.r-project.org", dependencies=TRUE)' > /tmp/packages.R \
    && Rscript /tmp/packages.R \
    && echo 'install.packages(c("rhdf5"), \
        repos="http://bioconductor.org", dependencies=TRUE)' > /tmp/packages.R \
    && Rscript /tmp/packages.R \
    && rm -rf /tmp/*


#------------
# Python

RUN pip3 install --upgrade pip setuptools wheel && \
    pip3 install --no-cache-dir requests==2.9.1 && \
    pip3 install --no-cache-dir numpy==1.10.4 && \
    pip3 install --no-cache-dir pandas==0.17.1 && \
    pip3 install --no-cache-dir matplotlib==1.5.1 && \
    pip3 install --no-cache-dir scipy==0.17.0 && \
    pip3 install --no-cache-dir scikit-learn==0.17 && \
    pip3 install --no-cache-dir ipython==4.1.1 notebook==4.1.0 && \
    pip3 install --no-cache-dir h5py==2.5.0 && \
    pip3 install --no-cache-dir rpy2==2.7.8 && \
    pip3 install --no-cache-dir pytest==2.8.7 sh==1.11


#------------
# R

# Install these R packages; others are their dependencies:
#   roxygen2
#   futile.logger
#   testthat
#   rpython
#   rhdf5


ARG cran=https://cran.rstudio.com/src/contrib
ARG bioc=http://bioconductor.org/packages/release/bioc/src/contrib

ARG roxygen2=roxygen2_5.0.1.tar.gz
ARG stringr=stringr_1.0.0.tar.gz
ARG stringi=stringi_1.0-1.tar.gz
ARG magrittr=magrittr_1.5.tar.gz
ARG brew=brew_1.0-6.tar.gz
ARG digest=digest_0.6.9.tar.gz
ARG rcpp=Rcpp_0.12.3.tar.gz
ARG futilelogger=futile.logger_1.4.1.tar.gz
ARG lambda=lambda.r_1.1.7.tar.gz
ARG futileoptions=futile.options_1.0.0.tar.gz
ARG memoise=memoise_1.0.0.tar.gz
ARG crayon=crayon_1.3.1.tar.gz
ARG praise=praise_1.0.0.tar.gz
ARG testthat=testthat_0.11.0.tar.gz
ARG rhdf5=rhdf5_2.14.0.tar.gz
ARG zlibbioc=zlibbioc_1.16.0.tar.gz
ARG rpython=rPython_0.0-6.tar.gz
ARG rjsonio=RJSONIO_1.3-0.tar.gz

RUN install.r -- -c --no-docs \
    roxygen2 \
    futile.logger \
    testthat \
    rpython

RUN install.r -- -c --no-docs \
    rhdf5

# RUN curl -so tmp.tar.gz ${cran}/${futileoptions}; R CMD INSTALL -c --no-docs tmp.tar.gz \
#     && curl -so tmp.tar.gz ${cran}/${lambda}; R CMD INSTALL -c --no-docs tmp.tar.gz \
#     && curl -so tmp.tar.gz ${cran}/${futilelogger}; R CMD INSTALL -c --no-docs tmp.tar.gz \
#     && curl -so tmp.tar.gz ${cran}/${rcpp}; R CMD INSTALL -c --no-docs tmp.tar.gz \
#     && curl -so tmp.tar.gz ${cran}/${digest}; R CMD INSTALL -c --no-docs tmp.tar.gz \
#     && curl -so tmp.tar.gz ${cran}/${brew}; R CMD INSTALL -c --no-docs tmp.tar.gz \
#     && curl -so tmp.tar.gz ${cran}/${magrittr}; R CMD INSTALL -c --no-docs tmp.tar.gz \
#     && curl -so tmp.tar.gz ${cran}/${stringi}; R CMD INSTALL -c --no-docs tmp.tar.gz \
#     && curl -so tmp.tar.gz ${cran}/${stringr}; R CMD INSTALL -c --no-docs tmp.tar.gz \
#     && curl -so tmp.tar.gz ${cran}/${roxygen2}; R CMD INSTALL -c --no-docs tmp.tar.gz \
#     && curl -so tmp.tar.gz ${cran}/${memoise}; R CMD INSTALL -c --no-docs tmp.tar.gz \
#     && curl -so tmp.tar.gz ${cran}/${crayon}; R CMD INSTALL -c --no-docs tmp.tar.gz \
#     && curl -so tmp.tar.gz ${cran}/${praise}; R CMD INSTALL -c --no-docs tmp.tar.gz \
#     && curl -so tmp.tar.gz ${cran}/${testthat}; R CMD INSTALL -c --no-docs tmp.tar.gz \
#     && curl -so tmp.tar.gz ${cran}/${rjsonio}; R CMD INSTALL -c --no-docs tmp.tar.gz \
#     && curl -so tmp.tar.gz ${cran}/${rpython}; R CMD INSTALL -c --no-docs tmp.tar.gz \
#     && curl -so tmp.tar.gz ${cran}/${zlibbioc}; R CMD INSTALL -c --no-docs tmp.tar.gz \
#     && curl -so tmp.tar.gz ${cran}/${rhdf5}; R CMD INSTALL -c --no-docs tmp.tar.gz \
#     rm -f tmp.tar.gz


#--------------
# Environment

RUN echo "alias ..='cd ..'" >> /root/.bashrc && \
    echo "alias back='cd -'" >> /root/.bashrc && \
    echo "alias ls='ls -FGh --color'" >> /root/.bashrc && \
    echo "alias dir='ls -alg --color'" >> /root/.bashrc && \
    echo "alias cp='cp -i'" >> /root/.bashrc && \
    echo "alias rm='rm -i'" >> /root/.bashrc && \
    echo "alias mv='mv -i'" >> /root/.bashrc && \
    echo "source /root/.bashrc" >> /root/.bash_profile

WORKDIR /home

CMD ["/bin/bash"]

