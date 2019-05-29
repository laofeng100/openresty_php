FROM alpine:3.9

MAINTAINER gongyishu development "gongyishu@le.com"

USER root
WORKDIR /
#ENV APP_NAME anp
#ENV APP_PATH /var/www/html
#ENV APP_PATH_INDEX /var/www/html
#ENV APP_PATH_404 /var/www/html
#ENV APP_INIT_SHELL ""
#ENV APP_MONITOR_HOOK DINGTALK-HOOK

ENV PHP_MEM_LIMIT 512M
ENV PHP_POST_MAX_SIZE 100M
ENV PHP_UPLOAD_MAX_FILESIZE 100M

ENV FPM_MAX_CHILDREN 200
ENV FPM_START_SERVERS 10
ENV FPM_MIN_SPARE_SERVERS 8
ENV FPM_MAX_SPARE_SERVERS 15
ENV FPM_MAX_REQUESTS 200
ENV FPM_SLOWLOG /var/log/fpm-slow.log
ENV FPM_SLOWLOG_TIMEOUT 2

#nginx默认
#ENV NGINX_PHP_CONF default

#是否开启opache功能
ENV ENABLE_OPCACHE "1"

ENV php_etc /etc/php7
ENV php_ini /etc/php7/php.ini
ENV php_conf_d /etc/php7/conf.d
ENV php_conf /etc/php7/php-fpm.conf
ENV fpm_conf /etc/php7/php-fpm.d/www.conf


COPY soft/grpc-1.19.0.tgz /grpc-1.19.0.tgz
COPY soft/protobuf-3.7.0.tgz /protobuf-3.7.0.tgz
COPY soft/yaf-3.0.8.tgz /yaf-3.0.8.tgz
COPY soft/scws-1.2.3.tar.bz2 /scws-1.2.3.tar.bz2
COPY soft/ngx_http_qrcode_module.tar.gz /ngx_http_qrcode_module.tar.gz
COPY soft/pecl-memcache-NON_BLOCKING_IO_php7.tar.gz /pecl-memcache-NON_BLOCKING_IO_php7.tar.gz

#Docker Build openresty config
ARG RESTY_VERSION="1.15.8.1"
ARG RESTY_OPENSSL_VERSION="1.0.2r"
ARG RESTY_PCRE_VERSION="8.42"
ARG RESTY_J="1"

ARG RESTY_CONFIG_OPTIONS="\
    --with-file-aio \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_realip_module \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_v2_module \
    --with-ipv6 \
    --with-md5-asm \
    --with-pcre-jit \
    --with-sha1-asm \
    --with-threads \
    --add-module=/tmp/ngx_http_qrcode_module \
    "
ARG RESTY_CONFIG_OPTIONS_MORE=""
ARG RESTY_ADD_PACKAGE_BUILDDEPS=""
ARG RESTY_ADD_PACKAGE_RUNDEPS=""
ARG RESTY_EVAL_PRE_CONFIGURE=""
ARG RESTY_EVAL_POST_MAKE=""

LABEL resty_version="${RESTY_VERSION}"
LABEL resty_openssl_version="${RESTY_OPENSSL_VERSION}"
LABEL resty_pcre_version="${RESTY_PCRE_VERSION}"
LABEL resty_config_options="${RESTY_CONFIG_OPTIONS}"
LABEL resty_config_options_more="${RESTY_CONFIG_OPTIONS_MORE}"
LABEL resty_add_package_builddeps="${RESTY_ADD_PACKAGE_BUILDDEPS}"
LABEL resty_add_package_rundeps="${RESTY_ADD_PACKAGE_RUNDEPS}"
LABEL resty_eval_pre_configure="${RESTY_EVAL_PRE_CONFIGURE}"
LABEL resty_eval_post_make="${RESTY_EVAL_POST_MAKE}"

