{%- from "cinder/map.jinja" import controller with context %}
{%- from "cinder/map.jinja" import volume with context %}

include:
- cinder.user

{%- set pkgs = [] %}

{%- if controller.get('enabled', False) %}
  {%- set pkgs = pkgs + controller.pkgs %}
{%- endif %}
{%- if volume.get('enabled', False) %}
  {%- set pkgs = pkgs + volume.pkgs %}
{%- endif %}

cinder_packages__packages:
  pkg.installed:
  - names: {{ pkgs }}
  - require:
    - user: cinder_user__user
