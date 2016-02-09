# This image contains some data-centric Python tools
# along with a small set of R tools.

FROM python:3.4.2

# As of 2/04/2016, cvxpy has trouble
# installing on Python-3.5.

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        wget \
        liblapack-dev gfortran \
        libhdf5-8=1.8.13+docs-15 libhdf5-dev=1.8.13+docs-15 \
        python3-dev=3.4.2-2 \
        r-base-core=3.1.1-1+b2 && \
    ln -s /usr/bin/python3-config /usr/bin/python-config && \
    rm -rf /var/lib/apt/lists/*

RUN pip3 install --upgrade pip setuptools wheel && \
    pip3 install --no-cache-dir numpy==1.10.4 pandas==0.17.1 && \
    pip3 install --no-cache-dir matplotlib==1.5.1 && \
    pip3 install --no-cache-dir scipy==0.17.0 && \
    pip3 install --no-cache-dir patsy==0.4.1 statsmodels==0.6.1 scikit-learn==0.17 && \
    pip3 install --no-cache-dir sqlalchemy==1.0.11 && \
    pip3 install --no-cache-dir h5py==2.5.0 && \
    pip3 install --no-cache-dir requests==2.9.1 flask==0.10.1 bokeh==0.11.1 && \
    pip3 install --no-cache-dir rpy2==2.7.8 && \
    pip3 install --no-cache-dir \
        arrow==0.7.0 \
        click==6.2 \
        ipython==4.1.1 notebook==4.1.0 && \
        pytest==2.8.7 \
        sh==1.11

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
ARG rpython=rPython_0.0-6.tar.gz
ARG rjsonio=RJSONIO_1.3-0.tar.gz

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
        ${bioc}/${zlibbioc} \
        ${cran}/${rpython} \
        ${cran}/${rjsonio} && \
    R CMD INSTALL \
        ${rjsonio} \
        ${rpython} \
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


RUN pip3 install --no-cache-dir \
        cvxpy==0.3.7 \
        Sphinx==1.3.5


RUN apt-get -y autoremove && \
    apt-get clean

WORKDIR /home

CMD ["/bin/bash"]