# These are not intended to be user-specified
ARG _RESTY_CONFIG_DEPS="--with-openssl=/tmp/openssl-${RESTY_OPENSSL_VERSION} --with-pcre=/tmp/pcre-${RESTY_PCRE_VERSION}"
RUN echo "https://mirrors.aliyun.com/alpine/v3.8/main/" > /etc/apk/repositories  \
    && echo "https://mirrors.aliyun.com/alpine/v3.8/community/" >> /etc/apk/repositories \
    && apk update  \
    && apk add --no-cache --virtual .build-deps \
        build-base \
        libxslt-dev \
        linux-headers \
        make \
        autoconf \
        automake \
        make \
        cmake \
        gcc \
        g++ \
        tzdata \
        ca-certificates \
        perl-dev \
        gd-dev \
        curl \
        libqrencode-dev \
        readline-dev \
        zlib-dev \
        zlib \
        ${RESTY_ADD_PACKAGE_BUILDDEPS} \
    && apk add --no-cache \
        libgcc \
        libxslt \
        gd \
        zlib \
        librdkafka-dev \
        libqrencode-dev \
        bash\
        php7 \
        php7-mbstring \
        php7-exif \
        php7-ftp \
        php7-intl \
        php7-session \
        php7-fpm \
        php7-xml \
        php7-soap \
        php7-sodium \
        php7-xsl \
        php7-zlib \
        php7-json \
        php7-phar \
        php7-gd \
        php7-iconv \
        php7-openssl \
        php7-dom \
        php7-pdo \
        php7-curl \
        php7-xmlwriter  \
        php7-xmlreader \
        php7-ctype \
        php7-simplexml \
        php7-zip \
        php7-posix \
        php7-dev \
        php7-pear \
        php7-tokenizer \
        php7-bcmath \
        php7-mongodb \
        php7-apcu \
        php7-fileinfo \
        php7-gmp \
        php7-redis \
        php7-opcache \
        php7-amqp \
        php7-ldap \
        php7-memcached\
        php7-pdo_mysql \
        php7-pdo_pgsql \
        ${RESTY_ADD_PACKAGE_RUNDEPS}  \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime  \
    && echo 'Asia/Shanghai' >/etc/timezone  \
    && echo "config opcache"  \
    && echo 'opcache.validate_timestamps=0' >> ${php_conf_d}/00_opcache.ini   \
    && echo 'opcache.enable=1' >> ${php_conf_d}/00_opcache.ini   \
    && echo 'opcache.enable_cli=1' >> ${php_conf_d}/00_opcache.ini   \
    && echo "config apcu"   \
    && echo 'apc.enabled=1' >> ${php_conf_d}/apcu.ini   \
    && echo 'apc.shm_size=32M' >> ${php_conf_d}/apcu.ini   \
    && echo 'apc.enable_cli=1' >> ${php_conf_d}/apcu.ini   \
    && apk add --no-cache --repository https://mirrors.aliyun.com/alpine/edge/community gnu-libiconv  \
    #=============== pecl install swoole ====================#
    && pecl install swoole-4.3.4  \
    && echo 'extension=swoole.so' >> ${php_conf_d}/swoole.ini  \
    #=============== pecl install rdkafka ====================#
    && pecl install rdkafka-3.1.0 \
    && echo 'extension=rdkafka.so' >> ${php_conf_d}/rdkafka.ini  \
    #=============== pecl install igbinary =====================#
    && pecl install  igbinary-3.0.1 \
    && echo 'extension=igbinary.so' >> ${php_conf_d}/igbinary.ini \
    #=============== pecl install grpc ====================#
    && pecl install ./grpc-1.19.0.tgz  \
    && echo 'extension=grpc.so' >> ${php_conf_d}/grpc.ini  \
    #=============== pecl install protobuf ====================#
    && pecl install ./protobuf-3.7.0.tgz  \
    && echo 'extension=protobuf.so' >> ${php_conf_d}/protobuf.ini  \
    #=============== pecl install yaf ====================#
    && pecl install ./yaf-3.0.8.tgz  \
    && echo "config yaf"   \
    && echo '[yaf]' >> ${php_conf_d}/yaf.ini   \
    && echo 'extension=yaf.so' >> ${php_conf_d}/yaf.ini   \
    && echo 'yaf.cache_config=1' >> ${php_conf_d}/yaf.ini   \
    && echo 'yaf.use_namespace=1' >> ${php_conf_d}/yaf.ini   \
    && echo 'yaf.use_spl_autoload=1' >> ${php_conf_d}/yaf.ini   \
    #===================install scws========================#
    && tar xvf ./scws-1.2.3.tar.bz2 \
    && cd /scws-1.2.3 \
    && ./configure --prefix=/usr/local/scws \
    && make \
    && make install \
    && ls -al /usr/local/scws/lib/libscws.la \
    && /usr/local/scws/bin/scws -h \
    && cd ./phpext \
    && /usr/bin/phpize \
    && ./configure --with-php-config=/usr/bin/php-config \
    && make \
    && make install \
    && echo 'extension=scws.so' >> ${php_conf_d}/scws.ini  \
    && cd / \
    #===================install memcache========================#
    && tar zxvf ./pecl-memcache-NON_BLOCKING_IO_php7.tar.gz \
    && cd /pecl-memcache-NON_BLOCKING_IO_php7 \
    && /usr/bin/phpize \
    && ./configure --with-php-config=/usr/bin/php-config \
    && make \
    && make install \
    && echo 'extension=memcache.so' >> ${php_conf_d}/memcache.ini  \
    && cd / \
    && tar zxf ./ngx_http_qrcode_module.tar.gz \
    && mv ngx_http_qrcode_module/ /tmp/ \
    #=================== delete install package ====================#
    && rm -rf /scws-1.2.3 /pecl-memcache-NON_BLOCKING_IO_php7 ./scws-1.2.3.tar.bz2 ./pecl-memcache-NON_BLOCKING_IO_php7.tar.gz \
    && rm -rf ./ngx_http_qrcode_module.tar.gz ./grpc-1.19.0.tgz ./protobuf-3.7.0.tgz ./yaf-3.0.8.tgz  \
    #===================install openresty ====================#
    && cd /tmp \
    && if [ -n "${RESTY_EVAL_PRE_CONFIGURE}" ]; then eval $(echo ${RESTY_EVAL_PRE_CONFIGURE}); fi \
    && curl -fSL https://www.openssl.org/source/openssl-${RESTY_OPENSSL_VERSION}.tar.gz -o openssl-${RESTY_OPENSSL_VERSION}.tar.gz \
    && tar xzf openssl-${RESTY_OPENSSL_VERSION}.tar.gz \
    && curl -fSL https://ftp.pcre.org/pub/pcre/pcre-${RESTY_PCRE_VERSION}.tar.gz -o pcre-${RESTY_PCRE_VERSION}.tar.gz \
    && tar xzf pcre-${RESTY_PCRE_VERSION}.tar.gz \
    && curl -fSL https://openresty.org/download/openresty-${RESTY_VERSION}.tar.gz -o openresty-${RESTY_VERSION}.tar.gz \
    && tar xzf openresty-${RESTY_VERSION}.tar.gz \
    && cd /tmp/openresty-${RESTY_VERSION} \
    && ./configure -j${RESTY_J} ${_RESTY_CONFIG_DEPS} ${RESTY_CONFIG_OPTIONS} ${RESTY_CONFIG_OPTIONS_MORE} \
    && make -j${RESTY_J} \
    && make -j${RESTY_J} install \
    && cd /tmp \
    && if [ -n "${RESTY_EVAL_POST_MAKE}" ]; then eval $(echo ${RESTY_EVAL_POST_MAKE}); fi \
    && rm -rf \
        openssl-${RESTY_OPENSSL_VERSION} \
        openssl-${RESTY_OPENSSL_VERSION}.tar.gz \
        openresty-${RESTY_VERSION}.tar.gz openresty-${RESTY_VERSION} \
        pcre-${RESTY_PCRE_VERSION}.tar.gz pcre-${RESTY_PCRE_VERSION} \
    && apk del .build-deps
#    && ln -sf /dev/stdout /usr/local/openresty/nginx/logs/access.log \
#    && ln -sf /dev/stderr /usr/local/openresty/nginx/logs/error.log
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php
ENV PATH=$PATH:/usr/local/openresty/luajit/bin:/usr/local/openresty/nginx/sbin:/usr/local/openresty/bin

COPY ./run.sh /run.sh
COPY --from=ochinchina/supervisord:latest /usr/local/bin/supervisord /usr/local/bin/supervisord
COPY ./supervisor.conf /supervisor.conf
WORKDIR /letv/www
EXPOSE 80
STOPSIGNAL SIGTERM
ENTRYPOINT ["/bin/bash"]
CMD ["/run.sh"]