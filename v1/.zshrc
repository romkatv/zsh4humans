# Export XDG environment variables. Other environment variables are exported later (see below).
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# Cache directory. Can be deleted. When zshrc is sourced by `z4h ssh` on a remote host, this
# variable is already set to ${XDG_CACHE_HOME:-$HOME/.cache}/zsh4humans.ssh.
: "${Z4H:=${XDG_CACHE_HOME:-$HOME/.cache}/zsh4humans}"

# URL of the base config. Used during initial installation and later when updating.
: "${Z4H_URL:=https://raw.githubusercontent.com/romkatv/zsh4humans/master/v1}"

if [ ! -e "$Z4H"/z4h.zsh ]; then
  mkdir -p -- "$Z4H" || return
  if command -v curl >/dev/null 2>&1; then
    curl -fsSLo "$Z4H"/z4h.zsh.$$ -- "$Z4H_URL"/z4h.zsh || return
  elif command -v wget >/dev/null 2>&1; then
    wget -qO    "$Z4H"/z4h.zsh.$$ -- "$Z4H_URL"/z4h.zsh || return
  else
    >&2 echo 'z4h: please install `curl` or `wget`'
    return 1
  fi
  mv -- "$Z4H"/z4h.zsh.$$ "$Z4H"/z4h.zsh || return
fi

. "$Z4H"/z4h.zsh || return

# Code above this line should not assume the current shell is Zsh. Below this line we are in Zsh.

zstyle :z4h:    auto-update      ask  # 'ask': ask to update; 'no': disable auto-update
zstyle :z4h:    auto-update-days 13   # auto-update this often; has no effect if auto-update is 'no'
# Bind alt-arrows or ctrl-arrows to change current directory? The other key modifier will get bound
# to cursor movement by words.
zstyle :z4h:    cd-key           alt  
# `z4h ssh` copies these files (relative to $ZDOTDIR, wich defaults to $HOME) to the remote host.
# Type `z4h ssh` to learn more about this feature.
zstyle :z4h:ssh dofiles          .zshrc .p10k.zsh
# Right-arrow key accepts one character (partial-accept) or the whole autosuggestion (accept)?
zstyle :z4h:autosuggestions forward-char accept
# Z4H_SSH is 1 when zshrc is being sourced on the remove host by `z4h ssh`.
if (( Z4H_SSH )); then
  zstyle :z4h: check-login-shell no   # don't check login shell when working remotely via `z4h ssh`
else
  zstyle :z4h: check-login-shell yes  # when working locally, check that login shell is zsh
fi

z4h install || return  # install or update core dependencies (fzf, zsh-autosuggestions, etc.)

# Clone additional Git repositories from GitHub. This doesn't do anything apart from cloning the
# repository and keeping it up-to-date. Cloned files can be used after `z4h init`.
z4h clone ohmyzsh/ohmyzsh  # ohmyzsh is just an example; you can delete it if you don't need it

z4h init || return  # initialize zsh; after this point console I/O is unavailable

# Enable emacs (-e) or vi (-v) keymap.
bindkey -e

# Export environment variables.
export EDITOR=nano
export GPG_TTY=$TTY

# Extend PATH.
path=(~/bin $path)

# Use additional Git repositories pulled in with `z4h clone ...`.
z4h source $Z4H/ohmyzsh/ohmyzsh/lib/diagnostics.zsh                         # just an example
z4h source $Z4H/ohmyzsh/ohmyzsh/plugins/emoji-clock/emoji-clock.plugin.zsh  # just an example

# Source additional local files.
if [[ $LC_TERMINAL == iTerm2 ]]; then
  z4h source ~/.iterm2_shell_integration.zsh  # enable iTerm2 shell integration (if installed)
fi

# Autoload functions.
autoload -Uz zmv

# Define functions.
function md() { [[ $# == 1 ]] && mkdir -p -- "$1" && cd -- "$1" }
compdef _directories md

# Define aliases.
alias tree='tree -aC -I .git'

# Add flags to existing aliases.
alias ls="${aliases[ls]:-ls} -A"
