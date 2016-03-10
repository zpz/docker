FROM python:3.5.1-slim

USER root

# Note: official Python image gets the link 'python-config' wrong.

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        less \
        locales \
        vim \
    && ln -s -f /usr/local/bin/python3-config /usr/local/bin/python-config \
    \
    && pip install --no-cache-dir --upgrade \
        pip==8.0.3 \
        setuptools==20.2.2 \
        wheel==0.29.0 \
    && pip install --no-cache-dir --upgrade \
        ipdb==0.9.0 \
        ipython==4.1.1 \
        pylint==1.5.4 \
        pytest==2.9.0 \
        pytest-cov==2.2.1 \
        pudb==2016.1 \
        requests==2.9.1 \
        sh==1.11 \
        six==1.10.0 \
        yapf==0.6.2 \
    \
    && ln -s /usr/local/bin/py.test /usr/local/bin/pytest \
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

#-------------
# bash and vim

COPY dotfiles/bashrc /etc/bash.bashrc
COPY dotfiles/vimrc /etc/vim/vimrc.local
COPY dotfiles/vim/ /etc/vim/


# Although we make ipython available,
# we still launch 'python' by default because the launch time is
# noticeably shorter.
# IPython can be launched instead by either adding it to the
# 'docker run' command or creating a dedicated command alias.

WORKDIR /

CMD ["python"]

