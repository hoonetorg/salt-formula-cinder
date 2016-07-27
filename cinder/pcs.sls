# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set server = {} %}
{%- if salt['pillar.get']('cinder_type', False) in ['controller'] %}
{%- from "cinder/map.jinja" import controller with context %}
{%- set server = controller %}
{%- endif %}
{%- if salt['pillar.get']('cinder_type', False) in ['volume'] %}
{%- from "cinder/map.jinja" import volume with context %}
{%- set server = volume %}
{%- endif %}

{% set pcs = server.get('pcs', {}) %}

{# set pcs = salt['pillar.get']('cinder:server:pcs', {}) #}

{% if pcs.cinder_cib is defined and pcs.cinder_cib %}
cinder_pcs__cib_present_{{pcs.cinder_cib}}:
  pcs.cib_present:
    - cibname: {{pcs.cinder_cib}}
{% endif %}

{% if 'resources' in pcs %}
{% for resource, resource_data in pcs.resources.items()|sort %}
cinder_pcs__resource_present_{{resource}}:
  pcs.resource_present:
    - resource_id: {{resource}}
    - resource_type: "{{resource_data.resource_type}}"
    - resource_options: {{resource_data.resource_options|json}}
{% if pcs.cinder_cib is defined and pcs.cinder_cib %}
    - require:
      - pcs: cinder_pcs__cib_present_{{pcs.cinder_cib}}
    - require_in:
      - pcs: cinder_pcs__cib_pushed_{{pcs.cinder_cib}}
    - cibname: {{pcs.cinder_cib}}
{% endif %}
{% endfor %}
{% endif %}

{% if 'constraints' in pcs %}
{% for constraint, constraint_data in pcs.constraints.items()|sort %}
cinder_pcs__constraint_present_{{constraint}}:
  pcs.constraint_present:
    - constraint_id: {{constraint}}
    - constraint_type: "{{constraint_data.constraint_type}}"
    - constraint_options: {{constraint_data.constraint_options|json}}
{% if pcs.cinder_cib is defined and pcs.cinder_cib %}
    - require:
      - pcs: cinder_pcs__cib_present_{{pcs.cinder_cib}}
    - require_in:
      - pcs: cinder_pcs__cib_pushed_{{pcs.cinder_cib}}
    - cibname: {{pcs.cinder_cib}}
{% endif %}
{% endfor %}
{% endif %}

{% if pcs.cinder_cib is defined and pcs.cinder_cib %}
cinder_pcs__cib_pushed_{{pcs.cinder_cib}}:
  pcs.cib_pushed:
    - cibname: {{pcs.cinder_cib}}
{% endif %}

cinder_pcs__empty_sls_prevent_error:
  cmd.run:
    - name: true
    - unless: true

