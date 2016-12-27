{% from "uwsgi/map.jinja" import uwsgi, sls_block with context %}
{% set service_function = {True:'running', False:'dead'}.get(uwsgi.service.enable) %}


include:
  - uwsgi.emperor.install

{% if grains.os_family == 'FreeBSD' %}
uwsgi_sysrc_emperor:
  sysrc.managed:
    - name: uwsgi_emperor
    - value: 'YES'
uwsgi_sysrc_configfile:
  sysrc.managed:
    - name: uwsgi_configfile
    - value: '/usr/local/etc/uwsgi/emperor.ini'
{% endif %}

uwsgi_emperor_service:
  service.{{ service_function }}:
    {{ sls_block(uwsgi.service.opts) }}
    - name: {{ uwsgi.lookup.emperor_service }}
    - enable: {{ uwsgi.service.enable }}
    - require:
{% if grains.os_family == 'FreeBSD' %}
      - sysrc: uwsgi_sysrc_emperor
      - sysrc: uwsgi_sysrc_configfile
{% endif %}
      - sls: uwsgi.emperor.install
    - watch:
      - pkg: uwsgi_emperor_install
