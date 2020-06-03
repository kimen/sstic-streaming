FROM alpine:latest as nginx_builder

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
    tar zxf nginx-${NGINX_VERSION}.tar.gz && rm nginx-${NGINX_VERSION}.tar.gz && \
    mv /tmp/nginx-${NGINX_VERSION} /tmp/nginx

RUN cd /tmp && \
    wget https://github.com/arut/nginx-rtmp-module/archive/v${NGINX_RTMP_VERSION}.tar.gz && \
    tar zxf v${NGINX_RTMP_VERSION}.tar.gz && rm v${NGINX_RTMP_VERSION}.tar.gz && \
    mv /tmp/nginx-rtmp-module-${NGINX_RTMP_VERSION} /tmp/nginx-rtmp-module

RUN cd /tmp/nginx && \
    ./configure \
    --prefix=/opt/nginx \
    --add-module=/tmp/nginx-rtmp-module \
    --with-threads \
    --with-file-aio \
    --with-http_ssl_module \
    --with-debug \
    --with-http_stub_status_module \
    --with-cc-opt="-Wimplicit-fallthrough=0" && \
    make && make install


FROM alpine:latest as player_builder

RUN apk add --update \
            ca-certificates \
	    wget

# Fetching the player from sstic's gitlab
RUN wget -O player.tgz https://gitlab.com/sstic/streaming-infra/-/archive/master/streaming-infra-master.tar.gz?path=player && \
    tar xvzf player.tgz && mv streaming-infra-master-player/player /player


FROM alpine:latest

RUN apk add --update \
            openssl \
            libstdc++ \
            ca-certificates \
            pcre

# Getting nginx from the build container
COPY --from=nginx_builder /opt/nginx /opt/nginx
# Getting the player from the build container
COPY --from=player_builder --chown=nobody:nobody /player /var/www/player/
# Copying the nginx configuration from the local repo
COPY nginx.conf /opt/nginx/conf/nginx.conf

# Preparing the hls directory
RUN mkdir /var/www/hls
VOLUME /var/www/hls

EXPOSE 1935
EXPOSE 8080

CMD /opt/nginx/sbin/nginx

