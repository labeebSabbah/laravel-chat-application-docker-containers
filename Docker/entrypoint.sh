#!/bin/bash

if [ ! -f "vendor/autoload.php" ]; then
    composer install --no-interaction --no-progress
fi

if [ ! -f ".env" ]; then
    echo "Creating ENV file for $_APP_ENV"
    cp .env.example .env
fi

role=${CONTAINER_ROLE:-app}

if [ "$role" = "app" ]; then

    php artisan key:generate
    php artisan migrate
    php artisan cache:clear
    php artisan config:clear
    php artisan route:clear
    php artisan view:clear

    php artisan serve --port=$PORT --host=0.0.0.0 --env=.env
    exec docker-php-entrypoint "$@"

elif [ "$role" = "queue" ]; then

    echo "Running the queue..."
    php /var/www/artisan queue:work --verbose --tries=3 --timeout=90

elif [ "$role" = "websocket" ]; then

    echo "Running the websocket..."
    php /var/www/artisan websockets:serve

fi
