# Documentation: https://github.com/romkatv/zsh4humans/blob/v5/README.md.
#
# Do not modify this file unless you know exactly what you are doing.
# It is strongly recommended to keep all shell customization and configuration
# (including exported environment variables such as PATH) in ~/.zshrc or in
# files sourced from ~/.zshrc. If you are certain that you must export some
# environment variables in ~/.zshenv, add them at the very bottom of the file.

if [ -n "${ZSH_VERSION-}" ]; then
  : ${ZDOTDIR:=~}
  setopt no_global_rcs no_rcs
  [[ -o interactive ]] && Z4H_BOOTSTRAPPING=1
fi

if [ -n "${Z4H_BOOTSTRAPPING-}" ]; then
  umask o-w
  unset Z4H_BOOTSTRAPPING

  Z4H_URL="https://raw.githubusercontent.com/romkatv/zsh4humans/v5"
  : "${Z4H:=${XDG_CACHE_HOME:-$HOME/.cache}/zsh4humans/v5}"

  if [ ! -e "$Z4H"/z4h.zsh ]; then
    mkdir -p -- "$Z4H" || return
    >&2 printf '\033[33mz4h\033[0m: fetching \033[4mz4h.zsh\033[0m\n'
    if command -v curl >/dev/null 2>&1; then
      curl -fsSL -- "$Z4H_URL"/z4h.zsh >"$Z4H"/z4h.zsh.$$ || return
    elif command -v wget >/dev/null 2>&1; then
      wget -O-   -- "$Z4H_URL"/z4h.zsh >"$Z4H"/z4h.zsh.$$ || return
    else
      >&2 printf '\033[33mz4h\033[0m: please install \033[32mcurl\033[0m or \033[32mwget\033[0m\n'
      return 1
    fi
    mv -- "$Z4H"/z4h.zsh.$$ "$Z4H"/z4h.zsh || return
  fi

  if [ -n "${ZSH_VERSION-}" ]; then
    setopt rcs
    source "$Z4H"/z4h.zsh zshenv
  else
    . "$Z4H"/z4h.zsh || return
  fi
fi

# If you are certain that you must export some environment variables
# in ~/.zshenv (see comments at the top!), do it below this comment.
# Do not change anything else in this file.

# export GOPATH=$HOME/go
# export PATH=$HOME/bin:$PATH
