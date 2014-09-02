include:
  - nginx.install
nginx:
  file:
    - managed
    - name: /opt/nginx/conf/nginx.conf
    - source: salt://nginx/files/nginx.conf
    - template: jinja
    - user: nginx
    - group: nginx
    - mode: 644
    - defaults:
        nginx_user: "nginx nginx"
        num_cpus: {{grains['num_cpus']}}

nginxinit:
  file:
    - managed
    - user: root
    - mode: 755
    - name: /etc/init.d/nginx
    - source: salt://nginx/files/nginx
  cmd.run:
    - names:
      - /sbin/chkconfig --add nginx
      - /sbin/chkconfig  nginx on
    - unless: /sbin/chkconfig --list nginx
  service.running:
    - name: nginx
    - enable: True
    - reload: True
    - watch:
      - file: /opt/nginx/conf.d/*.conf

nginx_log_cut:
  file:
    - managed
    - user: nginx
    - group: nginx
    - mode: 755
    - name: /opt/nginx/sbin/nginx_log_cut.sh
    - source: salt://nginx/files/nginx_log_cut.sh
  cron.present:
    - name: sh /opt/nginx/sbin/nginx_log_cut.sh
    - user: root
    - minute: 10
    - hour: 0
    - require:
      - file: nginx_log_cut
