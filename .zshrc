# Export XDG environment variables. Other environment variables are exported later (see below).
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# URL of zsh4humans repository. Used during initial installation and later when updating.
: "${Z4H_URL:=https://raw.githubusercontent.com/romkatv/zsh4humans/v1}"

# Cache directory. Gets recreated when deleted.
: "${Z4H:=${XDG_CACHE_HOME:-$HOME/.cache}/zsh4humans}"

# Fetch z4h.zsh if it doesn't yet exist and source it.
if [ ! -e "$Z4H"/z4h.zsh ]; then
  mkdir -p -- "$Z4H" || return
  >&2 echo "z4h: downloading z4h.zsh"
  if command -v curl >/dev/null 2>&1; then
    curl -fsSLo "$Z4H"/z4h.zsh.$$ -- "$Z4H_URL"/z4h.zsh || return
  elif command -v wget >/dev/null 2>&1; then
    wget -O     "$Z4H"/z4h.zsh.$$ -- "$Z4H_URL"/z4h.zsh || return
  fi
  mv -- "$Z4H"/z4h.zsh.$$ "$Z4H"/z4h.zsh || return
fi

# Code prior to this line should not assume the current shell is Zsh. Afterwards we are in Zsh.
. "$Z4H"/z4h.zsh || return

# 'ask': ask to update; 'no': disable auto-update.
zstyle :z4h: auto-update                 ask
# Auto-update this often; has no effect if auto-update is 'no'.
zstyle :z4h: auto-update-days            28
# Bind alt-arrows or ctrl-arrows to change current directory? The other key modifier will be bound
# to cursor movement by words.
zstyle :z4h: cd-key                      alt
# Right-arrow key accepts one character (partial-accept) or the whole autosuggestion (accept)?
zstyle :z4h:autosuggestions forward-char partial-accept

# `z4h ssh` copies these files to the remote host. Type `z4h help ssh` to learn more.
zstyle ':z4h:ssh:*' files                                                \
  $ZDOTDIR/.zshrc             '$ZDOTDIR/' overwrite=1,remove=1,persist=0 \
  $ZDOTDIR/.p10k.zsh          '$ZDOTDIR/' overwrite=1,remove=1,persist=0 \
  $ZDOTDIR/.p10k-portable.zsh '$ZDOTDIR/' overwrite=1,remove=1,persist=0

# Install or update core dependencies (fzf, zsh-autosuggestions, etc.).
z4h install || return

# Clone additional Git repositories from GitHub. This doesn't do anything apart from cloning the
# repository and keeping it up-to-date. Cloned files can be used after `z4h init`.
z4h clone ohmyzsh/ohmyzsh  # ohmyzsh is just an example; you can delete it if you don't need it

# Z4H_SSH is 1 when zshrc is being sourced on the remove host by `z4h ssh`.
if (( ! Z4H_SSH )); then
  # When working locally, check that user's login shell is zsh and offer to change it if it isn't.
  z4h chsh
fi

# Initialize Zsh. After this point console I/O is unavailable. Everything that requires user
# interaction or can perform network I/O must be done above. Everything else is best done below.
z4h init || return

# Enable emacs (-e) or vi (-v) keymap.
bindkey -e

# Export environment variables.
export EDITOR=nano
export GPG_TTY=$TTY

# Extend PATH.
path=(~/bin $path)

# Use additional Git repositories pulled in with `z4h clone`.
z4h source $Z4H/ohmyzsh/ohmyzsh/lib/diagnostics.zsh                         # just an example
z4h source $Z4H/ohmyzsh/ohmyzsh/plugins/emoji-clock/emoji-clock.plugin.zsh  # just an example
fpath+=($Z4H/ohmyzsh/ohmyzsh/plugins/supervisor)                            # just an example

# Source additional local files.
if [[ $LC_TERMINAL == iTerm2 ]]; then
  z4h source ~/.iterm2_shell_integration.zsh  # enable iTerm2 shell integration (if installed)
fi

# Autoload functions.
autoload -Uz zmv

# Define functions and completions.
function md() { [[ $# == 1 ]] && mkdir -p -- "$1" && cd -- "$1" }
compdef _directories md

# Define aliases.
alias tree='tree -aC -I .git'

# Add flags to existing aliases.
alias ls="${aliases[ls]:-ls} -A"
