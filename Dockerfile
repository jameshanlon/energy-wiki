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
      apache2-utils \
      supervisor
RUN easy_install pip && \
    pip install uwsgi

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
RUN (cd moin && \
     python setup.py install --record=install.log --force --prefix=/usr/local)

# Create a new wiki instance.
RUN mkdir /opt/moin && \
    cp -R /usr/local/share/moin/config /opt/moin/ && \
    cp -R /usr/local/share/moin/data /opt/moin/ && \
    cp -R /usr/local/share/moin/server /opt/moin/ && \
    cp -R /usr/local/share/moin/underlay /opt/moin/ && \
    cp -avi /usr/local/lib/python2.7/dist-packages/MoinMoin/web/static/htdocs /opt/moin/static

# Add configuration.
ADD uwsgi.ini /opt/
ADD uwsgi_params /opt/
ADD wikiconfig.py /opt/moin/config/
ADD moin.wsgi /opt/moin/server/

# Nginx config.
RUN mkdir /etc/nginx/sites-available && \
    mkdir /etc/nginx/sites-enabled
COPY nginx.conf /etc/nginx/nginx.conf
COPY nginx-wiki.conf /etc/nginx/sites-available/
RUN rm /etc/nginx/conf.d/default.conf && \
    ln -s /etc/nginx/sites-available/nginx-pledge.conf \
          /etc/nginx/sites-enabled/nginx-pledge.conf

# Supervisor config.
COPY supervisord.conf /etc/supervisor/conf.d/supervisor.conf

EXPOSE 8000
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisor.conf"]
