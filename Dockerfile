FROM nginx
MAINTAINER James Hanlon

# Install packages.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y \
      curl \
      git \
      build-essential \
      python \
      python-dev \
      python-setuptools \
      python-docutils \
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
    mkdir /opt/moin/wiki && \
    mkdir /opt/moin/wiki/static && \
    cp -R /usr/local/share/moin/underlay /opt/moin/wiki/ && \
    cp -R /usr/local/lib/python2.7/dist-packages/MoinMoin/web/static/htdocs/* \
      /opt/moin/wiki/static/ && \
    chown -R www-data:www-data /opt/moin/wiki/underlay && \
    chown -R www-data:www-data /opt/moin/wiki/static

# Install the memodump theme.
RUN git clone https://github.com/dossist/moinmoin-memodump.git
RUN cp -R moinmoin-memodump/memodump /opt/moin/wiki/static/

# Add configuration.
COPY uwsgi.ini     /opt/
COPY uwsgi_params  /opt/
COPY CONFIG        /opt/
COPY init.sh       /opt/
COPY wikiconfig.py /opt/moin/wiki/
COPY moin.wsgi     /opt/moin/

# Nginx config.
RUN mkdir /etc/nginx/sites-available && \
    mkdir /etc/nginx/sites-enabled
COPY nginx.conf /etc/nginx/
COPY nginx-wiki.conf /etc/nginx/sites-available/
RUN rm /etc/nginx/conf.d/default.conf && \
    ln -s /etc/nginx/sites-available/nginx-wiki.conf \
          /etc/nginx/sites-enabled/nginx-wiki.conf

# Supervisor config.
COPY supervisord.conf /etc/supervisor/conf.d/supervisor.conf

EXPOSE 9090
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisor.conf"]
