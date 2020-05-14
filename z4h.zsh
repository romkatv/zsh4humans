'export' TERM="${TERM:-xterm-256color}"

if '[' '-n' "${ZSH_VERSION-}" ']'; then
  if '[' '-n' "${_z4h_source_called+x}" ']'; then
    if '[' "${ZDOTDIR:-$HOME}" '=' "$HOME" ']'; then
      >&2 'printf' '\033[33mz4h\033[0m: please use \033[4;32mexec\033[0m \033[32mzsh\033[0m instead of \033[32msource\033[0m \033[4m~/.zshrc\033[0m\n'
    else
      >&2 'printf' '\033[33mz4h\033[0m: please use \033[4;32mexec\033[0m \033[32mzsh\033[0m instead of \033[32msource\033[0m \033[4;33m"$ZDOTDIR"\033[0;4m/.zshrc\033[0m\n'
    fi
    'return' '1'
  fi

  'typeset' '-gri' _z4h_source_called='1'

  'emulate' 'zsh'
  'setopt' 'auto_cd'    'no_bg_nice'    'no_flow_control'  'hist_find_no_dups'
  'setopt' 'c_bases'    'hist_verify'   'auto_param_slash' 'hist_ignore_space'
  'setopt' 'multios'    'always_to_end' 'complete_in_word' 'interactive_comments'
  'setopt' 'path_dirs'  'extended_glob' 'extended_history' 'hist_expire_dups_first'
  'setopt' 'auto_pushd' 'share_history' 'hist_ignore_dups' 'no_prompt_bang' 
  'setopt' 'prompt_cr'  'prompt_sp'     'prompt_percent'   'no_prompt_subst'
  'setopt' 'no_bg_nice' 'no_aliases'

  PS1="%B%F{2}%n@%m%f %F{4}%~%f
%F{%(?.2.1)}%#%f%b "
  RPS1="%B%F{3}z4h recovery mode%f%b"

  WORDCHARS=''
  ZLE_REMOVE_SUFFIX_CHARS=''
  HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
  HISTSIZE='1000000000'
  SAVEHIST='1000000000'

  'bindkey' '-d'
  'bindkey' '-e'

  'bindkey' '-s' '^[OM' '^M'
  'bindkey' '-s' '^[Ok' '+'
  'bindkey' '-s' '^[Om' '-'
  'bindkey' '-s' '^[Oj' '*'
  'bindkey' '-s' '^[Oo' '/'
  'bindkey' '-s' '^[OX' '='
  'bindkey' '-s' '^[OH' '^[[H'
  'bindkey' '-s' '^[OF' '^[[F'
  'bindkey' '-s' '^[OA' '^[[A'
  'bindkey' '-s' '^[OB' '^[[B'
  'bindkey' '-s' '^[OD' '^[[D'
  'bindkey' '-s' '^[OC' '^[[C'
  'bindkey' '-s' '^[[1~' '^[[H'
  'bindkey' '-s' '^[[4~' '^[[F'

  'bindkey' '-M' 'emacs' '^[[H'    'beginning-of-line'
  'bindkey' '-M' 'viins' '^[[H'    'vi-beginning-of-line'
  'bindkey' '-M' 'vicmd' '^[[H'    'vi-beginning-of-line'
  'bindkey' '-M' 'emacs' '^[[F'    'end-of-line'
  'bindkey' '-M' 'viins' '^[[F'    'vi-end-of-line'
  'bindkey' '-M' 'vicmd' '^[[F'    'vi-end-of-line'
  'bindkey' '-M' 'emacs' '^[[3~'   'delete-char'
  'bindkey' '-M' 'viins' '^[[3~'   'delete-char'
  'bindkey' '-M' 'viins' '^?'      'backward-delete-char'
  'bindkey' '-M' 'emacs' '^[[3;5~' 'kill-word'
  'bindkey' '-M' 'emacs' '^[[3;3~' 'kill-word'
  'bindkey' '-M' 'emacs' '^[k'     'backward-kill-line'
  'bindkey' '-M' 'emacs' '^[K'     'backward-kill-line'
  'bindkey' '-M' 'emacs' '^[j'     'kill-buffer'
  'bindkey' '-M' 'emacs' '^[J'     'kill-buffer'
  'bindkey' '-M' 'viins' '^_'      'undo'
  'bindkey' '-M' 'emacs' '^[\'     'redo'
  'bindkey' '-M' 'viins' '^[\'     'redo'
  'bindkey' '-M' 'emacs' '^[[1;3D' 'backward-word'
  'bindkey' '-M' 'emacs' '^[[1;5D' 'backward-word'
  'bindkey' '-M' 'viins' '^[[1;3D' 'vi-backward-word'
  'bindkey' '-M' 'viins' '^[[1;5D' 'vi-backward-word'
  'bindkey' '-M' 'emacs' '^[[1;3C' 'forward-word'
  'bindkey' '-M' 'emacs' '^[[1;5C' 'forward-word'
  'bindkey' '-M' 'viins' '^[[1;3C' 'vi-forward-word'
  'bindkey' '-M' 'viins' '^[[1;5C' 'vi-forward-word'
