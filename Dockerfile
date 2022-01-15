FROM debian:bullseye AS cli

ENV TERM=linux

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update \
    && apt -y upgrade \
    && apt-get install -y --no-install-recommends gnupg \
    && apt-get -y --no-install-recommends install \
        ca-certificates \
        bash \
        net-tools \
        curl \
        unzip \
        git \
        wget \
        curl \
        mc \
        php7.4-apcu \
        php7.4-apcu-bc \
        php7.4-cli \
        php7.4-curl \
        php7.4-json \
        php7.4-mbstring \
        php7.4-opcache \
        php7.4-readline \
        php7.4-xml \
        php7.4-zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* \
    && mkdir -p /usr/src/website \
    && cd /usr/src/website \
    && git clone https://github.com/calliotel/ips.git

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

CMD ["php", "-a"]

FROM cli AS fpm

RUN apt-get update \
    && apt-get -y --no-install-recommends install php7.4-fpm \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

STOPSIGNAL SIGQUIT

COPY overrides.conf /etc/php/7.4/fpm/pool.d/z-overrides.conf

CMD ["/usr/sbin/php-fpm7.4", "-O" ]

EXPOSE 9000

FROM cli AS swoole

RUN apt update \
    && apt clean \
    && apt autoclean \
    && apt autoremove \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*
