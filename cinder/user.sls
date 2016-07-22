{%- from "cinder/map.jinja" import user with context -%}
cinder_user:
  user.present:
    - name: {{user.user.name}}
    - home: {{user.user.home}}
    - uid: {{user.user.uid}}
    - gid: {{user.group.gid}}
    - groups: {{user.user.groups|json}}
    - shell: {{user.user.shell}}
    - system: True
    - require_in:
      {%- if pillar.cinder.controller is defined and pillar.cinder.controller.enabled %}
      - pkg: cinder_controller_packages
      {%- endif %}
      {%- if pillar.cinder.volume is defined and pillar.cinder.volume.enabled %}
      - pkg: cinder_volume_packages
      {%- endif %}

cinder_group:
  group.present:
    - name: {{user.group.name}}
    - gid: {{user.group.gid}}
    - system: True
    - require_in:
      - user: cinder_user
