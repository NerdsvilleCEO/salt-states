{% set pkgs = salt['pillar.get']("common:pkgs", []) %}
{% for pkg in pkgs %}
{{ pkg }}:
  pkg.installed
{% endfor %}
