# deep learning

ARG PARENT

FROM ${PARENT}
USER root


RUN pip-install \
        https://download.pytorch.org/whl/cpu/torch-1.0.0-cp36-cp36m-linux_x86_64.whl \
        torchvision \
        torchtext

RUN pip-install tensorflow tensorflow-probability
