#php.tar.bz2
php_source:
  file.managed:
    - name: /tmp/php-5.3.28.tar.bz2
    - unless: test -e /tmp/php-5.3.28.tar.bz2
    - source: salt://php/files/php-5.3.28.tar.bz2

#extract
extract_php:
  cmd.run:
    - cwd: /tmp
    - names:
      - tar jxvf php-5.3.28.tar.bz2
    - unless: test -d /tmp/php-5.3.28
    - require:
      - file: php_source


#user
php_user:
  user.present:
    - name: www
    - uid: 1502
    - createhome: False
    - gid_from_name: True
    - shell: /sbin/nologin

#php_pkgs
php_pkg:
  pkg.installed:
    - pkgs:
      - gcc
      - gcc-c++
      - bison
      - perl-ExtUtils-Embed
      - libxml2-devel
      - libjpeg-turbo-devel
      - libpng-devel
      - freetype-devel
      - intltool
      - libicu-devel
      - libcurl-devel
      - GeoIP-devel
      - openssl-devel
      - pcre-devel
      - zlib-devel
#php_compile
php_compile0:
  cmd.run:
    - cwd: /tmp/php-5.3.28
    - names:
      - ./configure --prefix=/opt/php --enable-fpm --with-config-file-path=/opt/php/etc/ --with-libxml-dir --with-openssl=/usr --with-zlib --with-gd --with-jpeg-dir --with-png-dir --with-freetype-dir --enable-gd-native-ttf --enable-gd-jis-conv --with-mhash --enable-mbstring --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --enable-sockets --with-curl --enable-sysvmsg --enable-sysvsem --enable-sysvshm --with-pear --enable-intl  --enable-soap --enable-wddx
    - unless: test -e Makefile
    - require:
      - cmd: extract_php

php_compile1:
  cmd.wait:
      - unless: test -e Makefile
      - watch:
        - cmd: php_compile0

php_compile2:
  cmd.run:
    - cwd: /tmp/php-5.3.28
    - names:
      - make -j{{grains['num_cpus']}}
    - unless: test -f main/php_ini.o
    - require:
      - cmd: extract_php
      - pkg: php_pkg
      - cmd: php_compile0

php_compile3:
  cmd.run:
    - cwd: /tmp/php-5.3.28
    - names:
      - make install
    - unless: test -d /opt/php
    - require:
      - cmd: php_compile2

#log_dir
log_dir:
  cmd.run:
    - names:
      - mkdir -p /opt/php/log
    - unless: test -d /opt/php/log/
    - require:
      - cmd: php_compile3

#extension_install
extension:
  cmd.run:
    - names:
      - echo yes | /opt/php/bin/pecl install memcache && /opt/php/bin/pecl install geoip && /opt/php/bin/pecl install redis 
    - unless: test -d /opt/php/lib/php/extensions/no-debug-non-zts-20090626/
    - require:
      - cmd: php_compile3
