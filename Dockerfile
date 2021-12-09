FROM php:5.6-apache
LABEL Name=uplott3 Version=0.0.1
WORKDIR /var/www/html
COPY ./conf/docker-php.conf /etc/apache2/conf-available/docker-php.conf
COPY ./conf/sources.list /etc/apt/sources.list
COPY ./conf/php.ini /usr/local/etc/php/php.ini
COPY ./conf/fjfc_ecms_dev.conf /etc/apache2/sites-available/fjfc_ecms_dev.conf
RUN apt-get update \
    && apt-get install libmcrypt-dev libfreetype6-dev libjpeg62-turbo-dev libpng-dev -y \
    && curl -fsSL 'https://hub.fastgit.org/phpredis/phpredis/archive/refs/tags/2.2.8.tar.gz' -o php_redis.tar.gz \
    && mkdir -p redis \
    && tar -xf php_redis.tar.gz -C redis --strip-components=1 \
    && rm php_redis.tar.gz \
    && ( \
        cd redis \
        && phpize \
        && ./configure \
        && make -j "$(nproc)" \
        && make install \
    ) \
    && rm -r redis \
    && docker-php-ext-enable redis \
    && docker-php-source extract \
    && docker-php-ext-configure mysqli \
    && docker-php-ext-install mysqli \
    # && docker-php-ext-enable mysqli \
    && docker-php-ext-configure sockets \
    && docker-php-ext-install sockets \
    # && docker-php-ext-enable sockets \
    && docker-php-ext-configure mcrypt \
    && docker-php-ext-install mcrypt \
    # && docker-php-ext-enable mcrypt \
    # && docker-php-ext-configure zip \
    # && docker-php-ext-install zip \
    # && docker-php-ext-enable zip \
    && docker-php-ext-configure mcrypt \
    && docker-php-ext-install mcrypt \
    # && docker-php-ext-enable mcrypt \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    # && docker-php-ext-enable gd \
    && docker-php-source delete \
    # && cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini \
    && a2ensite fjfc_ecms_dev \
    && a2enmod rewrite headers expires \