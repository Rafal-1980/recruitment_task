# Use PHP 8.1 CLI as base image
FROM php:8.1-cli

# Install necessary extensions and tools
RUN apt-get update && apt-get install -y \
    unzip \
    curl \
    git \
    libpq-dev \
    && docker-php-ext-install pdo pdo_pgsql sockets

# Set working directory
WORKDIR /app

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set production environment
ENV APP_ENV=prod
ENV APP_DEBUG=0

# Copy application files
COPY . .

# Install dependencies and clear cache for production
RUN composer install --no-dev --optimize-autoloader \
    && php bin/console cache:clear --env=prod \
    && php bin/console cache:warmup --env=prod

# Download and set up RoadRunner
RUN curl -L https://github.com/roadrunner-server/roadrunner/releases/download/v2023.3.8/roadrunner-2023.3.8-linux-amd64.tar.gz -o rr.tar.gz \
    && tar -xzf rr.tar.gz \
    && mv roadrunner-2023.3.8-linux-amd64/rr /usr/local/bin/rr \
    && chmod +x /usr/local/bin/rr \
    && rm -rf roadrunner-* rr.tar.gz

# Expose application port
EXPOSE 8080

# Starting RoadRunner
CMD ["/usr/local/bin/rr", "serve"]
