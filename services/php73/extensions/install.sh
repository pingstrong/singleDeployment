#!/bin/sh

export MC="-j$(nproc)"

echo
echo "============================================"
echo "Install extensions from   : install.sh"
echo "PHP version               : ${PHP_VERSION}"
echo "Extra Extensions          : ${PHP_EXTENSIONS}"
echo "Multicore Compilation     : ${MC}"
echo "Container package url     : ${CONTAINER_PACKAGE_URL}"
echo "Work directory            : ${PWD}"
echo "============================================"
echo


export EXTENSIONS=",${PHP_EXTENSIONS},"


#
# Check if current php version is greater than or equal to
# specific version.
#
# For example, to check if current php is greater than or
# equal to PHP 7.0:
#
# isPhpVersionGreaterOrEqual 7 0
#
# Param 1: Specific PHP Major version
# Param 2: Specific PHP Minor version
# Return : 1 if greater than or equal to, 0 if less than
#
isPhpVersionGreaterOrEqual()
 {
    local PHP_MAJOR_VERSION=$(php -r "echo PHP_MAJOR_VERSION;")
    local PHP_MINOR_VERSION=$(php -r "echo PHP_MINOR_VERSION;")

    if [[ "$PHP_MAJOR_VERSION" -gt "$1" || "$PHP_MAJOR_VERSION" -eq "$1" && "$PHP_MINOR_VERSION" -ge "$2" ]]; then
        return 1;
    else
        return 0;
    fi
}


#
# Install extension from package file(.tgz),
# For example:
#
# installExtensionFromTgz redis-5.0.2
#
# Param 1: Package name with version
# Param 2: enable options
#
installExtensionFromTgz()
{
    tgzName=$1
    extensionName="${tgzName%%-*}"

    mkdir ${extensionName}
    tar -xf ${tgzName}.tgz -C ${extensionName} --strip-components=1
    ( cd ${extensionName} && phpize && ./configure && make ${MC} && make install )

    docker-php-ext-enable ${extensionName} $2
}

if [[ -z "${EXTENSIONS##*,redis,*}" ]]; then
    echo "---------- Install redis ----------"
    installExtensionFromTgz redis-5.3.1
fi

if [[ -z "${EXTENSIONS##*,yaf,*}" ]]; then
    echo "---------- Install yaf ----------"
    installExtensionFromTgz yaf-3.2.5
fi

if [[ -z "${EXTENSIONS##*,mongodb,*}" ]]; then
    echo "---------- Install mongodb ----------"
    installExtensionFromTgz mongodb-1.8.0
fi

if [[ -z "${EXTENSIONS##*,swoole,*}" ]]; then
    echo "---------- Install swoole ----------"
    tgzName=swoole-4.5.2
    extensionName="${tgzName%%-*}"

    mkdir ${extensionName}
    tar -xf ${tgzName}.tgz -C ${extensionName} --strip-components=1
    ( cd ${extensionName} && phpize && ./configure --enable-openssl --enable-http2  && make ${MC} && make install )

    docker-php-ext-enable ${extensionName} $2
fi


if [[ -z "${EXTENSIONS##*,imagick,*}" ]]; then
    echo "---------- Install imagick ----------"
    pecl install imagick
    docker-php-ext-enable imagick
fi

if [[ -z "${EXTENSIONS##*,xlswriter,*}" ]]; then
    echo "---------- Install xlswriter ----------"
    pecl install xlswriter
    docker-php-ext-enable xlswriter
fi


#base extension

docker-php-ext-install bcmath
 