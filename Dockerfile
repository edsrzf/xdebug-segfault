FROM php:8.3

RUN apt-get update \
    && apt-get install -y gdb unzip \
    && docker-php-ext-install -j$(nproc) sockets \
    && curl -LOs https://github.com/DataDog/dd-trace-php/releases/download/0.95.0/datadog-setup.php  \
    && php datadog-setup.php --php-bin=all  \
    && rm datadog-setup.php \
    && pecl install xdebug-3.3.1 \
    && docker-php-ext-enable xdebug \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer

ENV DD_TRACE_CLI_ENABLED=1

WORKDIR /root

COPY composer.json composer.lock .
COPY src src

RUN COMPOSER_ALLOW_SUPERUSER=1 composer install

CMD ["php", "src/entry"]
