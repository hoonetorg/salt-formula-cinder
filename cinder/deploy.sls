{%- from "cinder/map.jinja" import controller with context %}
{%- from "cinder/map.jinja" import volume with context %}

{%- if controller.get('enabled', False) %}
{%- for backend_name, backend in controller.get('backend', {}).iteritems() %}

cinder_type_create_{{ backend_name }}:
  cmd.run:
  - name: "source /root/keystonerc; cinder type-create {{ backend.type_name }}"
  - unless: "source /root/keystonerc; cinder type-list | grep {{ backend.type_name }}"
  - require:
    - service: cinder_controller_services

cinder_type_update_{{ backend_name }}:
  cmd.run:
  - name: "source /root/keystonerc; cinder type-key {{ backend.type_name }} set volume_backend_name={{ backend_name }}"
  - unless: "source /root/keystonerc; cinder extra-specs-list | grep \"{u'volume_backend_name': u'{{ backend_name }}'}\""
  - require:
    - cmd: cinder_type_create_{{ backend_name }}

{%- endfor %}
{%- endif %}

{%- if volume.get('enabled', False) %}
{%- if volume.backend is defined %}

{%- for backend_name, backend in volume.get('backend', {}).iteritems() %}

{%- if backend.engine == 'iscsi' %}

cinder_iscsi_packages_{{ loop.index }}:
  pkg.installed:
  - names:
    - iscsitarget
    - open-iscsi
    - iscsitarget-dkms
  - require:
    - pkg: cinder_packages

/etc/default/iscsitarget:
  file.managed:
  - source: salt://cinder/files/iscsitarget
  - template: jinja
  - require:
    - pkg: cinder_iscsi_packages

cinder_scsi_service:
  service.running:
  - names:
    - iscsitarget
    - open-iscsi
  - enable: true
  - watch:
    - file: /etc/default/iscsitarget

{%- endif %}

{%- if backend.engine == 'hp3par' %}

hp3parclient:
  pkg.latest:
    - name: python-hp3parclient

{%- endif %}

{%- if backend.engine == 'fujitsu' %}

cinder_driver_fujitsu_{{ loop.index }}:
  pkg.latest:
    - name: cinder-driver-fujitsu

/etc/cinder/cinder_fujitsu_eternus_dx_{{ backend_name }}.xml:
  file.managed:
  - source: salt://cinder/files/{{ volume.version }}/cinder_fujitsu_eternus_dx.xml
  - template: jinja
  - defaults:
      backend_name: "{{ backend_name }}"
  - require:
    - pkg: cinder-driver-fujitsu

{%- endif %}

{%- endfor %}

{%- endif %}

{%- endif %}
