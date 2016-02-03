# docker build -t zppz/python3-data .

FROM python:3

RUN pip3 install --upgrade pip

RUN apt-get update

# development
RUN pip3 install sh arrow click
RUN pip3 install pytest

# numpy, scipy, analytics, modeling
RUN pip3 install numpy
RUN pip3 install pandas

RUN apt-get install -y libatlas-base-dev liblapack-dev gfortran
RUN pip3 install scipy
RUN pip3 install patsy statsmodels
RUN pip3 install scikit-learn
RUN pip3 install matplotlib seaborn

# failed to install cvxpy
# 'multiprocess' is not in python-3.5.
# should work in python-3.4.
#RUN apt-get install -y python-dev
#RUN pip3 install cvxpy

# database
RUN pip3 install sqlalchemy

# web
RUN pip3 install requests
RUN pip3 install flask
RUN pip3 install wtforms flask-login flask-openid \
    flask-mail flask-sqlalchemy flask-wtf
RUN pip3 install bokeh

# HDF5
RUN apt-get install -y python3-h5py

# cleanup
RUN apt-get -y remove libatlas-base-dev liblapack-dev gfortran
RUN apt-get -y autoremove
RUN apt-get -y clean

