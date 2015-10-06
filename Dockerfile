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
ENV MM_CSUM a74ba7fd8cf09b9e8415a4c45d7389ea910c09932da50359ea9796e3a30911a6

# Download MoinMoin
RUN curl -LOC- -s \
      http://static.moinmo.in/files/moin-$MM_VERSION.tar.gz && \
    sha256sum moin-$MM_VERSION.tar.gz | grep -q $MM_CSUM && \
    tar xzvf moin-$MM_VERSION.tar.gz

# Install MoinMoin.
RUN (cd moin-$MM_VERSION && \
     python setup.py install --force --prefix=/usr/local)
