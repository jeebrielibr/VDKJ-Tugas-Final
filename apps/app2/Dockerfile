FROM php:8.3-apache

RUN groupadd -r appuser && useradd -r -g appuser -s /sbin/nologin appuser

RUN docker-php-ext-install mysqli

COPY . /var/www/html/

RUN chown -R appuser:appuser /var/www/html

USER appuser

EXPOSE 80