fi

if '[' '-n' "${Z4H-}" '-a' "${Z4H_URL-}" '=' 'https://raw.githubusercontent.com/romkatv/zsh4humans/v2' ']' &&
   '[' '-z' "${Z4H##/*}" '-a' '-r' "$Z4H"/romkatv/zsh4humans/main.zsh ']'; then
  if '.' "$Z4H"/romkatv/zsh4humans/main.zsh; then
    'setopt' 'aliases'
    'return'
  fi
  'unset' '_z4h_bootstrap'
else
  _z4h_bootstrap='1'
fi

if '[' '-n' "${_z4h_bootstrap-}" ']'; then
  'unset' '_z4h_bootstrap'
  (
    if '[' '-z' "${Z4H-}" ]; then
      >&2 'printf' '\033[33mz4h\033[0m: missing required parameter: \033[31mZ4H\033[0m\n'
      >&2 'printf' '\n'
      if '[' "${ZDOTDIR:-$HOME}" '=' "$HOME" ']'; then
        >&2 'printf' 'It must be set at the top of \033[4m~/.zshrc\033[0m:\n'
      else
        >&2 'printf' 'It must be set at the top of \033[4;33m"$ZDOTDIR"\033[0;4m/.zshrc\033[0m:\n'
      fi
      >&2 'printf' '\n'
      >&2 'printf' '  \033[32m:\033[0m \033[33m"${Z4H:=${XDG_CACHE_HOME:-$HOME/.cache}/zsh4humans}"\033[0m\n'
      >&2 'printf' '\n'
      >&2 'printf' 'Note: The leading colon (\033[32m:\033[0m) is necessary.\n'
      'exit' '1'
    fi

    if '[' '-n' "${Z4H##/*}" ']'; then
      >&2 'printf' '\033[33mz4h\033[0m: invalid \033[1mZ4H\033[0m parameter: \033[31m%s\033[0m\n' "$Z4H"
      >&2 'printf' '\n'
      if '[' "${ZDOTDIR:-$HOME}" '=' "$HOME" ']'; then
        >&2 'printf' 'It comes from \033[4m~/.zshrc\033[0m. Correct value example:\n'
      else
        >&2 'printf' 'It comes from \033[4;33m"$ZDOTDIR"\033[0;4m/.zshrc\033[0m. Correct value example:\n'
      fi
      >&2 'printf' '\n'
      >&2 'printf' '  \033[32m:\033[0m \033[33m"${Z4H:=${XDG_CACHE_HOME:-$HOME/.cache}/zsh4humans}"\033[0m\n'
      >&2 'printf' '\n'
      >&2 'printf' 'Note: The leading colon (\033[32m:\033[0m) is necessary.\n'
      'exit' '1'
    fi

    if '[' '!' '-r' "$Z4H"/z4h.zsh ']'; then
      >&2 'printf' '\033[33mz4h\033[0m: confusing \033[4mz4h.zsh\033[0m location\n'
      >&2 'printf' '\n'
      if '[' "${ZDOTDIR:-$HOME}" '=' "$HOME" ']'; then
        >&2 'printf' 'Please fix \033[4m~/.zshrc\033[0m. Correct initialization example:\n'
      else
        >&2 'printf' 'Please fix \033[4;33m"$ZDOTDIR"\033[0;4m/.zshrc\033[0m. Correct initialization example:\n'
      fi
      >&2 'printf' '\n'
      >&2 'printf' '  \033[32m:\033[0m \033[33m"${Z4H:=${XDG_CACHE_HOME:-$HOME/.cache}/zsh4humans}"\033[0m\n'
      >&2 'printf' '  \033[32m.\033[0m \033[4;33m"$Z4H"\033[0;4m/z4h.zsh\033[0m || \033[32mreturn\033[0m\n'
      >&2 'printf' '\n'
      >&2 'printf' 'Note: The leading colon (\033[32m:\033[0m) and dot (\033[32m.\033[0m) are necessary.\n'
      'exit' '1'
    fi

    if '[' '-z' "${Z4H_URL-}" ']'; then
      >&2 'printf' '\033[33mz4h\033[0m: missing required parameter: \033[31mZ4H_URL\033[0m\n'
      >&2 'printf' '\n'
      if '[' "${ZDOTDIR:-$HOME}" '=' "$HOME" ']'; then
        >&2 'printf' 'It must be set at the top of \033[4m~/.zshrc\033[0m:\n'
      else
        >&2 'printf' 'It must be set at the top of \033[4;33m"$ZDOTDIR"\033[0;4m/.zshrc\033[0m:\n'
      fi
      >&2 'printf' '\n'
      >&2 'printf' '  \033[32m:\033[0m \033[33m"${Z4H_URL:=https://raw.githubusercontent.com/romkatv/zsh4humans/v2}"\033[0m\n'
      >&2 'printf' '\n'
      >&2 'printf' 'Note: The leading colon (\033[32m:\033[0m) is necessary.\n'
      'exit' '1'
    fi

    v="${Z4H_URL#https://raw.githubusercontent.com/romkatv/zsh4humans/v}"

    if '[' '-z' "$v" '-o' "$v" '=' "$Z4H_URL" ']'; then
      >&2 'printf' '\033[33mz4h\033[0m: invalid \033[1mZ4H_URL\033[0m: \033[31m%s\033[0m\n' "$Z4H_URL"
      >&2 'printf' '\n'
      if '[' "${ZDOTDIR:-$HOME}" '=' "$HOME" ']'; then
        >&2 'printf' 'It comes from \033[4m~/.zshrc\033[0m. Correct value example:\n'
      else
        >&2 'printf' 'It comes from \033[4;33m"$ZDOTDIR"\033[0;4m/.zshrc\033[0m. Correct value example:\n'
      fi
      >&2 'printf' '\n'
      >&2 'printf' '  \033[32m:\033[0m \033[33m"${Z4H_URL:=https://raw.githubusercontent.com/romkatv/zsh4humans/v2}"\033[0m\n'
      >&2 'printf' '\n'
      >&2 'printf' 'Note: The leading colon (\033[32m:\033[0m) is necessary.\n'
      'exit' '1'
    fi

    if '[' "$v" '!=' '2' ']'; then
      >&2 'printf' '\033[33mz4h\033[0m: unexpected major version in \033[1mZ4H_URL\033[0m\n'
      >&2 'printf' '\n'
      >&2 'printf' 'Expected:\n'
      >&2 'printf' '\n'
      >&2 'printf' '  Z4H_URL=\033[33m"%s"\033[0m\n' "https://raw.githubusercontent.com/romkatv/zsh4humans/v2"
      >&2 'printf' '\n'
      >&2 'printf' 'Found:\n'
      >&2 'printf' '\n'
      >&2 'printf' '  Z4H_URL=\033[33m"%s"\033[0m\n' "$Z4H_URL"
      >&2 'printf' '\n'
      >&2 'printf' 'Delete \033[4m%s\033[0m to switch to \033[1mv%s\033[0m.\n' "$Z4H" "$v"
      'exit' '1'
    fi

    >&2 'printf' '\033[33mz4h\033[0m: installing \033[1m%s\033[0m\n' "romkatv/zsh4humans"

    dir="$Z4H"/romkatv/zsh4humans
    url="https://github.com/romkatv/zsh4humans/archive/v$v.tar.gz"

    'command' 'mkdir' '-p' '--' "$Z4H"/romkatv || 'exit'
    if 'command' '-v' 'mktemp' >'/dev/null' 2>&1; then
      tmpdir="$('command' 'mktemp' '-d' "$dir".XXXXXXXXXX)"
    else
      tmpdir="$dir".tmp."$$"
      'command' 'rm' '-rf' '--' "$tmpdir" || 'exit'
      'command' 'mkdir' '--' "$tmpdir"    || 'exit'
    fi

    (
      if '[' '-n' "${ZSH_VERSION-}" ']'; then
        'builtin' 'cd' '-q' '--' "$tmpdir" || 'exit'
      else
        'cd' '--' "$tmpdir"                || 'exit'
      fi

      if 'command' '-v' 'curl' >'/dev/null' 2>&1; then
        err="$('command' 'curl' '-fsSLo' 'snapshot.tar.gz' '--' "$url" 2>&1)"
      elif 'command' '-v' 'wget' >'/dev/null' 2>&1; then
        err="$('command' 'wget' '-O' 'snapshot.tar.gz' '--' "$url" 2>&1)"
      else
        >&2 'printf' '\033[33mz4h\033[0m: please install \033[32mcurl\033[0m or \033[32mwget\033[0m\n'
        'exit' '1'
      fi

      if '[' "$?" '!=' '0' ']'; then
        >&2 'printf' "%s\n" "$err"
        >&2 'printf' '\033[33mz4h\033[0m: failed to download \033[31m%s\033[0m\n' "$url"
        'exit' '1'
      fi

      'command' 'tar' '-xzf' 'snapshot.tar.gz'  || 'exit'
      './'*'-'*'/sc/setup' '-n' "$Z4H"          || 'exit'
      'command' 'rm' '-rf' '--' "$dir"          || 'exit'
      'command' 'mv' '-f' '--' './'*'-'* "$dir" || 'exit'
    )

    ret="$?"
    'command' 'rm' '-rf' '--' "$tmpdir" || 'exit'
    'exit' "$ret"
  ) && '.' "$Z4H"/romkatv/zsh4humans/main.zsh && 'setopt' 'aliases' && 'return'
