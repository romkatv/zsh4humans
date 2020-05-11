if [ -n "$ZSH_VERSION" ]; then
  if [[ "${+functions[z4h]}" = "0" ]]; then
    emulate zsh
    setopt auto_cd    no_bg_nice    no_flow_control  hist_find_no_dups
    setopt c_bases    hist_verify   auto_param_slash hist_ignore_space
    setopt multios    always_to_end complete_in_word interactive_comments
    setopt path_dirs  extended_glob extended_history hist_expire_dups_first
    setopt auto_pushd share_history hist_ignore_dups 

    PS1='%B%F{2}%n@%m%f %F{4}%~%f
%F{%(?.2.1)}%#%f%b '
    RPS1='%B%F{3}z4h recovery mode%f%b'

    WORDCHARS=
    ZLE_REMOVE_SUFFIX_CHARS=
    HISTFILE=${ZDOTDIR:-~}/.zsh_history
    HISTSIZE=1000000000
    SAVEHIST=1000000000

    bindkey -d
    bindkey -e

    bindkey -s '^[OM' '^M'
    bindkey -s '^[Ok' '+'
    bindkey -s '^[Om' '-'
    bindkey -s '^[Oj' '*'
    bindkey -s '^[Oo' '/'
    bindkey -s '^[OX' '='
    bindkey -s '^[OH' '^[[H'
    bindkey -s '^[OF' '^[[F'
    bindkey -s '^[OA' '^[[A'
    bindkey -s '^[OB' '^[[B'
    bindkey -s '^[OD' '^[[D'
    bindkey -s '^[OC' '^[[C'
    bindkey -s '^[[1~' '^[[H'
    bindkey -s '^[[4~' '^[[F'

    bindkey -M emacs '^[[H'    beginning-of-line
    bindkey -M viins '^[[H'    vi-beginning-of-line
    bindkey -M vicmd '^[[H'    vi-beginning-of-line
    bindkey -M emacs '^[[F'    end-of-line
    bindkey -M viins '^[[F'    vi-end-of-line
    bindkey -M vicmd '^[[F'    vi-end-of-line
    bindkey -M viins '^?'      backward-delete-char
    bindkey -M emacs '^[[3;5~' kill-word
    bindkey -M emacs '^[[3;3~' kill-word
    bindkey -M emacs '^[k'     backward-kill-line
    bindkey -M emacs '^[K'     backward-kill-line
    bindkey -M emacs '^[j'     kill-buffer
    bindkey -M emacs '^[J'     kill-buffer
    bindkey -M viins '^_'      undo
    bindkey -M emacs '^[\'     redo
    bindkey -M viins '^[\'     redo
    bindkey -M emacs '^[[1;3D' backward-word
    bindkey -M emacs '^[[1;5D' backward-word
    bindkey -M viins '^[[1;3D' vi-backward-word
    bindkey -M viins '^[[1;5D' vi-backward-word
    bindkey -M emacs '^[[1;3C' forward-word
    bindkey -M emacs '^[[1;5C' forward-word
    bindkey -M viins '^[[1;3C' vi-forward-word
    bindkey -M viins '^[[1;5C' vi-forward-word
  fi
fi

if [ -r "$Z4H"/romkatv/zsh4humans/main.zsh ]; then
  . "$Z4H"/romkatv/zsh4humans/main.zsh && return 0
  [ "$?" = 2 ]                         && return 2
fi

