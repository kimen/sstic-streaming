FROM alpine:latest as builder

ARG NGINX_VERSION=1.16.1
ARG NGINX_RTMP_VERSION=1.2.1

RUN apk add --update \
	    build-base \
	    ca-certificates \
	    curl \
	    gcc \
	    libc-dev \
	    libgcc \
	    linux-headers \
	    make \
	    musl-dev \
	    openssl \
	    openssl-dev \
	    pcre \
	    pcre-dev \
	    pkgconf \
	    pkgconfig \
	    zlib-dev

RUN cd /tmp && \
    wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
    tar zxf nginx-${NGINX_VERSION}.tar.gz && \
    rm nginx-${NGINX_VERSION}.tar.gz

RUN cd /tmp && \
    wget https://github.com/arut/nginx-rtmp-module/archive/v${NGINX_RTMP_VERSION}.tar.gz && \
    tar zxf v${NGINX_RTMP_VERSION}.tar.gz && rm v${NGINX_RTMP_VERSION}.tar.gz && \
    mv /tmp/nginx-rtmp-module-${NGINX_RTMP_VERSION} /tmp/nginx-rtmp-module

RUN cd /tmp/nginx-${NGINX_VERSION} && \
    ./configure \
    --prefix=/opt/nginx \
    --add-module=/tmp/nginx-rtmp-module \
    --with-threads \
    --with-file-aio \
    --with-http_ssl_module \
    --with-debug \
    --with-http_stub_status_module \
    --with-cc-opt="-Wimplicit-fallthrough=0" && \
    cd /tmp/nginx-${NGINX_VERSION} && \
    make && make install

FROM alpine:latest
RUN apk update && \
    apk add \
            openssl \
            libstdc++ \
            ca-certificates \
            pcre

COPY --from=0 /opt/nginx /opt/nginx
COPY --from=0 /tmp/nginx-rtmp-module/stat.xsl /opt/nginx/conf/stat.xsl
COPY nginx.conf /opt/nginx/conf/nginx.conf
COPY --chown=nobody:nobody player /var/www/player/

EXPOSE 1935
EXPOSE 8080

CMD /opt/nginx/sbin/nginx

