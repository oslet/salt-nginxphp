include:
  - php.install
php:
  file:
    - managed
    - name: /opt/php/etc/php.ini
    - source: salt://php/files/php.ini
    - user: www
    - group: www
    - mode: 644

phpfpm:
  file:
    - managed
    - name: /opt/php/etc/php-fpm.conf
    - source: salt://php/files/php-fpm.conf
    - user: www
    - group: www
    - mode: 644

phpinfo:
  file:
    - managed
    - name: /opt/nginx/html/phpinfo.php
    - source: salt://php/files/phpinfo.php
    - user: www
    - group: www
    - mode: 644

phpinit:
  file:
    - managed
    - user: root
    - mode: 755
    - name: /etc/init.d/php-fpm
    - source: salt://php/files/php-fpm
  cmd.run:
    - names:
      - /sbin/chkconfig --add php-fpm
      - /sbin/chkconfig php-fpm on
    - unless: /sbin/chkconfig --list php-fpm
  service.running:
    - name: php-fpm
    - enable: True
    - reload: True
    - watch:
      - file: /opt/php/etc/php.ini
      - file: /opt/php/etc/php-fpm.conf
