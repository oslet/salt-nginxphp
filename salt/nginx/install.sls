#nginx.tar.gz
nginx_source:
  file.managed:
    - name: /tmp/nginx-1.4.6.tar.gz
    - unless: test -e /tmp/nginx-1.4.6.tar.gz
    - source: salt://nginx/files/nginx-1.4.6.tar.gz

#extract

extract_nginx:
  cmd.run:
    - cwd: /tmp
    - names:
      - tar zxvf nginx-1.4.6.tar.gz
    - unless: test -d /tmp/nginx-1.4.6
    - require:
      - file: nginx_source


#user

nginx_user:
  user.present:
    - name: nginx
    - uid: 1501
    - createhome: False
    - gid_from_name: True
    - shell: /sbin/nologin

#nginx_pkgs

nginx_pkg:
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
      - openssl-devel
      - GeoIP-devel
      - pcre-devel
      - zlib-devel

#libssl symbol
linbssl_ln:
  cmd.run:
    - names:
      - ln -s /usr/lib64/libssl.so.1.0.1e /usr/lib/libssl.so
    - unless: test -e /usr/lib/libssl.so

#nginx_compile
nginx_compile0:
  cmd.run:
    - cwd: /tmp/nginx-1.4.6
    - names:
      - ./configure --prefix=/opt/nginx --http-client-body-temp-path=/opt/nginx/client/ --http-proxy-temp-path=/opt/nginx/proxy/ --http-fastcgi-temp-path=/opt/nginx/fcgi/  --with-file-aio --with-http_realip_module --with-http_geoip_module --with-http_sub_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_stub_status_module --without-http_uwsgi_module --without-http_scgi_module --with-http_perl_module --without-mail_pop3_module --without-mail_imap_module --without-mail_smtp_module --with-pcre
    - unless: test -e Makefile
    - require:
      - cmd: extract_nginx
      - pkg:  nginx_pkg

nginx_compile1:
  cmd.wait:
      - unless: test -e Makefile
      - watch:
        - cmd: nginx_compile0

nginx_compile2:
  cmd.run:
    - cwd: /tmp/nginx-1.4.6
    - names:
      - make -j{{grains['num_cpus']}}
    - unless: test -f objs/nginx
    - require:
      - cmd: nginx_compile0

nginx_compile3:
  cmd.run:
    - cwd: /tmp/nginx-1.4.6
    - names:
      - make install
    - unless: test -d /opt/nginx
    - require:
      - cmd: nginx_compile2

#cache_dir
cache_dir:
  cmd:
    - names:
      - mkdir -p /opt/nginx/{client,proxy,fcgi,conf.d} && mkdir -p /var/log/nginx && chown -R nginx.nginx /opt/nginx/ && chown -R nginx.nginx /var/log/nginx/
    - unless: test -d /opt/nginx/client/
    - run
    - require:
      - cmd: nginx_compile3
