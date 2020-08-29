ARG PHP_VERSION
FROM ${PHP_VERSION}
LABEL maintainer="pingstrong@163.com"
ARG TZ

#update restorigy
RUN apt update

RUN cp "/usr/share/zoneinfo/$TZ" /etc/localtime \
    && echo "$TZ" > /etc/timezone

# Install dev dependencies
RUN apt install -y gcc make g++ git imagemagick libc6-dev nodejs libnode64 npm autoconf \
  libpcre3 libpcre3-dev openssl libssl-dev openssl libssl-dev libperl-dev zlib1g-dev  gcc libzip-dev \
  libcurl4-gnutls-dev libbz2-dev libjpeg-dev libpng-dev libxpm-dev libfreetype6-dev libgmp-dev libevent-dev \
  libmcrypt-dev  libxslt1-dev libxml2 libxml2-dev libgtk2.0-dev curl wget vim
 
RUN ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h
#manual make install extensions,for example mongodb,swoole
COPY ./extensions /tmp/extensions
WORKDIR /tmp/extensions
RUN chmod +x install.sh \
    && bash install.sh \
    && rm -rf /tmp/extensions

# Install PECL and PEAR extensions
 

# Configure php extensions
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-configure zip --with-libzip

# Install php extensions
RUN docker-php-ext-install \
    bcmath \
    calendar \
    curl \
    exif \
    gd \
    gettext \
    shmop \
    sysvmsg \
    iconv \
    mbstring \
    pdo \
    pdo_mysql \
    pcntl \
    tokenizer \
    xml \
    zip \
    soap \
    xmlrpc \
    gmp \
    mysqli \
    sockets
   # mysql \

# Install composer
ENV COMPOSER_HOME /tmp/composer
#ENV PATH ./vendor/bin:/composer/vendor/bin:$PATH
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_MEMORY_LIMIT -1
#RUN curl -s https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer
RUN curl -L -o /usr/bin/composer https://mirrors.aliyun.com/composer/composer.phar \
    && chmod +x /usr/bin/composer

# Install PHP_CodeSniffer
#RUN composer global require "squizlabs/php_codesniffer=*"

# php image's www-data user uid & gid are 82, change them to 1000 (primary user)
#RUN apk --no-cache add shadow && usermod -u 1000 www-data && groupmod -g 1000 www-data

# Setup working directory
WORKDIR /www