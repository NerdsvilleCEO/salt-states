{% set build_deps = salt['pillar.get']("build_deps:pkgs", []) %}
{% set user_vars = salt['pillar.get']("user_vars", {}) %}
{% set zsh_path = salt['pillar.get']("user_vars:zsh_path", "/usr/local/bin/zsh") %}

{{user_vars.home_dir}}/josh.santos:
  file.directory

create_group:
  group.present:
    - name: josh.santos

josh.santos:
  user.present:
    - groups: 
      - josh.santos

ensure_homedir_perms:
  file.directory:
    - name: {{user_vars.home_dir}}/josh.santos
    - user: josh.santos
    - group: josh.santos
    - recurse:
      - user
      - group

https://github.com/NerdsvilleCEO/.files.git:
  git.latest:
    - target: {{user_vars.home_dir}}/josh.santos/.files
    - force_reset: true
    - runas: josh.santos

{% if grains['os'] == 'MacOS' %}
install_emacs_plus:
  pkg.installed:
    - name: emacs-plus
    - runas: josh.santos
  file.symlink:
    - name: /Applications/Emacs.app/
    - target: /usr/local/Cellar/emacs-plus/25.3/Emacs.app/
{% endif %}

install_build_deps:
  pkg.installed:
     - pkgs: {{build_deps}}
     - unless: su - josh.santos -c ". ~/.zshrc && command -v zsh && command -v emacs && command -v python | grep 'shims' && command -v node"

compile_zsh:
  # cmd.wait
  # cmd.waitscript
  cmd.script:
     - source: {{user_vars.home_dir}}/josh.santos/.files/build-zsh.sh
     - unless: su - josh.santos -c "command -v zsh"

ensure_zsh_in_shells:
  cmd.run:
     - name: echo {{zsh_path}} | sudo tee -a /etc/shells
     - unless: grep {{zsh_path}} /etc/shells

oh_my_zsh:
  cmd.run:
     - name: sh -c "~/.files/oh-my-zsh.sh"
     - runas: josh.santos

{% if grains['os'] == 'MacOS' %}
chsh_zsh:
  cmd.run:
    - name: chpass -s {{zsh_path}} josh.santos
    - unless: grep {{zsh_path}} /etc/passwd
{% else %}
chsh_zsh:
  cmd.run:
     - name: chsh josh.santos -s {{zsh_path}}
     - unless: grep {{zsh_path}} /etc/passwd
{% endif %}

{% for file in user_vars.dotfiles %}
{{user_vars.home_dir}}/josh.santos/{{file}}:
  file.symlink:
    - target: {{user_vars.home_dir}}/josh.santos/.files/{{file}}   
    - user: josh.santos
    - group: josh.santos
    - force: true
{% endfor %}

change_email_env:
  file.line:
    - name: "{{user_vars.home_dir}}/josh.santos/.zshenv"
    - match: "export GIT_EMAIL=\"josh@nerdsville.net\""
    - content: "export GIT_EMAIL=\"josh.santos@defpoint.com\""
    - mode: "replace"

copy_path_from_zsh:
  cmd.run:
    - name: "printf 'export PATH=%s\n' $(zsh -c \"echo $PATH\") >> ~/.bashrc"
    - runas: josh.santos

{% for plugin, url in user_vars.zsh_plugins.iteritems() %}
{{url}}:
  git.latest:
    - target: {{user_vars.home_dir}}/josh.santos/.oh-my-zsh/custom/{{plugin}}
    - force_reset: true
    - runas: josh.santos
{% endfor %}

{{user_vars.spacemacs}}:
  git.latest:
    - target: {{user_vars.home_dir}}/josh.santos/.emacs.d
    - force_clone: true
    - force_reset: true
    - branch: develop
    - runas: josh.santos

{% for repo in ["fzf", "rbenv"] %}
{{user_vars.get(repo)}}:
  git.latest:
    - target: {{user_vars.home_dir}}/josh.santos/.{{repo}}
    - force_reset: true
    - runas: josh.santos
{% endfor %}

{% for script in ["pyenv", "nvm"] %}
{{script}}:
  cmd.script:
    - source: {{user_vars.get(script)}}
    - runas: josh.santos
{% endfor %}

/usr/local/share/zsh:
  file.directory:
    - user: josh.santos
    - group: josh.santos
    - recurse:
      - user
      - group

setup_deps:
  cmd.run:
    - name: . ~/.zshenv && . ~/.zshrc && . {{user_vars.home_dir}}/josh.santos/.files/install.sh
    - shell: {{zsh_path}}
    - runas: josh.santos
compile_emacs:
  cmd.script:
    - source: {{user_vars.home_dir}}/josh.santos/.files/build-emacs.sh
    - unless: su - josh.santos -c "command -v emacs"
remove_deps:
  pkg.removed:
    - pkgs: {{build_deps}}
