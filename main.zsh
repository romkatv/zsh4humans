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

if ! { zmodload -s zsh/terminfo zsh/zselect ||
       [[ $ZSH_PATCHLEVEL == zsh-5.8-0-g77d203f && $_z4h_exe == */bin/zsh &&
          -e ${_z4h_exe:h:h}/share/zsh/5.8/scripts/relocate ]] }; then
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

function -z4h-init-homebrew() {
  (( ARGC )) || return 0
  local dir=${1:h:h}
  export HOMEBREW_PREFIX=$dir
  export HOMEBREW_CELLAR=$dir/Cellar
  export HOMEBREW_REPOSITORY=$dir/Homebrew
}

if [[ $OSTYPE == darwin* ]]; then
  if [[ ! -e $Z4H/cache/init-darwin-paths ]] || ! source $Z4H/cache/init-darwin-paths; then
    autoload -Uz $Z4H/zsh4humans/fn/-z4h-gen-init-darwin-paths
    -z4h-gen-init-darwin-paths && source $Z4H/cache/init-darwin-paths
  fi
  [[ -z $HOMEBREW_PREFIX ]] && -z4h-init-homebrew {/opt/homebrew,/usr/local}/bin/brew(N)
elif [[ $OSTYPE == linux* && -z $HOMEBREW_PREFIX ]]; then
  -z4h-init-homebrew {/home/linuxbrew/.linuxbrew,~/.linuxbrew}/bin/brew(N)
fi

fpath=(
  ${^${(M)fpath:#*/$ZSH_VERSION/functions}/%$ZSH_VERSION\/functions/site-functions}(-/N)
  ${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/share/zsh/site-functions}(-/N)
  /opt/homebrew/share/zsh/site-functions(-/N)
  /usr{/local,}/share/zsh/{site-functions,vendor-completions}(-/N)
  $fpath
  $Z4H/zsh4humans/fn)

autoload -Uz -- $Z4H/zsh4humans/fn/(|-|_)z4h[^.]#(:t) || return
functions -Ms _z4h_err

path+=($Z4H/fzf/bin)
manpath=($manpath $Z4H/fzf/man '')

() {
  path=(${@:|path} $path)
} {~/bin,~/.local/bin,~/.cargo/bin,${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/bin},${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/sbin},/opt/local/sbin,/opt/local/bin,/usr/local/sbin,/usr/local/bin,/snap/bin}(-/N)

() {
  manpath=(${@:|manpath} $manpath '')
} {${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/share/man},/opt/local/share/man}(-/N)

() {
  infopath=(${@:|infopath} $infopath '')
} {${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/share/info},/opt/local/share/info}(-/N)

[[ $commands[zsh] == $_z4h_exe ]] || path=(${_z4h_exe:h} $path)

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

: ${GITSTATUS_CACHE_DIR=$Z4H/cache/gitstatus}
: ${ZSH=$Z4H/ohmyzsh/ohmyzsh}
: ${ZSH_CUSTOM=$Z4H/ohmyzsh/ohmyzsh/custom}
: ${ZSH_CACHE_DIR=$Z4H/cache/ohmyzsh}

[[ $terminfo[Tc] == yes && -z $COLORTERM ]] && export COLORTERM=truecolor

if [[ $EUID == 0 && -z ~(#qNU) && $Z4H == ~/* ]]; then
  typeset -gri _z4h_dangerous_root=1
else
  typeset -gri _z4h_dangerous_root=0
fi

[[ $langinfo[CODESET] == (utf|UTF)(-|)8 ]] || -z4h-fix-locale

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

    local -a start_tmux
    # 'integrated', 'system', or 'command' <cmd> [arg]...
    zstyle -a :z4h: start-tmux start_tmux || start_tmux=(integrated)
    local -i install_tmux need_restart
    if (( $#start_tmux == 1 )); then
      case $start_tmux[1] in
        integrated) install_tmux=1;;
        system)     start_tmux=(command tmux -u);;
      esac
    fi

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
        if [[ -n $_Z4H_TMUX && -t 1 ]] && zstyle -T :z4h: prompt-at-bottom; then
          local cursor_y cursor_x
          -z4h-get-cursor-pos || return
          local -i n=$((LINES - cursor_y))
          print -rn -- ${(pl:$n::\n:)}
        fi
      elif (( install_tmux )) &&
           [[ -z $TMUX && ! -w ${_Z4H_TMUX%,(|<->),(|<->)} && -z $Z4H_SSH ]]; then
        unset _Z4H_TMUX _Z4H_TMUX_CMD TMUX TMUX_PANE
        if [[ -x $tmux && -d $Z4H/terminfo ]]; then
          # We prefer /tmp over $TMPDIR because the latter breaks the rendering
          # of wide chars on iTerm2.
          local sock
          if [[ -n $TMUX_TMPDIR && -d $TMUX_TMPDIR && -w $TMUX_TMPDIR ]]; then
            sock=$TMUX_TMPDIR
          elif [[ -d /tmp && -w /tmp ]]; then
            sock=/tmp
          elif [[ -n $TMPDIR && -d $TMPDIR && -w $TMPDIR ]]; then
            sock=$TMPDIR
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
            SHELL=$_z4h_exe exec - $tmux -u -S $sock -f $Z4H/zsh4humans/$cfg || return
          fi
        else
          need_restart=1
        fi
      elif [[ -z $TMUX && $start_tmux[1] == command ]] && (( $+commands[$start_tmux[2]] )); then
        if [[ -d $Z4H/terminfo ]]; then
          SHELL=$_z4h_exe exec - ${start_tmux:1} || return
        else
          need_restart=1
        fi
      fi
    fi

    if [[ ( -x /usr/lib/systemd/systemd || -x /lib/systemd/systemd ) &&
          -z ${^fpath}/_systemctl(#qN) ]]; then
      _z4h_install_queue+=(systemd)
    fi
    local brew
    if [[ -v commands[brew] &&
          -n $HOMEBREW_REPOSITORY &&
          ! -e $HOMEBREW_REPOSITORY/Library/Taps/homebrew/homebrew-command-not-found/cmd/which-formula.rb ]]; then
      brew=homebrew-command-not-found
    fi
    _z4h_install_queue+=(
      zsh-history-substring-search zsh-autosuggestions zsh-completions
      zsh-syntax-highlighting terminfo fzf $brew powerlevel10k)
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

(( _z4h_dangerous_root || $+Z4H_SSH ))                                                   ||
  ! zstyle -T :z4h: chsh                                                                 ||
  [[ ${SHELL-} == $_z4h_exe || ${SHELL-} -ef $_z4h_exe || -e $Z4H/stickycache/no-chsh ]] ||
  -z4h-chsh                                                                              ||
  true
