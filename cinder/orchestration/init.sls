#!jinja|yaml
{%- set controller_node_ids = salt['pillar.get']('cinder:server:pcs:controller_node_ids') -%}
{%- set controller_admin_node_id = salt['pillar.get']('cinder:server:pcs:controller_admin_node_id') -%}
{%- set volume_node_ids = salt['pillar.get']('cinder:server:pcs:volume_node_ids') -%}
{%- set volume_admin_node_id = salt['pillar.get']('cinder:server:pcs:volume_admin_node_id') -%}
{%- set node_ids = [] %}
{%- set dup_node_ids = controller_node_ids + volume_node_ids %}
{%- for node_id in dup_node_ids %}
# probably appending {{node_id}}
{%- if node_id not in node_ids %}
# appending {{node_id}}
{%- do node_ids.append(node_id) %}
# node_ids: {{node_ids}}
{%- endif %}
{%- endfor %}

# controller_node_ids: {{controller_node_ids|json}}
# controller_admin_node_id: {{controller_admin_node_id}}
# volume_node_ids: {{volume_node_ids|json}}
# volume_admin_node_id: {{volume_admin_node_id}}
# dup_node_ids: {{dup_node_ids}}
# node_ids: {{node_ids}}

{%- for node_id in node_ids %}
cinder_orchestration__install_{{node_id}}:
  salt.state:
    - tgt: {{node_id}}
    - expect_minions: True
    - sls: cinder.configure
    - require_in:
      - salt: cinder_orchestration__pcs_controller
{%- endfor %}

{%- for controller_node_id in controller_node_ids %}
cinder_orchestration__service_controller_{{controller_node_id}}:
  salt.state:
    - tgt: {{controller_node_id}}
    - expect_minions: True
    - sls: cinder.service_controller
    - timeout: 60
    - require_in:
      - salt: cinder_orchestration__pcs_controller
{%- endfor %}

cinder_orchestration__pcs_controller:
  salt.state:
    - tgt: {{controller_admin_node_id}}
    - expect_minions: True
    - sls: cinder.pcs
    - pillar:
        cinder_type: controller

{%- for volume_node_id in volume_node_ids %}
cinder_orchestration__service_volume_{{volume_node_id}}:
  salt.state:
    - tgt: {{volume_node_id}}
    - expect_minions: True
    - sls: cinder.service_volume
    - timeout: 60
    - require:
      - salt: cinder_orchestration__pcs_controller
    - require_in:
      - salt: cinder_orchestration__pcs_volume
{%- endfor %}

cinder_orchestration__pcs_volume:
  salt.state:
    - tgt: {{volume_admin_node_id}}
    - expect_minions: True
    - sls: cinder.pcs
    - pillar:
        cinder_type: volume
