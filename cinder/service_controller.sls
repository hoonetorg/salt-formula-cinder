{%- from "cinder/map.jinja" import controller with context %}
{%- if controller.enabled %}
cinder_controller_services:
  service.running:
  - names: {{ controller.services }}
  - enable: true
{%- endif %}
