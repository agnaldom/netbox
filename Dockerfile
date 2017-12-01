FROM python:3.6-alpine

RUN apk add --no-cache \
      bash \
      build-base \
      ca-certificates \
      cyrus-sasl-dev \
      graphviz \
      jpeg-dev \
      libffi-dev \
      libxml2-dev \
      libxslt-dev \
      openldap-dev \
      openssl-dev \
      postgresql-dev \
      wget

RUN pip install gunicorn

WORKDIR /opt/

ARG BRANCH=master
ARG URL=https://github.com/digitalocean/netbox/archive/$BRANCH.tar.gz
RUN wget -q -O - "${URL}" | tar xz \
  && mv netbox* netbox


WORKDIR /opt/netbox
RUN pip install -r requirements.txt
RUN pip install napalm
RUN pip install django-auth-ldap

COPY ./configuration.py /opt/netbox/netbox/netbox/configuration.py
COPY ./gunicorn_config.py /opt/netbox/
COPY ./nginx.conf /tmp/nginx.conf

WORKDIR /opt/netbox/netbox

COPY ./docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT [ "/docker-entrypoint.sh" ]

EXPOSE 8001

VOLUME ["/etc/netbox-nginx/"]
VOLUME ["/opt/netbox/netbox/static/"]

CMD ["gunicorn", "--log-level debug", "-c /opt/netbox/gunicorn_config.py", "netbox.wsgi"]
