# docker build -t zppz/r .
#
# I'm not using a ready-made R image because
# in my use cases the content of this file
# will be copy-pasted into a Python-centric image.

FROM ubuntu:latest

RUN apt-get update

RUN apt-get install -y --no-install-recommends littler r-base-core

RUN echo 'options(repos = c(CRAN = "https://cran.rstudio.com/"), download.file.method = "libcurl")' >> /etc/R/Rprofile.site
RUN echo 'source("/etc/R/Rprofile.site")' >> /etc/littler.r
RUN ln -s /usr/share/doc/littler/examples/install.r /usr/local/bin/install.r

RUN apt-get install -y --no-install-recommends build-essential

RUN install.r roxygen2 futile.logger jsonlite
RUN install.r sp RandomFields
RUN install.r fields
RUN install.r uuid

#RUN pip3 install rpy2

#RUN install.r BiocInstaller
#RUN echo 'source("https://bioconductor.org/biocLite.R"); biocLite("rhdf5")' | r
RUN Rscript -e 'source("https://bioconductor.org/biocLite.R"); biocLite("rhdf5")'


RUN apt-get -y autoremove
RUN apt-get clean