fi

'[' '-n' "${ZSH_VERSION-}" ']' && 'setopt' 'aliases'

>&2 'printf' '\n'
>&2 'printf' '\033[33mz4h\033[0m: \033[31mcommand failed\033[0m: \033[32m.\033[0m \033[4;33m"$Z4H"\033[0m\033[4m/z4h.zsh\033[0m\n'

'[' '-e' "$Z4H"/tmp/updating ']' && 'return' '1'

>&2 'printf' '\033[33mz4h\033[0m: enabling \033[1mrecovery mode\033[0m\n'
>&2 'printf' '\n'
>&2 'printf' 'See error messages above to identify the culprit.\n'
>&2 'printf' '\n'
>&2 'printf' 'Edit Zsh configuration:\n'
>&2 'printf' '\n'
if [ "${ZDOTDIR:-$HOME}" '=' "$HOME" ]; then
  >&2 'printf' '  \033[32m%s\033[0m \033[4m~/.zshrc\033[0m\n' "${VISUAL:-${EDITOR:-vi}}"
else
  >&2 'printf' '  \033[32m%s\033[0m \033[4;33m"$ZDOTDIR"\033[0;4m/.zshrc\033[0m\n' "${VISUAL:-${EDITOR:-vi}}"
fi
if 'command' '-v' 'zsh' >'/dev/null' 2>&1; then
  >&2 'printf' '\n'
  >&2 'printf' 'Retry Zsh initialization:\n'
  >&2 'printf' '\n'
  >&2 'printf' '  \033[4;32mexec\033[0m \033[32mzsh\033[0m\n'
