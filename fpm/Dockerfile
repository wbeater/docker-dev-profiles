FROM php:8.2.5-fpm-alpine

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

# RUN apk update
# Pull in nproc:
# RUN apk add --no-cache coreutils

# Required for bandwidth graphs:
# RUN apk add --no-cache net-snmp-tools

# Install the linux-headers package:
# RUN apk add --update linux-headers

RUN apk add \
    # --no-cache \
    --virtual .build-deps $PHPIZE_DEPS \
    # && pecl install uploadprogress \
    # && docker-php-ext-enable uploadprogress \
    && apk del .build-deps $PHPIZE_DEPS \
    && chmod uga+x /usr/local/bin/install-php-extensions && sync \
    && install-php-extensions bcmath \
            bz2 \
            calendar \
            curl \
            exif \
            fileinfo \
            ftp \
            gd \
            gettext \
            imagick \
            imap \
            intl \
            # ldap \
            mbstring \
            mcrypt \
            memcached \
            mongodb \
            mysqli \
            opcache \
            openssl \
            pdo \
            pdo_mysql \
            redis \
            soap \
            sodium \
            # sysvsem \
            # sysvshm \
            # xmlrpc \
            xsl \
            zip \
    &&  echo -e "\n opcache.enable=1 \n opcache.enable_cli=1 \n opcache.memory_consumption=128 \n opcache.interned_strings_buffer=8 \n opcache.max_accelerated_files=4000 \n opcache.revalidate_freq=60 \n opcache.fast_shutdown=1" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
    &&  echo -e "\n xhprof.output_dir='/var/tmp/xhprof'" >> /usr/local/etc/php/conf.d/docker-php-ext-xhprof.ini \
    && cd ~ \
# Install composer
    && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php -r "copy('https://composer.github.io/installer.sig', 'signature');" \
    && php -r "if (hash_file('SHA384', 'composer-setup.php') === trim(file_get_contents('signature'))) { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && php -r "unlink('composer-setup.php');" \
# Install WP-CLI
    && curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp \
# Install msmtp - To Send Mails on Production & Development
    && apk add msmtp
# modify www-data user to have id 1000
RUN apk add \
        # --no-cache \
        --repository http://dl-3.alpinelinux.org/alpine/edge/community/ --allow-untrusted \
        --virtual .shadow-deps \
        shadow \
    && usermod -u 1000 www-data \
    && groupmod -g 1000 www-data \
    && apk del .shadow-deps

# Add xdebug
RUN apk add --virtual .build-deps $PHPIZE_DEPS
RUN apk add --update linux-headers
RUN pecl install xdebug-3.2.1
RUN docker-php-ext-enable xdebug
RUN apk del -f .build-deps

# Configure Xdebug
RUN echo "xdebug.start_with_request=trigger" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.mode=profile" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.output_dir=/var/log/xdebug" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.log=/var/log/xdebug/xdebug.log" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.discover_client_host=1" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.client_port=9003" >> /usr/local/etc/php/conf.d/xdebug.ini

RUN mkdir -p /var/log/xdebug
RUN chmod 0777 /var/log/xdebug
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

ENV PHP_MEMORY_LIMIT=1G
ENV PHP_UPLOAD_MAX_FILESIZE=512M
ENV PHP_POST_MAX_SIZE=512M


# Install Nodejs
# RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - \
#     && apt-get install -y nodejs \
#     && npm install -g yarn

# Setting locales
# RUN echo vi_VN.UTF-8 UTF-8 > /etc/locale.gen && locale-gen

# ENV PHP_INI_DIR /usr/local/etc/php
RUN cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" 

# Changing Workdir
WORKDIR /app

# RUN usermod -u 1000 www-data
# makes directory /var/www owned by www-data(default user for php-fpm)
RUN chown -R www-data:www-data /app



