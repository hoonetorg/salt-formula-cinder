
include:
- cinder.configure
{% if pillar.cinder.controller is defined %}
- cinder.service_controller
{% endif %}
{% if pillar.cinder.volume is defined %}
- cinder.service_volume
{% endif %}
