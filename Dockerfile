FROM php:8.3

RUN apt-get update \
    && apt-get install -y gdb unzip valgrind git \
    && docker-php-ext-install -j$(nproc) sockets \
    && curl -LOs https://github.com/DataDog/dd-trace-php/releases/download/0.95.0/datadog-setup.php  \
    && php datadog-setup.php --php-bin=all  \
    && rm datadog-setup.php \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer

ENV DD_TRACE_CLI_ENABLED=1

WORKDIR /root

COPY composer.json composer.lock .
COPY src src
COPY .gdbinit .gdbinit

RUN COMPOSER_ALLOW_SUPERUSER=1 composer install

ENV XDEBUG_MODE=develop
ENV ZEND_DONT_UNLOAD_MODULES=1
ENV USE_ZEND_ALLOC=0

RUN git clone https://github.com/derickr/xdebug.git && cd xdebug && git checkout issue2232-zend-user-code && phpize && ./configure && make && make install \
    && docker-php-ext-enable xdebug

CMD ["valgrind", "php", "-ddatadog.instrumentation_telemetry_enabled=0", "src/entry"]
