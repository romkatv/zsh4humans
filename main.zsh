if '[' '-z' "${ZSH_VERSION-}" ']' || ! 'eval' '[[ "$ZSH_VERSION" == (5.<8->*|<6->.*) ]]'; then
  '.' "$Z4H"/zsh4humans/sc/exec-zsh-i || 'return'
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

if ! { zmodload zsh/terminfo zsh/zselect && (( $#terminfo )) ||
       [[ $ZSH_PATCHLEVEL == zsh-5.8-0-g77d203f && $_z4h_exe == */bin/zsh &&
          -e ${_z4h_exe:h:h}/share/zsh/5.8/scripts/relocate ]] } 2>/dev/null; then
  builtin source $Z4H/zsh4humans/sc/exec-zsh-i || return
fi

if [[ ! -o interactive ]]; then
  # print -Pru2 -- "%F{3}z4h%f: starting interactive %F{2}zsh%f"
  # This is caused by Z4H_BOOTSTRAPPING, so we don't need to consult ZSH_SCRIPT and the like.
  exec -- $_z4h_exe -i || return
fi

typeset -gr _z4h_opt='emulate -L zsh &&
  setopt typeset_silent pipe_fail extended_glob prompt_percent no_prompt_subst &&
  setopt no_prompt_bang no_bg_nice no_aliases'

zmodload zsh/{datetime,langinfo,parameter,stat,system,terminfo,zutil} || return
zmodload -F zsh/files b:{zf_mkdir,zf_mv,zf_rm,zf_rmdir,zf_ln}         || return

() {
  if [[ $1 != $Z4H/zsh4humans/main.zsh ]]; then
    print -Pru2 -- "%F{3}z4h%f: confusing %Umain.zsh%u location: %F{1}${1//\%/%%}%f"
    return 1
  fi
  typeset -gr _z4h_param_pat=$'ZDOTDIR=$ZDOTDIR\0Z4H=$Z4H\0Z4H_URL=$Z4H_URL'
  typeset -gr _z4h_param_sig=${(e)_z4h_param_pat}
} ${${(%):-%x}:a} || return

function -z4h-check-core-params() {
  [[ "${(e)_z4h_param_pat}" == "$_z4h_param_sig" ]] || {
    -z4h-error-param-changed
    return 1
  }
}

export -T MANPATH=${MANPATH:-:} manpath
export -T INFOPATH=${INFOPATH:-:} infopath
typeset -gaU cdpath fpath mailpath path manpath infopath

fpath=(
  ${^${(M)fpath:#*/$ZSH_VERSION/functions}/%$ZSH_VERSION\/functions/site-functions}(FN)
  ${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/share/zsh/site-functions}(FN)
  /usr{/local,}/share/zsh/{site-functions,vendor-completions}(FN)
  $fpath
  $Z4H/zsh4humans/fn)

autoload -Uz -- $Z4H/zsh4humans/fn/(|-|_)z4h[^.]#(:t) || return
functions -Ms _z4h_err

if [[ $OSTYPE == darwin* ]]; then
  if [[ ! -e $Z4H/cache/init-darwin-paths ]] || ! source $Z4H/cache/init-darwin-paths; then
    -z4h-gen-init-darwin-paths && source $Z4H/cache/init-darwin-paths
  fi
fi

path+=($Z4H/fzf/bin)
manpath=($manpath $Z4H/fzf/man '')
[[ $commands[zsh] == $_z4h_exe ]] || path=(${_z4h_exe:h} $path)

: ${GITSTATUS_CACHE_DIR=$Z4H/cache/gitstatus}
: ${ZSH=$Z4H/ohmyzsh/ohmyzsh}
: ${ZSH_CUSTOM=$Z4H/ohmyzsh/ohmyzsh/custom}
: ${ZSH_CACHE_DIR=$Z4H/cache/ohmyzsh}

if [[ $OSTYPE == linux* && -z $HOMEBREW_PREFIX ]]; then
  () {
    local -aU dir=(/home/linuxbrew/.linuxbrew(-/N) ~/.linuxbrew(-/N))
    (( $#dir == 1 )) || return
    export HOMEBREW_PREFIX=$dir
    export HOMEBREW_CELLAR=$dir/Cellar
    export HOMEBREW_REPOSITORY=$dir/Homebrew
    (( ${path[(Ie)$dir/sbin]}           )) || path=($dir/sbin $path)
    (( ${path[(Ie)$dir/bin]}            )) || path=($dir/bin $path)
    (( ${manpath[(Ie)$dir/share/man]}   )) || manpath=($dir/share/man $manpath '')
    (( ${infopath[(Ie)$dir/share/info]} )) || infopath=($dir/share/info $infopath '')
  }
fi

() {
  path=(${@:|path} $path)
} {~/bin,~/.local/bin,~/.cargo/bin,/usr/local/bin,/snap/bin}(-/N)

if [[ $ZSH_PATCHLEVEL == zsh-5.8-0-g77d203f && $_z4h_exe == */bin/zsh &&
      -e ${_z4h_exe:h:h}/share/zsh/5.8/scripts/relocate ]]; then
  if [[ $TERMINFO != ~/.terminfo && $TERMINFO != ${_z4h_exe:h:h}/share/terminfo &&
        -e ${_z4h_exe:h:h}/share/terminfo/$TERM[1]/$TERM ]]; then
    export TERMINFO=${_z4h_exe:h:h}/share/terminfo
  fi
  if [[ -e ${_z4h_exe:h:h}/share/man ]]; then
    manpath=(${_z4h_exe:h:h}/share/man $manpath '')
  fi
fi

[[ $terminfo[Tc] == yes && -z $COLORTERM ]] && export COLORTERM=truecolor

if [[ $EUID == 0 && -z ~(#qNU) && $Z4H == ~/* ]]; then
  typeset -gri _z4h_dangerous_root=1
else
  typeset -gri _z4h_dangerous_root=0
fi

function compinit() {}

function compdef() {
  eval "$_z4h_opt"
  _z4h_compdef+=("${(pj:\0:)@}")
}

function -z4h-cmd-source() {
  local file compile
  zparseopts -D -F -- c=compile -compile=compile || return '_z4h_err()'
  emulate zsh -o extended_glob -c 'local files=(${^@}(N))'
  builtin set --
  for file in "${files[@]}"; do
    if (( ${#compile} )); then
      -z4h-compile "$file" || true
    else
      [[ ! -e "$file".zwc ]] || zf_rm -f -- "$file".zwc || true
    fi
    builtin source -- "$file"
  done
}

function -z4h-cmd-init() {
  if (( ARGC )); then
    print -ru2 -- ${(%):-"%F{3}z4h%f: unexpected %F{1}init%f argument"}
    return '_z4h_err()'
  fi
  if (( ${+_z4h_init_called} )); then
    if [[ ${funcfiletrace[-1]} != zsh:0 ]]; then
      if '[' "${ZDOTDIR:-$HOME}" '=' "$HOME" ']'; then
        >&2 'printf' '\033[33mz4h\033[0m: please use \033[4;32mexec\033[0m \033[32mzsh\033[0m instead of \033[32msource\033[0m \033[4m~/.zshrc\033[0m\n'
      else
        >&2 'printf' '\033[33mz4h\033[0m: please use \033[4;32mexec\033[0m \033[32mzsh\033[0m instead of \033[32msource\033[0m \033[4;33m"$ZDOTDIR"\033[0;4m/.zshrc\033[0m\n'
      fi
      'return' '1'
    fi
    print -ru2 -- ${(%):-"%F{3}z4h%f: %F{1}init%f cannot be called more than once"}
    return '_z4h_err()'
  fi
  -z4h-check-core-params || return
  typeset -gri _z4h_init_called=1

  () {
    eval "$_z4h_opt"

    [[ $MACHTYPE != x86_64 || $OSTYPE != (linux|darwin)* ]] ||
      ! zstyle -T :z4h start-tmux integrated
    local -i install_tmux=$? need_restart

    if (( $+ZSH_SCRIPT || $+ZSH_EXECUTION_STRING )) || ! [[ -o zle && -t 0 && -t 1 && -t 2 ]]; then
      unset _Z4H_TMUX _Z4H_TMUX_CMD
    else
      if [[ $USES_VSCODE_SERVER_SPAWN == true && $TERM == xterm-256color ]]; then
        unset _Z4H_TMUX _Z4H_TMUX_CMD
      fi
      local tmux=$Z4H/tmux/bin/tmux
      local -a match mbegin mend
      if [[ $TMUX == (#b)(/*),(|<->),(|<->) && -w $match[1] ]]; then
        if [[ $TMUX == */z4h-tmux-* ]]; then
          export _Z4H_TMUX=$TMUX
          export _Z4H_TMUX_CMD=$tmux
          unset TMUX TMUX_PANE
        elif [[ -x /proc/$match[2]/exe ]]; then
          export _Z4H_TMUX=$TMUX
          export _Z4H_TMUX_CMD=/proc/$match[2]/exe
        elif (( $+commands[tmux] )); then
          export _Z4H_TMUX=$TMUX
          export _Z4H_TMUX_CMD=$commands[tmux]
        else
          unset _Z4H_TMUX _Z4H_TMUX_CMD
        fi
        if [[ -n $_Z4H_TMUX && -t 1 ]] && zstyle -T :z4h prompt-position bottom; then
          local cursor_y cursor_x
          -z4h-get-cursor-pos || return
          local -i n=$((LINES - cursor_y))
          print -rn -- ${(pl:$n::\n:)}
        fi
      elif (( install_tmux )) &&
           [[ -z $TMUX && ! -w ${_Z4H_TMUX%,(|<->),(|<->)} && -z $Z4H_SSH ]]; then
        unset _Z4H_TMUX _Z4H_TMUX_CMD TMUX TMUX_PANE
        if [[ -x $tmux && -d $Z4H/terminfo ]]; then
          local sock
          if [[ -n $TMUX_TMPDIR && -d $TMUX_TMPDIR && -w $TMUX_TMPDIR ]]; then
            sock=$TMUX_TMPDIR
          elif [[ -n $TMPDIR && -d $TMPDIR && -w $TMPDIR ]]; then
            sock=$TMPDIR
          elif [[ -d /tmp && -w /tmp ]]; then
            sock=/tmp
          fi
          if [[ -n $sock ]]; then
            sock=${sock%/}/z4h-tmux-$UID-$TERM
            if (( terminfo[colors] < 256 )); then
              local cfg=tmux-16color.conf
            elif [[ $COLORTERM == (24bit|truecolor) ]]; then
              local cfg=tmux-truecolor.conf
            else
              local cfg=tmux-256color.conf
            fi
            SHELL=$_z4h_exe exec $tmux -u -S $sock -f $Z4H/zsh4humans/$cfg || return
          fi
        else
          need_restart=1
        fi
      fi
    fi

    if [[ ( -x /usr/lib/systemd/systemd || -x /lib/systemd/systemd ) &&
          -z ${^fpath}/_systemctl(#qN) ]]; then
      _z4h_install_queue+=(systemd)
    fi
    _z4h_install_queue+=(
      zsh-autosuggestions zsh-completions zsh-syntax-highlighting terminfo fzf powerlevel10k)
    (( install_tmux )) && _z4h_install_queue+=(tmux)
    if ! -z4h-install-many; then
      [[ -e $Z4H/.updating ]] || -z4h-error-command init
      return 1
    fi
    if (( _z4h_installed_something )); then
      if [[ $TERMINFO != ~/.terminfo && -e ~/.terminfo/$TERM[1]/$TERM ]]; then
        export TERMINFO=~/.terminfo
      fi
      if (( need_restart )); then
        print -ru2 ${(%):-"%F{3}z4h%f: restarting %F{2}zsh%f"}
        exec -- $_z4h_exe -i || return
      else
        print -ru2 ${(%):-"%F{3}z4h%f: initializing %F{2}zsh%f"}
        export P9K_TTY=old
      fi
    fi

    if [[ -w $TTY && (-n $Z4H_SSH && -n $_Z4H_SSH_MARKER || -n $_Z4H_TMUX) ]]; then
      typeset -gri _z4h_can_save_restore_screen=1  # this parameter is read by p10k
    else
      typeset -gri _z4h_can_save_restore_screen=0  # this parameter is read by p10k
    fi
  } || return

  # Enable Powerlevel10k instant prompt.
  zstyle -t :z4h:powerlevel10k channel none || () {
    local user=${(%):-%n}
    local XDG_CACHE_HOME=$Z4H/cache/powerlevel10k
    [[ -r $XDG_CACHE_HOME/p10k-instant-prompt-$user.zsh ]] || return 0
    builtin source $XDG_CACHE_HOME/p10k-instant-prompt-$user.zsh
  }

  () {
    eval "$_z4h_opt"
    -z4h-init && return
    [[ -e $Z4H/.updating ]] || -z4h-error-command init
    return 1
  }
}

function -z4h-cmd-install() {
  eval "$_z4h_opt"
  -z4h-check-core-params || return

  local -a flush
  zparseopts -D -F -- f=flush -flush=flush || return '_z4h_err()'

  local invalid=("${@:#([^/]##/)##[^/]##}")
  if (( $#invalid )); then
    print -Pru2 -- '%F{3}z4h%f: %Binstall%b: invalid project name(s)'
    print -Pru2 -- ''
    print -Prlu2 -- '  %F{1}'${(q)^invalid//\%/%%}'%f'
    return 1
  fi
  _z4h_install_queue+=("$@")
  (( $#flush && $#_z4h_install_queue )) || return 0
  -z4h-install-many && return
  -z4h-error-command install
  return 1
}

# Main zsh4humans function. Type `z4h help` for usage.
function z4h() {
  if (( ${+functions[-z4h-cmd-${1-}]} )); then
    -z4h-cmd-"$1" "${@:2}"
  else
    -z4h-cmd-help >&2
    return 1
  fi
}

[[ ${Z4H_SSH-} != <1->:* ]] || -z4h-ssh-maybe-update || return

typeset -gr _z4h_orig_shell=${SHELL-}

(( !EUID || $+Z4H_SSH ))                                                                 ||
  ! zstyle -T :z4h: chsh                                                                 ||
  [[ ${SHELL-} == $_z4h_exe || ${SHELL-} -ef $_z4h_exe || -e $Z4H/stickycache/no-chsh ]] ||
  -z4h-chsh                                                                              ||
  true
