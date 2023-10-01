# Use the official PHP 8.1-fpm image as the base image
FROM php:8.1-fpm

LABEL maintainer="TienHM"

# Copy composer.lock and composer.json
COPY ./src/composer.lock /var/www/html/
COPY ./src/composer.json /var/www/html/

# Set working directory
WORKDIR /var/www/html

# Set ENV
ENV PHP_OPCACHE_VALIDATE_TIMESTAMPS="0" \
    PHP_OPCACHE_MAX_ACCELERATED_FILES="50000" \
    PHP_OPCACHE_MEMORY_CONSUMPTION="256" \
    PHP_OPCACHE_MAX_WASTED_PERCENTAGE="10"

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libpq-dev \
    g++ \
    libicu-dev \
    libxml2-dev \
    libzip-dev \
    libonig-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl \
    memcached \
    autoconf \
    pkg-config \
    libssl-dev

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install extensions
RUN docker-php-ext-install mysqli pgsql pdo pdo_pgsql pdo_mysql mbstring zip exif bcmath soap
RUN docker-php-ext-configure intl
RUN docker-php-ext-install intl

# Install OpCache
RUN docker-php-ext-install opcache
COPY ./docker/php/opcache.ini /usr/local/etc/php/conf.d/opcache.ini
COPY ./docker/php/opcache-default.blacklist /usr/local/etc/php/conf.d/opcache-default.blacklist

# Install GD
RUN docker-php-ext-configure gd --with-jpeg=/usr/include/ --with-freetype=/usr/include/
RUN docker-php-ext-install gd

# Install mcrypt
RUN apt-get update && apt-get install -y \
        libmcrypt-dev
RUN pecl install mcrypt \
    && docker-php-ext-enable mcrypt

# Install apcu
RUN pecl install apcu \
    && docker-php-ext-enable apcu

# Install Imagemagick & PHP Imagick ext
RUN apt-get update && apt-get install -y \
        libmagickwand-dev --no-install-recommends

RUN pecl install imagick && docker-php-ext-enable imagick

# Install swoole ext
#RUN pecl install swoole \
#    && docker-php-ext-enable swoole

# Install mongodb ext
RUN pecl install mongodb \
    && docker-php-ext-enable mongodb

# Install xdebug
RUN pecl install xdebug && docker-php-ext-enable xdebug

# remove not necessary files
RUN rm -rf /var/lib/apt/lists/*

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Supervisor
RUN apt-get update && apt-get install -y supervisor && rm -rf /var/lib/apt/lists/*

# Copy your custom Supervisor configuration
COPY ./docker/supervisor/laravel-scheduler.conf /etc/supervisor/conf.d/laravel-scheduler.conf
COPY ./docker/supervisor/laravel-worker.conf /etc/supervisor/conf.d/laravel-worker.conf

# Add user for laravel application
RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

# Copy existing application directory contents
COPY . /var/www/html

# Permission
RUN chown www:www /var/www/html
RUN chown www:www /tmp

RUN chmod 777 -R ./docker/data
# Change current user to www
USER www

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]
