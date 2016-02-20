# This image contains basic Python and R installation along with
# tools for interactions between Python and R.

FROM python:3.5.1-slim


ENV R_VERSION 3.2.3-6


RUN echo "deb http://http.debian.net/debian sid main" > /etc/apt/sources.list.d/debian-unstable.list


RUN apt-get update \
    && apt-get install -y --no-install-recommends --fix-missing \
        less \
        locales \
        vim-tiny \
    && ln -s /usr/bin/vim.tiny /usr/bin/vim \
    && ln -s -f /usr/local/bin/python3-config /usr/local/bin/python-config \
    && pip3 install --no-cache-dir --upgrade pip setuptools wheel \
    \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    && apt-get -y autoremove \
    && apt-get clean


#--------
# Locale

ENV TZ=America/Los_Angeles
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen en_US.utf8 \
    && /usr/sbin/update-locale LANG=en_US.UTF-8



# Note: official Python image gets the link 'python-config' wrong.
#
# Do not keep 'build-essential' in an image; it makes huge images.

RUN apt-get update \
    && apt-get install -t unstable -y --no-install-recommends --fix-missing \
        build-essential pkg-config \
        r-base-core=${R_VERSION} \
        r-base-dev=${R_VERSION} \
    && echo 'install.packages(\
        c("rPython", "futile.logger"), \
        repos="http://cran.us.r-project.org", \
        dependencies=c("Depends", "Imports"), \
        clean=TRUE, keep_outputs=FALSE)' > /tmp/packages.R \
    && Rscript /tmp/packages.R \
    \
    && pip3 install --no-cache-dir --upgrade rpy2==2.7.8 \
    && pip3 install --no-cache-dir --upgrade sh==1.11 \
    \
    && apt-get purge -y --auto-remove build-essential pkg-config \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    && apt-get -y autoremove \
    && apt-get clean

#--------------
# Environment

RUN echo "alias ..='cd ..'" >> /root/.bashrc \
    && echo "alias back='cd -'" >> /root/.bashrc \
    && echo "alias ls='ls -FGh --color'" >> /root/.bashrc \
    && echo "alias dir='ls -alg --color'" >> /root/.bashrc \
    && echo "alias cp='cp -i'" >> /root/.bashrc \
    && echo "alias rm='rm -i'" >> /root/.bashrc \
    && echo "alias mv='mv -i'" >> /root/.bashrc \
    && echo "source /root/.bashrc" >> /root/.bash_profile


WORKDIR /home

CMD ["/bin/bash"]

