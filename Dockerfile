FROM nginx
MAINTAINER James Hanlon

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y \
      curl \
      build-essential \
      python \
      python-dev \
      python-setuptools \
      mysql-client \
      libmysqlclient-dev \
      apache2-utils

# Moin Moin version.
ENV MM_VERSION 1.9.8
ENV MM_CSUM 4a616d12a03f51787ac996392f9279d0398bfb3b

# Download MoinMoin
RUN curl -LOC- -s \
      http://static.moinmo.in/files/moin-$MM_VERSION.tar.gz && \
    sha256sum moin-$MM_VERSION.tar.gz | grep -q $MM_SUM && \
    tar xzvf moin-$MM_VERSION.tar.gz --strip-components=1

# Install MoinMoin.
RUN (cd moinmoin-$MM_VERSION && \
     python setup.py install --force --prefix=/usr/local)
