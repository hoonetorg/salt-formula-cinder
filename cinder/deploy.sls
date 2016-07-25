{%- from "cinder/map.jinja" import controller with context %}
{%- from "cinder/map.jinja" import volume with context %}

{%- if controller.get('enabled', False) %}
{%- for backend_name, backend in controller.get('backend', {}).iteritems() %}

cinder_deploy__cinder_type_create_{{ backend_name }}:
  cmd.run:
  - name: "source /root/keystonerc; cinder type-create {{ backend.type_name }}"
  - unless: "source /root/keystonerc; cinder type-list | grep {{ backend.type_name }}"

cinder_deploy__cinder_type_update_{{ backend_name }}:
  cmd.run:
  - name: "source /root/keystonerc; cinder type-key {{ backend.type_name }} set volume_backend_name={{ backend_name }}"
  - unless: "source /root/keystonerc; cinder extra-specs-list | grep \"{u'volume_backend_name': u'{{ backend_name }}'}\""
  - require:
    - cmd: cinder_deploy__cinder_type_create_{{ backend_name }}

{%- endfor %}
{%- endif %}

{%- if volume.get('enabled', False) %}
{%- if volume.backend is defined %}

{%- for backend_name, backend in volume.get('backend', {}).iteritems() %}

{%- if backend.engine == 'iscsi' %}

cinder_deploy__backend_iscsi_packages:
  pkg.installed:
  - names:
    - iscsitarget
    - open-iscsi
    - iscsitarget-dkms

cinder_deploy__backend_iscsi_file_/etc/default/iscsitarget:
  file.managed:
  - source: salt://cinder/files/iscsitarget
  - template: jinja
  - require:
    - pkg: cinder_deploy__backend_iscsi_packages

cinder_deploy__backend_iscsi_service:
  service.running:
  - names:
    - iscsitarget
    - open-iscsi
  - enable: true
  - watch:
    - file: cinder_deploy__backend_iscsi_file_/etc/default/iscsitarget

{%- endif %}

{%- if backend.engine == 'hitachi_vsp' %}
#either it works after juno and with all os's or we don't need it
{#- if grains.os_family == 'Debian' and volume.version == 'juno' #}
cinder_deploy__backend_hitachi_vsp_packages:
  pkg.installed:
    - names:
      - horcm
      - hbsd

cinder_deploy__backend_hitachi_vsp_dir:
  file.directory:
    - name: /var/lock/hbsd
    - user: cinder
    - group: cinder
    - require:
      - pkg: cinder_deploy__backend_hitachi_vsp_packages
{#- endif #}

{%- endif %}

{%- if backend.engine == 'hp3par' %}

cinder_deploy__backend_hp3par_packages:
  pkg.installed:
    - name: python-hp3parclient

{%- endif %}

{%- if backend.engine == 'fujitsu' %}

cinder_deploy__backend_fujitsu_packages:
  pkg.installed:
    - name: cinder-driver-fujitsu

cinder_deploy__backend_fujitsu_file_/etc/cinder/cinder_fujitsu_eternus_dx_{{ backend_name }}.xml:
  file.managed:
  - source: salt://cinder/files/{{ volume.version }}/cinder_fujitsu_eternus_dx.xml
  - template: jinja
  - defaults:
      backend_name: "{{ backend_name }}"
  - require:
    - pkg: cinder_deploy__backend_fujitsu_packages

{%- endif %}

{%- endfor %}

{%- endif %}

{%- endif %}
