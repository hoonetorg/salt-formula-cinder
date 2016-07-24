{%- from "cinder/map.jinja" import volume with context %}
{%- if volume.enabled %}
cinder_volume_services:
  service.running:
  - names: {{ volume.services }}
  - enable: true
  - watch:
    - file: /etc/cinder/cinder.conf
    - file: /etc/cinder/api-paste.ini
{%- endif %}
