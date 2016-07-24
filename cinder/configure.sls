{%- from "cinder/map.jinja" import controller with context %}
{%- from "cinder/map.jinja" import volume with context %}

{%- set server = {} %}
{%- if controller.get('enabled', False) %}
  {%- do server.update(controller) %}
{%- endif %}
{%- if volume.get('enabled', False) %}
  {%- do server.update(volume) %}
{%- endif %}
#{# server|json#}

include:
- cinder.packages

/etc/cinder/cinder.conf:
  file.managed:
  - source: salt://cinder/files/{{ server.version }}/cinder.conf.{{ grains.os_family }}
  - template: jinja
  - require:
    - pkg: cinder_packages

/etc/cinder/api-paste.ini:
  file.managed:
  - source: salt://cinder/files/{{ server.version }}/api-paste.ini.{{ grains.os_family }}
  - template: jinja
  - require:
    - pkg: cinder_packages

{%- if controller.get('enabled', False) %}
cinder_syncdb:
  cmd.run:
  - name: cinder-manage db sync
  - require:
    - file: /etc/cinder/cinder.conf
    - file: /etc/cinder/api-paste.ini
{%- endif %}

{%- if volume.get('enabled', False) %}

/var/lock/cinder:
  file.directory:
  - mode: 755
  - user: cinder
  - group: cinder
  - require:
    - pkg: cinder_packages
  - require_in:
    - service: cinder_volume_services
{%- endif %}

