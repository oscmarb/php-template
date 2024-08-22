FROM php:8.2-alpine3.20

RUN mkdir /app
WORKDIR /app

RUN apk add --no-cache autoconf g++ make linux-headers \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer
