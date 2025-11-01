# deep learning

ARG PARENT

FROM ${PARENT}
USER root


RUN pip-install \
        https://download.pytorch.org/whl/cpu/torch-1.1.0-cp36-cp36m-linux_x86_64.whl \
        https://download.pytorch.org/whl/cpu/torchvision-0.3.0-cp36-cp36m-linux_x86_64.whl \
        torchtext

RUN pip-install tensorflow tensorflow-probability

RUN pip-install matplotlib