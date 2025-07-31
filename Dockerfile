FROM php:8.3-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    curl \
    git \
    nano \
    libzip-dev \
    && docker-php-ext-install \
        pdo_mysql \
        mbstring \
        exif \
        pcntl \
        bcmath \
        gd \
        intl \
        zip



# Install Redis extension
RUN pecl install redis \
&& docker-php-ext-enable redis

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy existing application
COPY . .
RUN cp .env.example .env
# Install PHP dependencies
RUN composer install --no-dev
#RUN composer install --no-dev --no-scripts
# Set permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage
# Ensure correct ownership
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Set correct permissions
RUN chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache
# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]
