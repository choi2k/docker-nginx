FROM alpine:latest
LABEL maintainer "admin@rexnote.com"

ENV NGINX_VERSION=1.10.3 \
    LUA_MODULE_VERSION=0.10.6 \
    NGINX_DEVEL_KIT_VERSION=0.3.0 \
    NGINX_CACHE_PURGE_VERSION=2.3 \
    NGINX_USER=nginx \
    NGINX_SITECONF_DIR=/etc/nginx/sites-enabled \
    NGINX_LOG_DIR=/var/log/nginx \
    NGINX_TEMP_DIR=/var/lib/nginx \
    NGINX_SETUP_DIR=/usr/src/nginx \
    GEOIP_VERSION=1.6.10

ARG WITH_DEBUG=false
ARG WITH_NDK=true
ARG WITH_LUA=true
ARG WITH_PURGE=true
ARG WITH_UPSTREAM_CHECK=true

ENV TZ=Asia/Hong_Kong

RUN apk --no-cache update && \
    apk --no-cache upgrade && \
apk --no-cache add tzdata openntpd

RUN apk --update add logrotate
ADD nginx /etc/logrotate.d/nginx
RUN echo "59 23 * * *	/usr/sbin/logrotate /etc/logrotate.d/nginx" >> /etc/crontabs/root

COPY setup/ ${NGINX_SETUP_DIR}/
RUN sh ${NGINX_SETUP_DIR}/install.sh

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 80/tcp 443/tcp

VOLUME ["${NGINX_SITECONF_DIR}"]
ENTRYPOINT ["/sbin/entrypoint.sh"]