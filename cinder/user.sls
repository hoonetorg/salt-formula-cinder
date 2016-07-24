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

cinder_group:
  group.present:
    - name: {{user.group.name}}
    - gid: {{user.group.gid}}
    - system: True
    - require_in:
      - user: cinder_user
