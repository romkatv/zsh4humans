if '[' '-z' "${ZSH_VERSION-}" ']' || ! 'eval' '[[ "$ZSH_VERSION" == (5.<4->*|<6->.*) ]]'; then
  '.' "$Z4H"/romkatv/zsh4humans/sc/exec-zsh-i || 'return'
fi

() {
  if [[ -x /proc/self/exe ]]; then
    local exe=/proc/self/exe
  else
    emulate zsh -o posix_argzero -c 'local exe=${0#-}'
    if [[ $SHELL == /* && ${SHELL:t} == $exe && -x $SHELL ]]; then
      exe=$SHELL
    elif (( $+commands[$exe] )); then
      exe=$commands[$exe]
    elif [[ -x $exe ]]; then
      exe=${exe:a}
    else
      print -Pru2 -- "%F{3}z4h%f: unable to find path to %F{1}zsh%f"
      return 1
    fi
  fi
  typeset -gr _z4h_exe=${exe:A}
}

if [[ ! -o interactive ]]; then
  print -Pru2 -- "%F{3}z4h%f: starting interactive %F{2}zsh%f"
  exec -- $_z4h_exe -i || return
fi

typeset -gr _z4h_opt='emulate -L zsh &&
  setopt typeset_silent pipe_fail extended_glob prompt_percent no_prompt_subst &&
  setopt no_prompt_bang no_bg_nice no_aliases'

zmodload zsh/{datetime,langinfo,parameter,stat,system,terminfo,zutil} || return
zmodload -F zsh/files b:{zf_mkdir,zf_mv,zf_rm}                        || return

() {
  local zshrc=${funcsourcetrace[-1]%:<->}
  if [[ $zshrc != */.zshrc ]]; then
    print -Pru2 -- "%F{3}z4h%f: confusing config origin: %F{1}${zshrc//\%/%%}%f"
    return 1
  fi
  if [[ $1 != $Z4H/romkatv/zsh4humans/main.zsh ]]; then
    print -Pru2 -- "%F{3}z4h%f: confusing %Umain.zsh%u location: %F{1}${1//\%/%%}%f"
    return 1
  fi
  local zdotdir=${ZDOTDIR:-~}
  typeset -g ZDOTDIR=${zshrc:h}
  if [[ $ZDOTDIR != $zdotdir ]]; then
    local home=~
    print -Pru2 -- "%F{3}z4h%f: changing %BZDOTDIR%b to %U${${${(q)ZDOTDIR}/#${(q)home}/~}//\%/%%}%u"
  fi
  typeset -gr _z4h_param_pat=$'ZDOTDIR=$ZDOTDIR\0Z4H=$Z4H\0Z4H_URL=$Z4H_URL'
  typeset -gr _z4h_param_sig=${(e)_z4h_param_pat}
} ${${(%):-%x}:a} || return

typeset -gaU cdpath fpath mailpath path
[[ $commands[zsh] == $_z4h_exe ]] || path=(${_z4h_exe:h} $path)
path=($Z4H/bin $Z4H/junegunn/fzf/bin $path)
fpath+=($Z4H/romkatv/zsh4humans/fn $Z4H/fn $Z4H/zsh-users/zsh-completions/src)

: ${GITSTATUS_CACHE_DIR=$Z4H/cache/gitstatus}

autoload -Uz -- $Z4H/romkatv/zsh4humans/fn/[^_]*(:t) || return

function compinit() {}

function compdef() {
  emulate -L zsh
  _z4h_compdef+=("${(pj:\0:)@}")
}

# Main zsh4humans function. Type `z4h help` for usage.
function z4h() {
  [[ "$ARGC-$1" != 2-source ]] || {
    [[ -e "$2" ]] || return
    [[ "$2".zwc -nt "$2" ]] || -z4h-compile "$2" || true
    local file="$2"
    set --
    source -- "$file"
    return
  }

  [[ "${(e)_z4h_param_pat}" == "$_z4h_param_sig" ]] || {
    eval "$_z4h_opt"
    -z4h-error-param-changed
    return 1
  }

  [[ "$ARGC-$1" != 1-init ]] || {
    (( ! ${+_z4h_init_called} )) || {
      print -ru2 ${(%):-"%F{3}z4h%f: %F{1}init%f cannot be called more than once"}
      return 1
    }
    typeset -gri _z4h_init_called=1
    _z4h_install_queue+=(
      zsh-users/zsh-completions
      zsh-users/zsh-autosuggestions
      zsh-users/zsh-syntax-highlighting
      junegunn/fzf
      Aloxaf/fzf-tab
      romkatv/powerlevel10k)
    if ! -z4h-install-many; then
      -z4h-error-command init
      return 1
    fi
    # Enable Powerlevel10k instant prompt.
    () {
      local user=${(%):-%n}
      local XDG_CACHE_HOME=$Z4H/cache/powerlevel10k
      [[ -r $XDG_CACHE_HOME/p10k-instant-prompt-$user.zsh ]] || return 0
      [[ -e $XDG_CACHE_HOME/p10k-root ]] || zf_mkdir -p -- $XDG_CACHE_HOME/p10k-root 2>/dev/null
      source $XDG_CACHE_HOME/p10k-instant-prompt-$user.zsh
    }
    () {
      eval "$_z4h_opt"
      -z4h-init && return
      -z4h-error-command init
      return 1
    }
    return
  }

  eval "$_z4h_opt"

  case $ARGC-$1 in
    <->-install)
      local -i flush OPTIND
      local opt OPTARG
      shift
      while getopts ':f' opt "$@"; do
        case $opt in
          f)  flush=1;;
          +f) flush=0;;
          *) -z4h-error-bad-opt '%Binstall%b'; return 1;;
        esac
      done
      shift $((OPTIND-1))
      local invalid=("${@:#([^/]##/)##[^/]##}")
      if (( $#invalid )); then
        print -Pru2 -- '%F{3}z4h%f: %Binstall%b: invalid project name(s)'
        print -Pru2 -- ''
        print -Prlu2 -- '  %F{1}'${(q)^invalid//\%/%%}'%f'
        return 1
      fi
      _z4h_install_queue+=("$@")
      (( flush && $#_z4h_install_queue )) || return 0
      -z4h-install-many && return
      -z4h-error-command install
      return 1
    ;;

    1-chsh)   -z4h-chsh;;
    # <2->-ssh) -z4h-ssh "${@:2}";;
    1-update) -z4h-update;;
    *)        -z4h-help "$@";;
  esac
}
