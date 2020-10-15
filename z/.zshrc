autoload -Uz compinit
compinit

setopt alwaystoend noautoremoveslash NO_AUTO_LIST NO_AUTO_MENU NO_AUTO_PARAM_KEYS NO_LIST_BEEP NO_MENU_COMPLETE NO_BASH_AUTO_LIST NO_COMPLETE_IN_WORD NO_LIST_AMBIGUOUS NO_LIST_PACKED NO_LIST_ROWS_FIRST NO_REC_EXACT

zstyle ':completion:*'               completer         "_complete" "_ignored"
zstyle ':completion:*'               matcher-list      "m:{a-z-_}={A-Z_-}" "l:|=* r:|=*"
zstyle ':completion:*'               menu              "no"
zstyle ':completion:*'               verbose           "true"
zstyle ':completion:*'               single-ignored    "show"
#zstyle ':completion:*'               insert-unambiguous "yes"
zstyle ':completion:*:-subscript-:*' tag-order         "indexes parameters"

autoload +X -Uz -- _main_complete _complete _ignored

ZLE_REMOVE_SUFFIX_CHARS=
ZLE_SPACE_SUFFIX_CHARS=

() {
  local f
  for f in _main_complete _complete _ignored compadd; do
    if (( $+functions[$f] )); then
      functions -c -- $f my_orig$f
    else
      function my_orig$f() {
        local func=${(%):-%N}
        builtin ${func#my_orig} "$@"
      }
    fi
    function $f() {
      (( $+my_ident )) || local my_ident
      local func=${(%):-%N}
      {
        print -r -- $func "${(@q-)@}"
        typeset -pm 'PREFIX|IPREFIX|SUFFIX|ISUFFIX|CURRENT|words|curcontext|compstate'
      } | awk '{print "'$my_ident'" $0 }' >>/tmp/log
      if [[ $func == _main_complete ]] && (( my_insert )); then
        compadd -QU -- fake
        compstate[insert]=all
        return
      fi
      my_ident+='  '
      my_orig$func "$@"
      local -i ret=$?
      my_ident[-2,-1]=
      {
        typeset -pm 'ret'
        typeset -pm 'compstate'
        print -r -- ----------------------
      } | awk '{print "'$my_ident'" $0 }' >>/tmp/log
      return ret
    }
  done
}

function my-complete() {
  local ZLE_REMOVE_SUFFIX_CHARS ZLE_SPACE_SUFFIX_CHARS
  unset ZLE_REMOVE_SUFFIX_CHARS ZLE_SPACE_SUFFIX_CHARS
  local buf=$BUFFER
  local -i my_insert=0
  zle expand-or-complete
  if [[ $buf == $BUFFER ]]; then
    my_insert=1
    zle expand-or-complete
    [[ $buf == $BUFFER ]] && return
  fi
  if [[ $LBUFFER == *' ' && $RBUFFER == ' '* ]]; then
    RBUFFER[1]=
  else
    BUFFER=$BUFFER
  fi
}

zle -N my-complete
bindkey '^I' my-complete

rm -f -- /tmp/log
