# Export XDG environment variables. Other environment variables are exported later.
export XDG_CACHE_HOME="$HOME/.cache"

# URL of zsh4humans repository. Used during initial installation and updates.
Z4H_URL="https://raw.githubusercontent.com/romkatv/zsh4humans/v2"

# Cache directory. Gets recreated if deleted. If already set, must not be changed.
: "${Z4H:=${XDG_CACHE_HOME:-$HOME/.cache}/zsh4humans}"

# Do not create world-writable files by default.
umask o-w

# Fetch z4h.zsh if it doesn't exist yet.
if [ ! -e "$Z4H"/z4h.zsh ]; then
  mkdir -p -- "$Z4H" || return
  >&2 printf '\033[33mz4h\033[0m: fetching \033[4mz4h.zsh\033[0m\n'
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL -- "$Z4H_URL"/z4h.zsh >"$Z4H"/z4h.zsh.$$ || return
  else
    wget -O-   -- "$Z4H_URL"/z4h.zsh >"$Z4H"/z4h.zsh.$$ || return
  fi
  mv -- "$Z4H"/z4h.zsh.$$ "$Z4H"/z4h.zsh || return
fi

# Code prior to this line should not assume the current shell is Zsh.
# Afterwards we are in Zsh.
. "$Z4H"/z4h.zsh || return

# 'ask': ask to update; 'no': disable auto-update.
zstyle ':z4h:' auto-update                     ask
# Auto-update this often; has no effect if auto-update is 'no'.
zstyle ':z4h:'                auto-update-days 28
# Stability vs freshness of plugins: stable, testing or dev.
zstyle ':z4h:*'               channel          stable
# Bind alt-arrows or ctrl-arrows to change current directory?
# The other key modifier will be bound to cursor movement by words.
zstyle ':z4h:'                cd-key           alt
# Right-arrow key accepts one character ('partial-accept') from
# command autosuggestions or the whole thing ('accept')?
zstyle ':z4h:autosuggestions' forward-char     partial-accept

if (( UID && UID == EUID )) && [[ -z $SSH_CONNECTION ]]; then
  # When logged in locally as a regular user, check that login shell
  # is zsh and offer to change it if it isn't.
  z4h chsh
fi

# Clone additional Git repositories from GitHub. This doesn't do anything
# apart from cloning the repository and keeping it up-to-date. Cloned
# files can be used after `z4h init`.
#
# This is just an example. If you don't plan to use Oh My Zsh, delete this.
z4h install ohmyzsh/ohmyzsh || return

# Install or update core components (fzf, zsh-autosuggestions, etc.) and
# initialize Zsh. After this point console I/O is unavailable. Everything
# that requires user interaction or can perform network I/O must be done
# above. Everything else is best done below.
z4h init || return

# Enable emacs (-e) or vi (-v) keymap.
bindkey -e

# Export environment variables.
export EDITOR=nano
export GPG_TTY=$TTY

# Extend PATH.
path=(~/bin $path)

# Use additional Git repositories pulled in with `z4h install`.
#
# This is just an example that you should delete. It doesn't do anything useful.
z4h source $Z4H/ohmyzsh/ohmyzsh/lib/diagnostics.zsh
z4h source $Z4H/ohmyzsh/ohmyzsh/plugins/emoji-clock/emoji-clock.plugin.zsh
fpath+=($Z4H/ohmyzsh/ohmyzsh/plugins/supervisor)

# Source additional local files.
if [[ $LC_TERMINAL == iTerm2 ]]; then
  # Enable iTerm2 shell integration (if installed).
  z4h source ~/.iterm2_shell_integration.zsh
fi

# Define key bindings.
bindkey -M emacs '^H' backward-kill-word # Ctrl-H and Ctrl-Backspace: Delete previous word.

# Sort completion candidates when pressing TAB?
zstyle ':completion:*' sort false

# Should cursor go to the end when up/down/ctrl-up/ctrl-down fetch commands from history?
zstyle ':zle:(up|down)-line-or-beginning-search' leave-cursor no

# Autoload functions.
autoload -Uz zmv

# Define functions and completions.
function md() { [[ $# == 1 ]] && mkdir -p -- "$1" && cd -- "$1" }
compdef _directories md

# Define aliases.
alias tree='tree -a -I .git'

# Add flags to existing aliases.
alias ls="${aliases[ls]:-ls} -A"

# Set shell options: http://zsh.sourceforge.net/Doc/Release/Options.html.
setopt glob_dots  # glob matches files starting with dot; `ls *` becomes equivalent to `ls *(D)`
