def test_zsh_is_installed(host):
  assert host.exists("zsh")

  # TODO: Pull from pillars for the version to check
  assert "5.2" in host.run("zsh --version").stdout

def test_emacs_is_installed(host):
  assert host.exists("emacs")

  # TODO: Pull from pillars for the version to check
  assert "25.2" in host.run("emacs --version").stdout

def test_idempotency(host):
  # TODO: re-converge with flag to test that no changes are made
  pass

def test_libraries_and_deps_installed(host):
  # TODO: Pull from pillars for this data
  deps = [".bootstrap-gitconfig", ".zshrc", ".zshenv", ".fzf", 
         ".rbenv", ".pyenv", ".nvm", ".oh-my-zsh"]
  for dep in deps:
    assert host.file("/home/josh.santos/%s" %dep).exists
