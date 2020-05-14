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
fpath+=($Z4H/romkatv/zsh4humans/fn $Z4H/fn)

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
    (( ${+_z4h_install_succeeded} )) || {
      print -ru2 -- ${(%):-"%F{3}z4h%f: %F{1}init%f cannot be called before %Binstall%b"}
      return 1
    }
    (( ! ${+_z4h_init_called} )) || {
      print -ru2 ${(%):-"%F{3}z4h%f: %F{1}init%f cannot be called more than once"}
      return 1
    }
    typeset -gri _z4h_init_called=1
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
      -z4h-init
    }
    return
  }

  eval "$_z4h_opt"

  case $ARGC-$1 in
    1-install)
      : ${GITSTATUS_CACHE_DIR=$Z4H/cache/gitstatus}

      {
        if [[ ! -e $Z4H/cache/.last-update-ts ]]; then
          zf_mkdir -p -- $Z4H || return
          print -n >$Z4H/cache/.last-update-ts || return
        elif zstyle -t :z4h: auto-update ask; then
          local days
          if zstyle -s :z4h: auto-update-days days && [[ $dayz == <-> ]]; then
            # Check if update is required.
            local -a last_update_ts
            if zstat -A last_update_ts +mtime -- $Z4H/cache/.last-update-ts 2>/dev/null &&
              (( EPOCHSECONDS - last_update_ts[1] >= 86400 * days )); then
              local REPLY
              {
                read -q ${(%):-"?%F{3}z4h%f: update dependencies? [y/N]: "} && REPLY=y
              } always {
                [[ -w $TTY ]] && print >>$TTY || print -u2
              }
              if [[ $REPLY == y ]]; then
                z4h update
                return
              fi
              print -Pru2 -- "%F{3}z4h%f: type %F{2}z4h%f %Bupdate%b to update"
              print -n >$Z4H/cache/.last-update-ts || return
            fi
          fi
        fi

        # GitHub projects to clone.
        local github_repos=(
          zsh-users/zsh-syntax-highlighting  # https://github.com/zsh-users/zsh-syntax-highlighting
          zsh-users/zsh-autosuggestions      # https://github.com/zsh-users/zsh-autosuggestions
          zsh-users/zsh-completions          # https://github.com/zsh-users/zsh-completions
          romkatv/powerlevel10k              # https://github.com/romkatv/powerlevel10k
          Aloxaf/fzf-tab                     # https://github.com/Aloxaf/fzf-tab
          junegunn/fzf                       # https://github.com/junegunn/fzf
        )

        # Clone or update all repositories.
        local repo have=($Z4H/$^github_repos(N))
        for repo in ${github_repos:|have}; do
          -z4h-clone ${repo#$Z4H} zsh4humans/${repo:t} z4h-stable || return
        done

        if (( ! ${have[(I)*/romkatv/powerlevel10k]} )); then
          print -Pru2 -- "%F{3}z4h%f: fetching %Bgitstatus%b binary"
          GITSTATUS_CACHE_DIR=$GITSTATUS_CACHE_DIR \
            $Z4H/romkatv/powerlevel10k/gitstatus/install -f || return
          zf_mkdir -p -- $Z4H/cache/powerlevel10k/p10k-root
        fi

        if [[ ! -e $Z4H/junegunn/fzf/bin/fzf ]]; then
          print -Pru2 -- "%F{3}z4h%f: fetching %Bfzf%b binary"
          local BASH_SOURCE=($Z4H/junegunn/fzf/install) err
          if ! err=$(emulate sh && set -- --bin && source "${BASH_SOURCE[0]}" 2>&1); then
            print -ru2 -- $err
            return 1
          fi
          if [[ -h $Z4H/junegunn/fzf/bin/fzf ]]; then
            command cp -- $Z4H/junegunn/fzf/bin/fzf $Z4H/junegunn/fzf/bin/fzf.tmp || return
            zf_mv -f -- $Z4H/junegunn/fzf/bin/fzf.tmp $Z4H/junegunn/fzf/bin/fzf || return
          fi
        fi

        path=($Z4H/junegunn/fzf/bin $path)
        fpath+=($Z4H/zsh-users/zsh-completions/src)
        typeset -gri _z4h_install_succeeded=1
      } always {
        (( $? )) && -z4h-error-install
      }
    ;;

    2-clone)
      if [[ -z $2 || $2 != *?/?* || $2 == *:* ]]; then
        print -Pru2 -- "%F{3}z4h%f: %Bclone%b argument must be %Uuser/repo%u: %F{1}${2//\%/%%}%f"
        return 1
      fi
      if (( ! $+_z4h_install_succeeded )); then
        print -Pru2 -- "%F{3}z4h%f: %F{1}clone%f cannot be called before %Binstall%b"
        return 1
      fi
      if (( $+_z4h_init_called )); then
        print -Pru2 -- "%F{3}z4h%f: %F{1}clone%f cannot be called after %Binit%b"
        return 1
      fi
      [[ ! -d $Z4H/$2 ]] || -z4h-clone $2 $2 master
      return
    ;;

    1-chsh)   -z4h-chsh;;
    <2->-ssh) -z4h-ssh "${@:2}";;
    1-update) -z4h-update;;
    1-reset)  -z4h-reset;;
    *)        -z4h-help "$@";;
  esac
}
