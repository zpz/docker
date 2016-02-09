# docker build -t zppz/rr:0.1 -t zppz/rr:latest .
#
# I'm not using a ready-made R image because
# in my use cases the content of this file
# may be copy-pasted into a Python-centric image.

FROM buildpack-deps:jessie

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        wget \
        liblapack-dev gfortran \
        r-base-core && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /tmp
WORKDIR /tmp

ARG cran=https://cran.rstudio.com/src/contrib
ARG bioc=http://bioconductor.org/packages/release/bioc/src/contrib

ARG randomfields=RandomFields_3.1.8.tar.gz
ARG sp=sp_1.2-2.tar.gz
ARG lattice=lattice_0.20-33.tar.gz
ARG randomfieldsutils=RandomFieldsUtils_0.0.14.tar.gz
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
ARG json=jsonlite_0.9.19.tar.gz
ARG fields=fields_8.3-6.tar.gz
ARG spam=spam_1.3-0.tar.gz
ARG maps=maps_3.0.2.tar.gz
ARG uuid=uuid_0.1-2.tar.gz
ARG rhdf5=rhdf5_2.14.0.tar.gz
ARG zlibbioc=zlibbioc_1.16.0.tar.gz

RUN wget -nd \
        ${cran}/${randomfields} \
        ${cran}/${sp} \
        ${cran}/${lattice} \
        ${cran}/${randomfieldsutils} \
        ${cran}/${roxygen2} \
        ${cran}/${stringr} \
        ${cran}/${stringi} \
        ${cran}/${magrittr} \
        ${cran}/${brew} \
        ${cran}/${digest} \
        ${cran}/${rcpp} \
        ${cran}/${futilelogger} \
        ${cran}/${lambda} \
        ${cran}/${futileoptions} \
        ${cran}/${json} \
        ${cran}/${fields} \
        ${cran}/${spam} \
        ${cran}/${maps} \
        ${cran}/${uuid} \
        ${bioc}/${rhdf5} \
        ${bioc}/${zlibbioc} && \
    R CMD INSTALL \
        ${zlibbioc} \
        ${rhdf5} \
        ${uuid} \
        ${maps} \
        ${spam} \
        ${fields} \
        ${json} \
        ${futileoptions} \
        ${lambda} \
        ${futilelogger} \
        ${rcpp} \
        ${digest} \
        ${brew} \
        ${magrittr} \
        ${stringi} \
        ${stringr} \
        ${roxygen2} \
        ${randomfieldsutils} \
        ${lattice} \
        ${sp} \
        ${randomfields} && \
    rm -f *.tar.gz

WORKDIR /home

RUN apt-get -y autoremove && \
    apt-get clean

CMD ["R"]
