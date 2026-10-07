# Expense Tracker: PHP 8.3 + Apache (mod_php) with the pdo_mysql extension.
FROM php:8.3-apache

RUN docker-php-ext-install pdo_mysql \
    && a2enmod headers \
    && a2dissite 000-default

# Reuse the project's own vhost (DocumentRoot /var/www/expense-tracker).
COPY deploy/expense-tracker.conf /etc/apache2/sites-available/expense-tracker.conf
RUN a2ensite expense-tracker \
    # The vhost writes to custom log names; send them to the container logs.
    && ln -sf /dev/stdout /var/log/apache2/expense-tracker-access.log \
    && ln -sf /dev/stderr /var/log/apache2/expense-tracker-error.log

COPY . /var/www/expense-tracker

EXPOSE 80

# Reports unhealthy if Apache, PHP or the database connection is broken.
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
    CMD php -r 'exit(@file_get_contents("http://127.0.0.1/health.php") === false ? 1 : 0);'
