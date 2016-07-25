{%- from "cinder/map.jinja" import volume with context %}
{%- if volume.get('enabled', False) %}
cinder_service_volume__services:
  service.{{ volume.service_state }}:
    - names: {{ volume.services }}
    {% if volume.service_state in [ 'running', 'dead' ] %}
    - enable: {{ volume.service_enable }}
    {% endif %}
{%- endif %}