_z4h_bootstrap() {
  if [ -z "${Z4H:-}" ]; then
    if [ -t 2 ]; then
      >&2 printf '\033[33mz4h\033[0m: missing required parameter: \033[31mZ4H\033[0m\n'
      >&2 printf '\n'
      >&2 printf 'It must be set at the top of \033[4m%s\033[0m:\n' "${ZDOTDIR:-~}"/.zshrc
      >&2 printf '\n'
      >&2 printf '  \033[32m:\033[0m \033[33m"${Z4H:=${XDG_CACHE_HOME:-$HOME/.cache}/zsh4humans}"\033[0m\n'
      >&2 printf '\n'
      >&2 printf 'Note: The leading colon (\033[32m:\033[0m) is necessary.\n'
    else
      >&2 printf 'z4h: missing required parameter: Z4H\n'
      >&2 printf '\n'
      >&2 printf 'It must be set at the top of %s:\n' "${ZDOTDIR:-~}"/.zshrc
      >&2 printf '\n'
      >&2 printf '  : "${Z4H:=${XDG_CACHE_HOME:-$HOME/.cache}/zsh4humans}"\n'
      >&2 printf '\n'
      >&2 printf 'Note: The leading colon (:) is necessary.\n'
    fi
    return 2
  fi
  if [ -n "${Z4H##/*}" ]; then
    if [ -t 2 ]; then
      >&2 printf '\033[33mz4h\033[0m: invalid \033[1mZ4H\033[0m: \033[31m%s\033[0m\n' "$Z4H"
      >&2 printf '\n'
      >&2 printf 'It comes from \033[4m%s\033[0m. Correct value example:\n' "${ZDOTDIR:-~}"/.zshrc
      >&2 printf '\n'
      >&2 printf '  \033[32m:\033[0m \033[33m"${Z4H:=${XDG_CACHE_HOME:-$HOME/.cache}/zsh4humans}"\033[0m\n'
      >&2 printf '\n'
      >&2 printf 'Note: The leading colon (\033[32m:\033[0m) is necessary.\n'
    else
      >&2 printf 'z4h: invalid Z4H: %s\n' "$Z4H"
      >&2 printf '\n'
      >&2 printf 'It comes from %s. Correct value example:\n' "${ZDOTDIR:-~}"/.zshrc
      >&2 printf '\n'
      >&2 printf '  : "${Z4H:=${XDG_CACHE_HOME:-$HOME/.cache}/zsh4humans}"\n'
      >&2 printf '\n'
      >&2 printf 'Note: The leading colon (:) is necessary.\n'
    fi
    return 2
  fi
  if [ -z "${Z4H_URL:-}" ]; then
    if [ -t 2 ]; then
      >&2 printf '\033[33mz4h\033[0m: missing required parameter: \033[31mZ4H_URL\033[0m\n'
      >&2 printf '\n'
      >&2 printf 'It must be set at the top of \033[4m%s\033[0m:\n' "${ZDOTDIR:-~}"/.zshrc
      >&2 printf '\n'
      >&2 printf '  \033[32m:\033[0m \033[33m"${Z4H_URL:=https://raw.githubusercontent.com/romkatv/zsh4humans/v2}"\033[0m\n'
      >&2 printf '\n'
      >&2 printf 'Note: The leading colon (\033[32m:\033[0m) is necessary.\n'
    else
      >&2 printf 'z4h: missing required parameter: Z4H_URL\n'
      >&2 printf '\n'
      >&2 printf 'It must be set at the top of %s:\n' "${ZDOTDIR:-~}"/.zshrc
      >&2 printf '\n'
      >&2 printf '  : "${Z4H_URL:=https://raw.githubusercontent.com/romkatv/zsh4humans/v2}"\n'
      >&2 printf '\n'
      >&2 printf 'Note: The leading colon (:) is necessary.\n'
    fi
    return 2
  fi
  local id="${Z4H_URL#https://raw.githubusercontent.com/}"
  local ref="${id##*/}"
  local proj="${id%/*}"
  local dir="$Z4H/$proj"
  local tmp="$dir.tmp.$$"
  if [ "$mid" = "$Z4H_URL" -o -z "$ref" -o -z "$proj" ]; then
    if [ -t 2 ]; then
      >&2 printf '\033[33mz4h\033[0m: invalid \033[1mZ4H_URL\033[0m: \033[31m%s\033[0m\n' "$Z4H_URL"
      >&2 printf '\n'
      >&2 printf 'It comes from \033[4m%s\033[0m. Correct value example:\n' "${ZDOTDIR:-~}"/.zshrc
      >&2 printf '\n'
      >&2 printf '  \033[32m:\033[0m \033[33m"${Z4H_URL:=https://raw.githubusercontent.com/romkatv/zsh4humans/v2}"\033[0m\n'
      >&2 printf '\n'
      >&2 printf 'Note: The leading colon (\033[32m:\033[0m) is necessary.\n'
    else
      >&2 printf 'z4h: invalid Z4H_URL: %s\n' "$Z4H_URL"
      >&2 printf '\n'
      >&2 printf 'It comes from %s. Correct value example:\n' "${ZDOTDIR:-~}"/.zshrc
      >&2 printf '\n'
      >&2 printf '  : "${Z4H_URL:=https://raw.githubusercontent.com/romkatv/zsh4humans/v2}"\n'
      >&2 printf '\n'
      >&2 printf 'Note: The leading colon (:) is necessary.\n'
    fi
    return 2
  fi

  if [ -t 2 ]; then
    >&2 printf '\033[33mz4h\033[0m: fetching \033[1m%s\033[0m\n' "$proj"
  else
    >&2 printf 'z4h: fetching %s\n' "$proj"
  fi

  command mkdir -p -- "$tmp" || return 1

  (
    cd ${ZSH_VERSION:+-q} -- "$tmp" || exit

    local url="https://github.com/$proj/archive/$ref.tar.gz"
    local err

    if command -v curl >/dev/null 2>&1; then
      err="$(command curl -fsSLo snapshot.tar.gz -- "$url" 2>&1)"
    elif command -v wget >/dev/null 2>&1; then
      err="$(command wget -O snapshot.tar.gz -- "$url" 2>&1)"
    else
      if [ -t 2 ]; then
        >&2 printf '\033[33mz4h\033[0m: please install \033[32mcurl\033[0m or \033[32mwget\033[0m\n'
      else
        >&2 printf 'z4h: please install curl or wget\n'
      fi
      exit 1
    fi

    if [ $? != 0 ]; then
      >&2 printf "%s\n" "$err"
      if [ -t 2 ]; then
        >&2 printf '\033[33mz4h\033[0m: failed to download \033[31m%s\033[0m\n' "$url"
      else
        >&2 printf 'z4h: failed to download %s\n' "$url"
      fi
      exit 1
    fi

    command tar -xzf snapshot.tar.gz  || exit
    ./*-*/sc/setup -n "$Z4H"          || exit
    command rm -rf -- "$dir"          || exit
    command mv -f -- ./*-* "$dir"     || exit
  )

  local ret=$?
  command rm -rf -- "$tmp"

  return "$ret"
}

if ! [ -r "$Z4H"/romkatv/zsh4humans/main.zsh ]; then
  _z4h_bootstrap && { unset -f _z4h_bootstrap; return 0; }
  [ "$?" = 2 ]   && { unset -f _z4h_bootstrap; return 2; }
fi

unset -f _z4h_bootstrap

if [ -t 2 ]; then
  >&2 printf '\033[33mz4h\033[0m: bootstap \033[31mfailed\033[0m\n'
  if [ -e "$Z4H" ]; then
    >&2 printf '\n'
    >&2 printf 'Try deleting the cache directory (\033[1m$Z4H\033[0m):\n'
    >&2 printf '\n'
    >&2 printf '  \033[32mrm\033[0m -rf -- \033[4m%s\033[0m\n' "$Z4H"
  fi
  if [ -n "$ZSH_VERSION" ]; then
    >&2 printf '\n'
    >&2 printf 'Restart \033[32mzsh\033[0m to retry.\n'
  fi
else
  >&2 printf 'z4h: bootstap failed\n'
  if [ -e "$Z4H" ]; then
    >&2 printf '\n'
    >&2 printf 'Try deleting the cache directory ($Z4H):\n'
    >&2 printf '\n'
    >&2 printf '  rm -rf -- %s\n' "$Z4H"
  fi
  if [ -n "$ZSH_VERSION" ]; then
    >&2 printf '\n'
    >&2 printf 'Restart zsh to retry.\n'
  fi
fi

return 1
