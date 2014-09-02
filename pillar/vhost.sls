vhost:
  {% if 'node' in grains['id'] %}    
  - name: www 
    target: /opt/nginx/conf.d/vhost_www.conf
  {% else %}
  - name: cus
    target: /opt/nginx/conf.d/vhost_cus.conf
  {% endif %}

