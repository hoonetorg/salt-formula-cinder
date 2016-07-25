{%- from "cinder/map.jinja" import controller with context %}
{%- if controller.get('enabled', False) %}
cinder_service_controller__services:
  service.{{ controller.service_state }}:
    - names: {{ controller.services }}
    {% if controller.service_state in [ 'running', 'dead' ] %}
    - enable: {{ controller.service_enable }}
    {% endif %}
{%- endif %}
