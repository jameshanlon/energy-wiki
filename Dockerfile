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
    mkdir moin && \
    tar xf moin-$MM_VERSION.tar.gz -C moin --strip-components=1

# Install MoinMoin.
# Code package in /usr/local/lib/python2.7/dist-packages.
# Rest of the Moin Moin data to /usr/local/share/moin.
RUN (cd moin && \
     python setup.py install --record=install.log --force --prefix=/usr/local)

# Add configuration.
ADD uwsgi_params /opt/
ADD wikiconfig.py /usr/local/share/moin/config/
ADD moin.wsgi /usr/local/share/moin/server/

# Nginx config.
RUN mkdir /etc/nginx/sites-available && \
    mkdir /etc/nginx/sites-enabled
COPY nginx.conf /etc/nginx/nginx.conf
COPY nginx-wiki.conf /etc/nginx/sites-available/
RUN rm /etc/nginx/conf.d/default.conf && \
    ln -s /etc/nginx/sites-available/nginx-pledge.conf \
          /etc/nginx/sites-enabled/nginx-pledge.conf
