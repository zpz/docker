# This image contains some data-centric Python tools
# along with a small set of R tools.
# The selections are not general, but rather are tailored to
# the needs of particular projects of the maintainer.

FROM python:3.4


RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        liblapack-dev gfortran \
        libhdf5-8 libhdf5-dev \
        r-base && \
    rm -rf /var/lib/apt/lists/*

RUN pip3 install -U --no-cache-dir pip setuptools wheel && \
    pip3 install --no-cache-dir numpy==1.10.4 pandas==0.17.1 && \
    pip3 install --no-cache-dir matplotlib==1.5.1 && \
    pip3 install --no-cache-dir scipy==0.17.0 && \
    pip3 install --no-cache-dir patsy==0.4.1 statsmodels==0.6.1 scikit-learn==0.17 && \
    pip3 install --no-cache-dir cvxpy==0.3.7 && \
    pip3 install --no-cache-dir sqlalchemy==1.0.11 && \
    pip3 install --no-cache-dir h5py==2.5.0 && \
    pip3 install --no-cache-dir requests==2.9.1 flask==0.10.1 bokeh==0.11.1 && \
    pip3 install --no-cache-dir \
        arrow==0.7.0 \
        click==6.2 \
        ipython==4.1.1 notebook==4.1.0 && \
        pytest==2.8.7 \
        rpy2==2.7.8 \
        sh==1.11 \
        Sphinx==1.3.5

# As of 2/04/2016, cvxpy has trouble
# installing on Python-3.5.

RUN apt-get -y autoremove && \
    apt-get clean

CMD ipython

