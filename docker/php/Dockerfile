FROM php:8.3-fpm

# UID/GID 1000 matches the default WSL2 Ubuntu user in this learning environment.
ARG UID=1000
ARG GID=1000

# Install PHP extensions commonly used by Laravel 11 applications.
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        git \
        unzip \
        libicu-dev \
        libonig-dev \
        libzip-dev \
        default-mysql-client; \
    docker-php-ext-install -j"$(nproc)" \
        pdo_mysql \
        mbstring \
        bcmath \
        intl \
        zip \
        exif \
        pcntl \
        opcache; \
    pecl install redis; \
    docker-php-ext-enable redis; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/pear

# Composer is included in the shared PHP image so composer/artisan/php-cli use the same PHP runtime.
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Local PHP settings for Laravel development.
COPY docker/php/php.ini /usr/local/etc/php/conf.d/99-learning.ini

# Create a non-root user so generated files are owned by UID/GID 1000 on WSL/Windows.
RUN set -eux; \
    if ! getent group "${GID}" >/dev/null; then \
        groupadd --gid "${GID}" laravel; \
    fi; \
    useradd --uid "${UID}" --gid "${GID}" --create-home --shell /bin/bash laravel; \
    mkdir -p /var/www/html /home/laravel/.composer; \
    chown -R "${UID}:${GID}" /var/www/html /home/laravel

ENV COMPOSER_HOME=/home/laravel/.composer
ENV PATH="${COMPOSER_HOME}/vendor/bin:${PATH}"

WORKDIR /var/www/html

USER laravel

EXPOSE 9000

CMD ["php-fpm"]
