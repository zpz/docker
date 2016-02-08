# Some core Python data-centric tools that
# take a long time to build.

FROM python:3.4

# As of 2/04/2016, cvxpy has trouble
# installing on Python-3.5.

RUN apt-get update && apt-get install -y --no-install-recommends \
    liblapack-dev gfortran \
    libhdf5-8 libhdf5-dev

RUN pip3 install -U pip setuptools wheel && \
    pip3 install numpy==1.10.4 pandas==0.17.1 && \
    pip3 install matplotlib==1.5.1 && \
    pip3 install scipy==0.17.0 scikit-learn==0.17 && \
    pip3 install h5py==2.5.0

# libatlas-base-dev

# cleanup
RUN dpkg-reconfigure -au && \
    apt-get -y purge liblapack-dev gfortran libhdf5-dev && \
    apt-get -y autoremove && \
    apt-get clean

CMD python3

