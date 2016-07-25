{%- from "cinder/map.jinja" import controller with context %}
{%- from "cinder/map.jinja" import volume with context %}

include:
- cinder.configure
{% if pillar.cinder.controller is defined %}
- cinder.service_controller
{% endif %}
{% if pillar.cinder.volume is defined %}
- cinder.service_volume
{% endif %}
- cinder.deploy

extend:
  
{%- if controller.get('enabled', False) %}
  cinder_service_controller__services:
    service:
      - require:
        - cmd: cinder_configure__syncdb 

{%- for backend_name, backend in controller.get('backend', {}).iteritems() %}
  cinder_deploy__cinder_type_create_{{ backend_name }}:
    cmd:
      - require:
        - service: cinder_service_controller__services
{%- endfor %}
{%- endif %}

{%- if volume.get('enabled', False) %}
  cinder_service_volume__services:
    service:
      - require:
        - cmd: cinder_configure__syncdb 

{%- if volume.backend is defined %}
{%- for backend_name, backend in volume.get('backend', {}).iteritems() %}

{%- if backend.engine == 'iscsi' %}
  cinder_deploy__backend_iscsi_packages:
    pkg:
      - require:
        - pkg: cinder_packages__packages
{%- endif %}

{%- if backend.engine == 'hitachi_vsp' %}
  cinder_deploy__backend_hitachi_vsp_packages:
    pkg:
      - require:
        - pkg: cinder_packages__packages
{%- endif %}

{%- if backend.engine == 'hp3par' %}
  cinder_deploy__backend_hp3par_packages:
    pkg:
      - require:
        - pkg: cinder_packages__packages
{%- endif %}

{%- if backend.engine == 'fujitsu' %}
  cinder_deploy__backend_fujitsu_packages:
    pkg:
      - require:
        - pkg: cinder_packages__packages
{%- endif %}

{%- endfor %}
{%- endif %}

{%- endif %}
