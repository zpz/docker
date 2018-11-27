ARG PARENT

FROM ${PARENT}
USER root

#---------------
# group and user

RUN groupadd --gid 1000 docker \
    && mkdir -p /home/docker-user \
    && useradd --uid 1000 --gid docker --no-user-group --home /home/docker-user --shell /bin/bash docker-user \
    && chown -R docker-user:docker /home/docker-user \
    && chmod -R u=rwx,g=rwx,o=r /home/docker-user

# Giving 'g=rwx' to /home/docker-user is a hack around mapped-volume permission issues.

# If root privilage is needed, install `sudo`, and add
# RUN usermod -a -G sudo docker-user \
#   && echo 'docker-user ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/docker-user \
#   && chmod 0440 /etc/sudoers.d/docker-user

# Subsequently, when you use `sudo command ...`, the environment is different.
# To preserve environment, use the `-E -H` options.
# However, strangely, `PYTHONPATH` is not preserved.
# You can simply do this:
#   sudo PYTHONPAH=$PYTHONPATH command ...

#-------------------------
# The very basic utilities

RUN apt-get update \
    && apt-get install -y --no-install-recommends --allow-unauthenticated \
        apt-utils \
    && apt-get install -y --no-install-recommends --allow-unauthenticated \
        bzip2 \
        curl \
        less \
        tree \
        unzip \
        xz-utils \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/*

COPY dotfiles/bash/bashrc /etc/bash.bashrc
RUN chmod +r /etc/bash.bashrc


ENV SHELL=/bin/bash


#-------------------------
# Some packages most useful for Python development related to
# testing, code analysis, code formatting, etc.
# Keep this selection to the minimum.

COPY dotfiles/ptpython/config.py /home/docker-user/.ptpython/

RUN pip install --no-cache-dir --upgrade \
        'coverage' \
        'Faker' \
        'mypy' \
        'ptpython' \
        'pylint' \
        'pytest' \
        'yapf' \
    && chown -R docker-user /home/docker-user/.ptpython

# Use `yapf` to format Python code in-place:
#   yapf -ir -vv --no-local-style .


CMD ["ptpython"]
WORKDIR /