fi
if '[' '-n' "${ZSH_VERSION-}" ']' && 'command' '-v' 'z4h' >'/dev/null' 2>&1; then
  >&2 'printf' '\n'
  >&2 'printf' 'If errors persist and you are desperate:\n'
  >&2 'printf' '\n'
  >&2 'printf' '  \033[32mz4h\033[0m \033[1mreset\033[0m\n'
fi
if '[' '-n' "$Z4H" '-a' '-z' "${Z4H##/*}" '-a' '-r' "$Z4H"/z4h.zsh ']'; then
  >&2 'printf' '\n'
  >&2 'printf' 'If nothing helps and you are about to give up:\n'
  >&2 'printf' '\n'
  >&2 'printf' '  \033[35m# nuke the entire site from orbit\033[0m\n'
  >&2 'printf' '  \033[4;32msudo\033[0m \033[32mrm\033[0m -rf -- \033[4;33m"%s"\033[0m\n' "$Z4H"
fi
if 'command' '-v' 'curl' >'/dev/null' 2>&1; then
  >&2 'printf' '\n'
  >&2 'printf' 'Give up and start over:\n'
  >&2 'printf' '\n'
  >&2 'printf' '  \033[32msh\033[0m -c \033[33m"\033[0m$(\033[32mcurl\033[0m -fsSL \033[4mhttps://raw.githubusercontent.com/romkatv/zsh4humans/v2/install\033[0m)\033[33m"\033[0m\n'
elif 'command' '-v' 'wget' >'/dev/null' 2>&1; then
  >&2 'printf' '\n'
  >&2 'printf' 'Give up and start over:\n'
  >&2 'printf' '\n'
  >&2 'printf' '  \033[32msh\033[0m -c \033[33m"\033[0m$(\033[32mwget\033[0m -O- \033[4mhttps://raw.githubusercontent.com/romkatv/zsh4humans/v2/install\033[0m)\033[33m"\033[0m\n'
fi

>&2 'printf' '\n'

'return' '1'
