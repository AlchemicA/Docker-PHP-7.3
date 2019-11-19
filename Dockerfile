FROM php:7.3-fpm-alpine

ADD bin/* /usr/local/bin/

ENV PHP_INI_DIR /usr/local/etc/php

RUN set -ex \
	&& ( \
		docker-php-ext-install pdo_mysql \
	) \
	&& ( \
		apk add \
			--update \
			--no-cache \
			icu-dev \
		&& docker-php-ext-configure intl --enable-intl \
		&& docker-php-ext-install intl \
	) \
	&& ( \
		apk add \
			--no-cache \
			curl \
			curl-dev \
		&& docker-php-ext-configure curl --enable-curl \
		&& docker-php-ext-install curl \
	) \
	&& ( \
		apk add \
			--no-cache \
			freetype \
			libpng \
			libjpeg-turbo \
			freetype-dev \
			libpng-dev \
			libjpeg-turbo-dev \
		&& docker-php-ext-configure gd \
			--with-gd \
			--with-freetype-dir=/usr/include/ \
			--with-png-dir=/usr/include/ \
			--with-jpeg-dir=/usr/include/ \
		&& docker-php-ext-install gd \
	) \
	&& ( \
		apk add \
			--no-cache \
			libxslt \
			libxslt-dev \
		&& docker-php-ext-configure xsl --enable-xsl \
		&& docker-php-ext-install xsl \
	) \
	&& ( \
		apk add \
			--no-cache \
			libzip-dev \
		&& docker-php-ext-configure zip --with-libzip=/usr/include --enable-zip \
		&& docker-php-ext-install zip \
	) \
	&& ( \
		docker-php-ext-configure simplexml --enable-simplexml \
		&& docker-php-ext-install simplexml \
	) \
	&& ( \
		docker-php-ext-configure soap --enable-soap \
		&& docker-php-ext-install soap \
	) \
	&& ( \
		php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
		&& php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
		&& php -r "unlink('composer-setup.php');" \
		# && apk add \
		# 	--no-cache \
		# 	curl \
		# && curl -sSL https://phar.phpunit.de/phpunit.phar -o phpunit.phar \
		# && chmod +x phpunit.phar \
		# && mv phpunit.phar /usr/local/bin/phpunit \
		# && curl -sSL https://files.magerun.net/n98-magerun.phar -o n98-magerun.phar \
		# && chmod +x n98-magerun.phar \
		# && mv n98-magerun.phar /usr/local/bin/n98-magerun \
	) \
	&& ( \
		apk add \
			--no-cache \
			g++ \
			make \
			autoconf \
		&& pecl install xdebug \
		&& docker-php-ext-enable xdebug \
		&& docker-php-source delete \
		&& echo "xdebug.remote_enable=on" >> "$PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini" \
		&& echo "xdebug.remote_autostart=off" >> "$PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini" \
		&& echo "xdebug.remote_port=9090" >> "$PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini" \
		&& echo "xdebug.remote_handler=dbgp" >> "$PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini" \
		&& echo "xdebug.remote_connect_back=0" >> "$PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini" \
	)

ENTRYPOINT ["/usr/local/bin/docker-environment"]
