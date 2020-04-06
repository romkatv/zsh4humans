# z4h_prelude check if the current shell is Zsh >= 5.4. If not, it replaces
# the current process with Zsh >= 5.4. If there is no Zsh >= 5.4, z4h_prelude
# installs the latest version to ~/.zsh-bin.
z4h_prelude() {
  local v="${ZSH_VERSION-}"
  local v1="${v%%.*}"
  local v2="${v#*.}"
  v2="${v2%%.*}"
  if [ -n "$v1" -a -n "$v2" ]; then
    if [ "$v1" -eq 5 -a "$v2" -ge 4 -o "$v1" -gt 5 ]; then
      if [[ -o interactive ]]; then
        # The current interpreter is interactive Zsh >= 5.4. Proceed with initialization.
        set +ue
        return 0
      fi
      # The current interpreter is non-interactive Zsh >= 5.4. Need to execute interactive.
      # Will continue below. It's more convenient because we know we are in Zsh.
      return 2
    fi
  fi
  if ! command -v zsh >/dev/null 2>&1 || ! zsh -fc '[[ $ZSH_VERSION == (5.<4->*|<6->.*) ]]'; then
    if [ ! -d ~/.zsh-bin ]; then
      # There is no suitable Zsh. Install the latest version to ~/.zsh-bin.
      local install zsh_url='https://raw.githubusercontent.com/romkatv/zsh-bin/master/install'
      if command -v curl >/dev/null 2>&1; then
        install="$(curl -fsSL -- "$zsh_url")" || return 1
      elif command -v wget >/dev/null 2>&1; then
        install="$(wget -O- -- "$zsh_url")"   || return 1
      else
        >&2 echo 'z4h: please install `curl` or `wget`'
        return 1
      fi
      >&2 echo 'z4h: installing zsh to ~/.zsh-bin'
      ( set -- -q; eval "$install" ) || return 1
    fi
    export PATH="$HOME/.zsh-bin/bin:$PATH"
  fi
  # The current interpreter is not Zsh >= 5.4. Execute Zsh >= 5.4.
  exec zsh -i || return 1
}

z4h_prelude
_z4h_prelude_status=$?
unset -f z4h_prelude
[ $_z4h_prelude_status = 1 ] && return 1

if (( ${+functions[z4h]} )); then
  print -ru2 -- ${(%):-"%F{3}z4h%f: please use %F{2}%Uexec%u zsh%f instead of %F{2}source%f %U~/.zshrc%u"}
  unset _z4h_prelude_status
  return 1
fi

emulate zsh

if (( ! $+_z4h_exe )); then
  if [[ -x /proc/self/exe ]]; then
    _z4h_exe=/proc/self/exe
  else
    emulate zsh -o posix_argzero -c 'typeset -g _z4h_exe=${0#-}'
    if [[ $SHELL == /* && ${SHELL:t} == $_z4h_exe && -x $SHELL ]]; then
      _z4h_exe=$SHELL
    elif (( $+commands[$_z4h_exe] )); then
      _z4h_exe=$commands[$_z4h_exe]
    elif [[ -x $_z4h_exe ]]; then
      _z4h_exe=${_z4h_exe:a}
    else
      print -Pru2 -- "%F{3}z4h%f: %F{1}unable to find path to zsh%f"
      return 1
    fi
  fi
  typeset -gr _z4h_exe=${_z4h_exe:A}
fi

if (( _z4h_prelude_status == 2 )); then
  exec -- $_z4h_exe -i || return
else
  unset _z4h_prelude_status
fi

zmodload zsh/zutil || return

() {
  emulate -L zsh -o extended_glob -o prompt_percent -o no_prompt_subst -o no_prompt_bang
  if [[ -n $ZDOTDIR && $ZDOTDIR != /* ]]; then
    print -Pru2 -- "%F{3}z4h%f: invalid %BZDOTDIR%b: %F{1}${ZDOTDIR//\%/%%}%f"
    return 1
  fi
  if [[ $Z4H != /* ]]; then
    print -Pru2 -- "%F{3}z4h%f: invalid %BZ4H%b: %F{1}${Z4H//\%/%%}%f"
    return 1
  fi
  if [[ $1 != $Z4H/z4h.zsh ]]; then
    print -Pru2 -- "%F{3}z4h%f: confusing %Uz4h.zsh%u location: %F{1}${1//\%/%%}%f"
    return 1
  fi
  if [[ $Z4H_URL != https://raw.githubusercontent.com/*/zsh4humans/v[^/]##* ]]; then
    print -Pru2 -- "%F{3}z4h%f: invalid %BZ4H_URL%b: %F{1}${Z4H_URL//\%/%%}%f"
    return 1
  fi

  : ${ZDOTDIR:=~}
  typeset -gr _z4h_param_pat=$'ZDOTDIR=$ZDOTDIR\0Z4H=$Z4H\0Z4H_URL=$Z4H_URL'
  typeset -gr _z4h_param_sig=${(e)_z4h_param_pat}
} ${${(%):-%x}:a} || return 1

typeset -gaU cdpath fpath mailpath path
[[ $commands[zsh] == $_z4h_exe ]] || path=(${_z4h_exe:h} $path)

function _z4h_clone() {
  [[ -d $1 && $Z4H_UPDATE == 0 ]] && return

  local dst=$1
  local repo=$2
  local branch=$3
  if [[ -d $dst/.git && $+commands[git] == 1 ]]; then
    print -Pru2 -- "%F{3}z4h%f: updating %B${repo//\%/%%}%b"
    >&2 git -C $dst pull || return
  elif (( $+commands[git] )); then
    print -Pru2 -- "%F{3}z4h%f: cloning %B${repo//\%/%%}%b"
    zmodload -F zsh/files b:zf_rm b:zf_mv || return
    local old=$dst.old.$$
    local new=$dst.new.$$
    {
      local err
      if ! err=$(git clone -b $branch --depth=1 -- https://github.com/$repo.git $new 2>&1); then
        print -ru2 -- "$err"
        return 1
      fi
      [[ ! -e $dst ]] || zf_mv -- $dst $old || return
      zf_mv -- $new $dst
    } always {
      rm -rf -- $old $new
    }
  else
    print -Pru2 -- "%F{3}z4h%f: downloading %B${repo//\%/%%}%b"
    zmodload -F zsh/files b:zf_mkdir b:zf_rm b:zf_mv || return
    local old=$dst.old.$$
    local new=$dst.new.$$
    {
      zf_mkdir -p -- ${dst:h} $new
      local url=https://github.com/$repo/archive/$branch.tar.gz
      local err
      if (( $+commands[curl] )); then
        err="$(curl -fsSLo $new/dump.tar.gz -- $url 2>&1)"
      elif (( $+commands[wget] )); then
        err="$(wget -qO $new/dump.tar.gz -- $url 2>&1)"
      else
        print -Pru2 -- "%F{3}z4h%f: please install %F{1}git%f, %F{1}curl%f or %F{1}wget%f"
        return 1
      fi
      if (( $? )); then
        print -ru2 -- $err
        print -Pru2 -- "%F{3}z4h%f: failed to download %F{1}${url//\%/%%}%f"
        return 1
      fi
      ( cd -- $new && tar -xzf dump.tar.gz ) || return
      local dirs=($new/${repo:t}-*(N/))
      if (( $#dirs != 1 )); then
        print -Pru2 -- "%F{3}z4h%f: invalid content: %F{1}${url//\%/%%}%f"
        return 1
      fi
      [[ ! -e $dst ]] || zf_mv -- $dst $old || return
      zf_mv -- $dirs[1] $dst
    } always {
      zf_rm -rf -- $old $new
    }
  fi
}

function _z4h_compile() {
  [[ "$1".zwc -nt "$1" ]] && return
  [[ -w "${1:h}"       ]] || return
  zmodload zsh/system                   || return
  zmodload -F zsh/files b:zf_mv b:zf_rm || return
  local tmp="$1".tmp."${sysparams[pid]}".zwc
  {
    # This zf_rm is to work around bugs in NTFS and/or WSL. The following code fails there:
    #
    #   touch a b
    #   chmod -w b
    #   zf_rm -f a b
    #
    # The last command produces this error:
    #
    #   zf_mv: a: permission denied
    zcompile -R -- "$tmp" "$1" && zf_rm -f -- "$1".zwc && zf_mv -f -- "$tmp" "$1".zwc
  } always {
    (( $? )) && zf_rm -f -- "$tmp"
  }
}

function compinit() {}

function compdef() {
  emulate -L zsh
  _z4h_compdef+=("${(pj:\0:)@}")
}

# Main zsh4humans function. Type `z4h help` for usage.
function z4h() {
  [[ "$ARGC-$1" != 2-source ]] || {
    [[ -e "$2" ]] || return
    _z4h_compile "$2" || true
    source -- "$2"
    return
  }

  emulate -L zsh
  setopt typeset_silent pipe_fail extended_glob prompt_percent no_prompt_subst no_prompt_bang

  if [[ ${(e)_z4h_param_pat} != $_z4h_param_sig ]]; then
    print -Pru2 -- "%F{3}z4h%f: core parameters have unexpectedly changed"
    local -a old=(${(0)_z4h_param_sig})
    local -a new=(${(0)${(e)_z4h_param_pat}})
    local diff_old=(${new:|old})
    local diff_new=(${old:|new})
    print -Pru2 -- ""
    print -Pru2 -- "%F{2}Expected:%f"
    print -Pru2 -- ""
    print -lru2 -- "  "$^diff_old
    print -Pru2 -- ""
    print -Pru2 -- "%F{1}Found:%f"
    print -Pru2 -- ""
    print -lru2 -- "  "$^diff_new
    print -Pru2 -- ""
    print -Pru2 -- "Restore the parameters or restart Zsh with %F{2}%Uexec%u zsh%f."
    return 1
  fi

  case $ARGC-$1 in
    <2->-ssh)
      autoload -Uz z4h-ssh && z4h-ssh "${@:2}"
      return
    ;;

    1-reset)
      print -Pru2 -- "%F{3}z4h%f: deleting %B\$Z4H%b (%U${Z4H//\%/%%}%u)."
      zmodload -F zsh/files b:zf_rm || return
      zf_rm -rf -- $Z4H
      print -Pru2 -- "%F{3}z4h%f: restarting %F{2}zsh%f"
      exec -- $_z4h_exe
      return
    ;;

    1-install)
      if [[ -d $Z4H/zsh4humans ]]; then
        path=($Z4H/bin $path)
        fpath+=($Z4H/zsh4humans)
        typeset +x -gi Z4H_UPDATE
      else
        typeset +x -gi Z4H_UPDATE=1
      fi
    ;|

    1-update)
      typeset +x -gi Z4H_UPDATE=1
    ;|

    1-install|1-update)
      # GitHub projects to clone.
      local github_repos=(
        zsh-users/zsh-syntax-highlighting  # https://github.com/zsh-users/zsh-syntax-highlighting
        zsh-users/zsh-autosuggestions      # https://github.com/zsh-users/zsh-autosuggestions
        zsh-users/zsh-completions          # https://github.com/zsh-users/zsh-completions
        romkatv/powerlevel10k              # https://github.com/romkatv/powerlevel10k
        Aloxaf/fzf-tab                     # https://github.com/Aloxaf/fzf-tab
        junegunn/fzf                       # https://github.com/junegunn/fzf
      )

      {
        if [[ ! -e $Z4H/.last-update-ts ]]; then
          zmodload -F zsh/files b:zf_mkdir || return
          zf_mkdir -p -- $Z4H || return
          print -n >$Z4H/.last-update-ts || return
        elif (( ! Z4H_UPDATE )) && zstyle -t :z4h: auto-update ask; then
          local days
          if zstyle -s :z4h: auto-update-days days && [[ $dayz == <-> ]]; then
            # Check if update is required.
            zmodload zsh/stat zsh/datetime || return
            local -a last_update_ts
            if zstat -A last_update_ts +mtime -- $Z4H/.last-update-ts 2>/dev/null &&
              (( EPOCHSECONDS - last_update_ts[1] >= 86400 * days )); then
              local REPLY
              {
                read -q ${(%):-"?%F{3}z4h%f: update dependencies? [y/N]: "} && Z4H_UPDATE=1
              } always {
                [[ -w $TTY ]] && print >>$TTY || print -u2
              }
              (( Z4H_UPDATE )) || print -Pru2 -- "%F{3}z4h%f: type %F{2}z4h%f %Bupdate%b to update"
              print -n >$Z4H/.last-update-ts || return
            fi
          fi
        fi

        if (( Z4H_UPDATE == 1 )); then
          _z4h_clone $Z4H romkatv/zsh4humans "${Z4H_URL:t}" || return
          print -Pru2 -- "%F{3}z4h%f: restarting %F{2}zsh%f"
          Z4H_UPDATE=2 exec -- $_z4h_exe || return
        fi

        if (( Z4H_UPDATE == 2 )); then
          typeset +x -gi Z4H_UPDATE=1
        fi

        # Clone or update all repositories.
        local repo
        for repo in $github_repos; do
          _z4h_clone $Z4H/$repo $repo master || return
        done

        # Download fzf binary.
        if [[ ! -e $Z4H/junegunn/fzf/bin/fzf || $Z4H_UPDATE == 1 ]]; then
          print -Pru2 -- "%F{3}z4h%f: fetching %F{2}fzf%f binary"
          local BASH_SOURCE=($Z4H/junegunn/fzf/install) err
          if ! err=$(emulate sh && set -- --bin && source "${BASH_SOURCE[0]}" 2>&1); then
            print -ru2 -- $err
            return 1
          fi
        fi
      } always {
        if (( $? )); then
          print -Pru2 -- "%F{3}z4h%f: %F{1}failed to install or update dependencies%f"
          print -Pru2 -- ""
          print -Pru2 -- "Type \`%F{2}z4h%f %B$1%b\` to retry."
          print -Pru2 -- "If this problem persists, try \`%F{2}z4h%f %Breset%b\`."
        fi
      }

      fpath+=($Z4H/zsh-users/zsh-completions/src)
      path+=($Z4H/junegunn/fzf/bin)
      return 0
    ;;

    2-clone)
      if [[ -z $2 || $2 == *:* ]]; then
        print -Pru2 -- "%F{3}z4h%f: %Bclone%b argument must be %Uuser/repo%u: %F{1}${2//\%/%%}%f"
        return 1
      fi
      if [[ -z ${Z4H_UPDATE:#2} ]]; then
        print -Pru2 -- "%F{3}z4h%f: %F{1}clone%f cannot be called before %Binstall%b"
        return 1
      fi
      if (( $+_z4h_initialized )); then
        print -Pru2 -- "%F{3}z4h%f: %F{1}clone%f cannot be called after %Binit%b"
        return 1
      fi
      _z4h_clone $Z4H/$2 $2 master
      return
    ;;

    1-chsh)
      if [[ -z ${Z4H_UPDATE:#2} ]]; then
        print -Pru2 -- "%F{3}z4h%f: %F{1}clone%f cannot be called before %Binstall%b"
        return 1
      fi
      if (( $+_z4h_initialized )); then
        print -Pru2 -- "%F{3}z4h%f: %F{1}clone%f cannot be called after %Binit%b"
        return 1
      fi
      # Check whether the current shell is the login shell. If not, offer to change login shell.
      (( UID && EUID )) || return 0
      [[ -n $SHELL && $SHELL != $_z4h_exe && $_z4h_exe == /* && ${SHELL:A} != ${_z4h_exe:A} &&
        -x ${_z4h_exe:A} && ! -e $Z4H/.no-chsh && $+commands[chsh] == 1 &&
        -r /etc/shells && -w $TTY ]] || return 0
      [[ $+commands[sudo] == 1 ||
        "$(</etc/shells)" == *((#s)|$'\n')($_z4h_exe|${_z4h_exe:A})((#e)|$'\n')* ]] || return 0

      >>$TTY print -Pr -- "%F{3}z4h%f: the current shell isn't your login shell"
      >>$TTY print -Pr -- ""
      >>$TTY print -Pr -- "  Current shell         %F{2}${_z4h_exe//\%/%%}%f"
      >>$TTY print -Pr -- "  Login shell (%B\$SHELL%b)  %F{2}${SHELL//\%/%%}%f"

      trap '' INT
      (
        local query="Change login shell to %F{2}${_z4h_exe//\%/%%}%f?"
        while true; do
          {
            local REPLY=n
            >>$TTY print
            read -q ${(%):-"?$query [y/N]: "} && REPLY=y
          } always {
            >>$TTY print -l -- '' ''
          }
          if [[ $REPLY != y ]]; then
            print -rn >$Z4H/.no-chsh || return
            >>$TTY print -Pr -- "Won't ask again until %U\$Z4H/.no-chsh%u is deleted."
            return 1
          fi
          query="Try again?"
          if [[ "$(</etc/shells)" != *((#s)|$'\n')($_z4h_exe|${_z4h_exe:A})((#e)|$'\n')* ]]; then
            >>$TTY print -Pr -- "Adding %F{2}${_z4h_exe//\%/%%}%f to %U/etc/shells%u."
            sudo tee -a /etc/shells >/dev/null <<<$_z4h_exe || continue
            >$TTY print
          fi
          >>$TTY print -Pr -- "Changing login shell to %F{2}${_z4h_exe//\%/%%}%f."
          chsh -s $_z4h_exe || continue
          >>$TTY print -Pr -- "Changed login shell to %F{2}${_z4h_exe//\%/%%}%f."
          return 0
        done
      ) && export SHELL=$_z4h_exe

      return 0
    ;;

    1-help) ;|

    2-help)
      case $2 in
        install)
          print -Pr -- "usage: %F{2}z4h%f %Binstall%b"
          print -Pr -- ""
          print -Pr -- "Install all missing dependencies (fzf, zsh-autosuggestions, etc.)."
        ;;
        update)
          print -Pr -- "usage: %F{2}z4h%f %Bupdate%b"
          print -Pr -- ""
          print -Pr -- "Update all dependencies (fzf, zsh-autosuggestions, etc.)."
        ;;
        init)
          print -Pr -- "usage: %F{2}z4h%f %Binit%b"
          print -Pr -- ""
          print -Pr -- "Initialize Zsh. Should be called just once from %U.zshrc%u."
        ;;
        reset)
          print -Pr -- "usage: %F{2}z4h%f %Breset%b"
          print -Pr -- ""
          print -Pr -- "Reinstall all dependencies (fzf, zsh-autosuggestions, etc.)."
        ;;
        clone)
          print -Pr -- "usage: %F{2}z4h%f %Bclone%b %Uusername/repository%u"
          print -Pr -- ""
          print -Pr -- "Clone a repository from GitHub. Can be called from %U.zshrc%u between"
          print -Pr -- "%Binstall%b and %Binit%b."
        ;;
        source)
          print -Pr -- "usage: %F{2}z4h%f %Bsource%b %Ufile%u"
          print -Pr -- ""
          print -Pr -- "Compile and source Zsh file if it exists. This is done with current options."
        ;;
        ssh)
          autoload -Uz z4h-help-ssh && z4h-help-ssh
          return
        ;;
        chsh)
          print -Pr -- "usage: %F{2}z4h%f %Bchsh%b"
          print -Pr -- ""
          print -Pr -- "Check whether current user's login shell is %F{2}zsh%f. If not, offer to"
          print -Pr -- "change login shell."
        ;;
        help)
          print -Pr -- "usage: %F{2}z4h%f %Bhelp%b [%Ucommand%u]"
          print -Pr -- ""
          print -Pr -- "Print help for the command."
        ;;
        *)
          print -Pru2 -- "%F{3}z4h%f: unknown command: %F{1}${2//\%/%%}%f"
          return 1
        ;;
      esac
      return 0
    ;;

    1-init)
      if [[ -z ${Z4H_UPDATE:#2} ]]; then
        print -Pru2 -- "%F{3}z4h%f: %F{1}init%f cannot be called before %Binstall%b"
        return 1
      fi
      if (( _z4h_initialized )); then
        print -Pru2 "%F{3}z4h%f: %F{1}init%f cannot be called more than once"
        return 1
      fi
      if (( Z4H_UPDATE == 1 )); then
        print -Pru2 -- "%F{3}z4h%f: restarting %F{2}zsh%f"
        exec -- $_z4h_exe || return
      fi
    ;;

    *)
      [[ $ARGC-$1 == 1-help ]] && local fd=1 ret=0 || local fd=2 ret=1
      print -Pru$fd -- "usage: %F{2}z4h%f %Binstall%b"
      print -Pru$fd -- "           %Bupdate%b"
      print -Pru$fd -- "           %Binit%b"
      print -Pru$fd -- "           %Breset%b"
      print -Pru$fd -- "           %Bclone%b %Uusername/repository%u"
      print -Pru$fd -- "           %Bsource%b %Ufile%u"
      print -Pru$fd -- "           %Bssh%b [%Ussh-options%u] [%Uuser@%u]%Uhostname%u"
      print -Pru$fd -- "           %Bchsh%b"
      print -Pru$fd -- "           %Bhelp%b [%Ucommand%u]"
      return ret
    ;;
  esac

  typeset -gri _z4h_initialized=1

  # Enable Powerlevel10k instant prompt.
  if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
  fi

  # Display $1 in terminal title.
  function z4h-set-term-title() {
    emulate -L zsh
    if [[ -t 1 ]]; then
      print -rn -- $'\e]0;'${(V)1}$'\a'
    elif [[ -w $TTY ]]; then
      print -rn -- $'\e]0;'${(V)1}$'\a' >$TTY
    fi
  }

  # When a command is running, display it in the terminal title.
  function z4h-set-term-title-preexec() {
    if (( P9K_SSH )); then
      z4h-set-term-title ${(V%):-"%n@%m: "}$1
    else
      z4h-set-term-title $1
    fi
  }

  # When no command is running, display the current directory in the terminal title.
  function z4h-set-term-title-precmd() {
    if (( P9K_SSH )); then
      z4h-set-term-title ${(V%):-"%n@%m: %~"}
    else
      z4h-set-term-title ${(V%):-"%~"}
    fi
  }

  autoload -Uz add-zsh-hook                       || return
  add-zsh-hook preexec z4h-set-term-title-preexec || return
  add-zsh-hook precmd z4h-set-term-title-precmd   || return

  # If the current locale isn't UTF-8, change it to an UTF-8 one.
  # Try in order: C.UTF-8, en_US.UTF-8, the first UTF-8 locale in lexicographical order.
  () {
    emulate -L zsh -o extended_glob
    zmodload zsh/langinfo
    [[ $langinfo[CODESET] == (utf|UTF)(-|)8 ]] && return 0
    (( $+commands[locale] )) || return
    local loc=(${(@M)$(locale -a):#*.(utf|UTF)(-|)8})
    (( $#loc )) || return
    export LC_ALL=${loc[(r)(#i)C.UTF(-|)8]:-${loc[(r)(#i)en_US.UTF(-|)8]:-$loc[1]}}
  } || : ${POWERLEVEL9K_CONFIG_FILE=${ZDOTDIR:-~}/.p10k-portable.zsh}

  # Enable command_not_found_handler if possible.
  if (( $+functions[command_not_found_handler] )); then
    # already installed
  elif [[ -e /etc/zsh_command_not_found ]]; then
    source /etc/zsh_command_not_found
  elif [[ -e /usr/share/doc/pkgfile/command-not-found.zsh ]]; then
    source /usr/share/doc/pkgfile/command-not-found.zsh
  elif [[ -x /usr/libexec/pk-command-not-found && -S /var/run/dbus/system_bus_socket ]]; then
    command_not_found_handler() { /usr/libexec/pk-command-not-found "$@" }
  elif [[ -x /data/data/com.termux/files/usr/libexec/termux/command-not-found ]]; then
    command_not_found_handler() { /data/data/com.termux/files/usr/libexec/termux/command-not-found "$@" }
  elif [[ -x /run/current-system/sw/bin/command-not-found ]]; then
    command_not_found_handler() { /run/current-system/sw/bin/command-not-found "$@" }
  elif (( $+commands[brew] )); then
    () {
      emulate -L zsh -o extended_glob
      [[ -n $TTY && ( -n $CONTINUOUS_INTEGRATION || -z $MC_SID ) ]] || return
      local repo
      repo="$(brew --repository 2>/dev/null)" || return
      [[ -n $repo/Library/Taps/*/*/cmd/brew-command-not-found-init(|.rb)(#q.N) ]] || return
      autoload -Uz is-at-least
      function command_not_found_handler() {
        emulate -L zsh
        local msg
        if msg="$(brew which-formula --explain $1 2>/dev/null)" && [[ -n $msg ]]; then
          print -ru2 -- $msg
        elif is-at-least 5.3; then
          print -ru2 -- "zsh: command not found: $1"
        fi
        return 127
      }
    }
  fi

  # The same as up-line-or-beginning-search but for local history.
  function z4h-up-local-history() {
    emulate -L zsh
    local last=$LASTWIDGET
    zle .set-local-history 1
    () { local -h LASTWIDGET=$last; up-line-or-beginning-search "$@" } "$@"
    zle .set-local-history 0
  }

  # The same as down-line-or-beginning-search but for local history.
  function z4h-down-local-history() {
    emulate -L zsh
    local last=$LASTWIDGET
    zle .set-local-history 1
    () { local -h LASTWIDGET=$last; down-line-or-beginning-search "$@" } "$@"
    zle .set-local-history 0
  }

  function z4h-beginning-of-buffer() { CURSOR=0 }
  function z4h-end-of-buffer() { CURSOR=$(($#BUFFER  + 1)) }
  function z4h-expand() { zle _expand_alias || zle .expand-word || true }
  function z4h-run-help() { zle run-help || true }

  zmodload zsh/terminfo || return
  if (( $+terminfo[rmam] && $+terminfo[smam] )); then
    function z4h-expand-or-complete() {
      # Show '...' while completing. No `emulate -L zsh` to pick up dotglob if it's set.
      print -rn -- ${terminfo[rmam]}${(%):-"%F{red}...%f"}${terminfo[smam]}
      zle fzf-tab-complete
    }
  else
    function z4h-expand-or-complete() { zle fzf-tab-complete }
  fi

  # fzf-history-widget with duplicate removal, preview and syntax highlighting (requires `bat`).
  function z4h-fzf-history() {
    emulate -L zsh -o pipefail
    local preview='printf "%s" {}'
    (( $+commands[bat] )) && preview+=' | bat -l bash --color always -pp'
    local cmd
    cmd="$(print -rNC1 -- "${(@u)history}" |
      fzf --read0 --no-multi --tiebreak=index --cycle --height=80% \
        --preview-window=down:40%:wrap --preview=$preview          \
        --bind '?:toggle-preview,ctrl-h:backward-kill-word' --query=$LBUFFER)"
    local -i ret=$?
    if [[ $ret == 0 && -n "$cmd" ]]; then
      zle .vi-fetch-history -n $(($#history - ${${history[@]}[(ie)$cmd]} + 1))
    fi
    zle .reset-prompt
    return ret
  }

  # Widgets for changing current working directory.
  function z4h-redraw-prompt() {
    emulate -L zsh
    local f
    for f in chpwd $chpwd_functions precmd $precmd_functions; do
      (( $+functions[$f] )) && $f &>/dev/null
    done
    zle .reset-prompt
    zle -R
  }
  function z4h-cd-rotate() {
    emulate -L zsh
    while (( $#dirstack )) && ! pushd -q $1 &>/dev/null; do
      popd -q $1
    done
    if (( $#dirstack )); then
      z4h-redraw-prompt
    fi
  }
  function z4h-cd-back() { z4h-cd-rotate +1 }
  function z4h-cd-forward() { z4h-cd-rotate -0 }
  function z4h-cd-up() { cd .. && z4h-redraw-prompt }

  function z4h-autosuggest-accept() {
    emulate -L zsh
    local cursor=$CURSOR
    zle autosuggest-accept
    CURSOR=$cursor
  }

  function z4h-do-nothing() {}

  autoload -Uz up-line-or-beginning-search down-line-or-beginning-search run-help || return
  (( $+aliases[run-help] )) && unalias run-help  # make run-help more useful

  zle -N up-line-or-beginning-search
  zle -N down-line-or-beginning-search
  zle -N z4h-expand
  zle -N z4h-beginning-of-buffer
  zle -N z4h-end-of-buffer
  zle -N z4h-expand-or-complete
  zle -N z4h-up-local-history
  zle -N z4h-down-local-history
  zle -N z4h-cd-back
  zle -N z4h-cd-forward
  zle -N z4h-cd-up
  zle -N z4h-fzf-history
  zle -N z4h-autosuggest-accept
  zle -N z4h-do-nothing
  zle -N z4h-run-help

  zmodload zsh/terminfo || return
  if (( terminfo[colors] >= 256 )); then
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=244'         # the default is hard to see
    typeset -A ZSH_HIGHLIGHT_STYLES=(comment fg=96)  # different colors for comments and suggestions
  else
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=black,bold'  # the default is outside of 8 color range
    : ${POWERLEVEL9K_CONFIG_FILE=${ZDOTDIR:-~}/.p10k-portable.zsh}
  fi

  ZSH_HIGHLIGHT_MAXLENGTH=1024                # don't colorize long command lines (slow)
  ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)  # main syntax highlighting plus matching brackets
  ZSH_AUTOSUGGEST_MANUAL_REBIND=1             # disable a very slow obscure feature

  PROMPT_EOL_MARK='%K{red} %k'   # mark the missing \n at the end of a comand output with a red block
  READNULLCMD=less               # use `less` instead of the default `more`
  WORDCHARS=''                   # only alphanums make up words in word-based zle widgets
  ZLE_REMOVE_SUFFIX_CHARS=''     # don't eat space when typing '|' after a tab completion
  zle_highlight=('paste:none')   # disable highlighting of text pasted into the command line

  : ${HISTFILE:=${ZDOTDIR:-~}/.zsh_history}  # save command history in this file
  HISTSIZE=1000000000                        # infinite command history
  SAVEHIST=1000000000                        # infinite command history

  bindkey -e  # enable emacs keymap (sorry, vi users)

  if [[ ${commands[find]:A} == */busybox* ]]; then
    local fs=
  else
    local fs="-o -fstype sysfs -o -fstype devfs -o -fstype devtmpfs -o -fstype proc"
  fi
  : ${FZF_ALT_C_COMMAND:="command find -L . -mindepth 1 \( -path '*/\.*' "$fs" \) -prune -o -type d -print 2>/dev/null | cut -b3-"}

  FZF_COMPLETION_TRIGGER=''                            # file completion without trigger
  fzf_default_completion=z4h-expand-or-complete        # file completion falls back to regular
  z4h source $Z4H/junegunn/fzf/shell/completion.zsh    # load fzf-completion
  z4h source $Z4H/junegunn/fzf/shell/key-bindings.zsh  # load fzf-cd-widget

  zstyle ':fzf-tab:*' prefix ''                    # remove '·'
  zstyle ':fzf-tab:*' continuous-trigger alt-enter # alt-enter to accept and trigger next completion
  bindkey '\t' expand-or-complete                  # fzf-tab reads it during initialization
  z4h source $Z4H/Aloxaf/fzf-tab/fzf-tab.zsh       # load fzf-tab-complete

  # Delete all existing keymaps and reset to the default state.
  bindkey -d

  # If NumLock is off, translate keys to make them appear the same as with NumLock on.
  bindkey -s '^[OM' '^M'  # enter
  bindkey -s '^[Ok' '+'
  bindkey -s '^[Om' '-'
  bindkey -s '^[Oj' '*'
  bindkey -s '^[Oo' '/'
  bindkey -s '^[OX' '='

  # If someone switches our terminal to application mode (smkx), translate keys to make
  # them appear the same as in raw mode (rmkx).
  bindkey -s '^[OH' '^[[H'  # home
  bindkey -s '^[OF' '^[[F'  # end
  bindkey -s '^[OA' '^[[A'  # up
  bindkey -s '^[OB' '^[[B'  # down
  bindkey -s '^[OD' '^[[D'  # left
  bindkey -s '^[OC' '^[[C'  # right

  # TTY sends different key codes. Translate them to regular.
  bindkey -s '^[[1~' '^[[H'  # home
  bindkey -s '^[[4~' '^[[F'  # end

  bindkey '^[[D'    backward-char                  # left       move cursor one char backward
  bindkey '^[[C'    forward-char                   # right      move cursor one char forward
  bindkey '^[[A'    z4h-up-local-history           # up         prev command in local history
  bindkey '^[[B'    z4h-down-local-history         # down       next command in local history
  bindkey '^[[H'    beginning-of-line              # home       go to the beginning of line
  bindkey '^[[F'    end-of-line                    # end        go to the end of line
  bindkey '^?'      backward-delete-char           # bs         delete one char backward
  bindkey '^[[3~'   delete-char                    # delete     delete one char forward
  bindkey '^H'      backward-kill-word             # ctrl+bs    delete previous word
  bindkey '^[^?'    backward-kill-word             # alt+bs     delete previous word
  bindkey '^[[3;5~' kill-word                      # ctrl+del   delete next word
  bindkey '^[[3;3~' kill-word                      # alt+del    delete next word
  bindkey '^K'      kill-line                      # ctrl+k     delete line after cursor
  bindkey '^J'      backward-kill-line             # ctrl+j     delete line before cursor
  bindkey '^[n'     kill-buffer                    # alt+n      delete all lines
  bindkey '^[N'     kill-buffer                    # alt+N      delete all lines
  bindkey '^[m'     z4h-autosuggest-accept         # alt+m      accept autosuggestion
  bindkey '^[M'     z4h-autosuggest-accept         # alt+M      accept autosuggestion
  bindkey '^_'      undo                           # ctrl+/     undo
  bindkey '^[\'     redo                           # alt+/      redo
  bindkey '^[[1;5A' up-line-or-beginning-search    # ctrl+up    prev cmd in global history
  bindkey '^[[1;5B' down-line-or-beginning-search  # ctrl+down  next cmd in global history
  bindkey '^ '      z4h-expand                     # ctrl+space expand alias/glob/parameter
  bindkey '\t'      z4h-expand-or-complete         # tab        fzf-tab completion
  bindkey '^[f'     fzf-completion                 # alt-f      fzf file completion
  bindkey '^[F'     fzf-completion                 # alt-F      fzf file completion
  bindkey '^R'      z4h-fzf-history                # ctrl+r     fzf history
  bindkey '^[h'     z4h-run-help                   # alt+h      help for the cmd at cursor
  bindkey '^[H'     z4h-run-help                   # alt+H      help for the cmd at cursor
  bindkey '^[[1;5H' z4h-beginning-of-buffer        # ctrl-home  go to the beginning of buffer
  bindkey '^[[1;3H' z4h-beginning-of-buffer        # alt-home   go to the beginning of buffer
  bindkey '^[[1;5F' z4h-end-of-buffer              # ctrl-end   go to the end of buffer
  bindkey '^[[1;3F' z4h-end-of-buffer              # alt-end    go to the end of buffer
  bindkey '^[[5~'   z4h-do-nothing                 # pageup     do nothing
  bindkey '^[[6~'   z4h-do-nothing                 # pageup     do nothing

  if zstyle -t :z4h: cd-key ctrl; then
    bindkey '^[[1;3D' backward-word                # alt+left   go backward one word
    bindkey '^[[1;3C' forward-word                 # alt+right  go forward one word
    bindkey '^[[1;5D' z4h-cd-back                  # ctrl+left  cd into the prev directory
    bindkey '^[[1;5C' z4h-cd-forward               # ctrl+right cd into the next directory
    bindkey '^[[1;5A' z4h-cd-up                    # ctrl+up    cd ..
    bindkey '^[[1;5B' fzf-cd-widget                # ctrl+down  fzf cd
  else
    bindkey '^[[1;5D' backward-word                # ctrl+left  go backward one word
    bindkey '^[[1;5C' forward-word                 # ctrl+right go forward one word
    bindkey '^[[1;3D' z4h-cd-back                  # alt+left   cd into the prev directory
    bindkey '^[[1;3C' z4h-cd-forward               # alt+right  cd into the next directory
    bindkey '^[[1;3A' z4h-cd-up                    # alt+up     cd ..
    bindkey '^[[1;3B' fzf-cd-widget                # alt+down   fzf cd
  fi

  # Tell zsh-autosuggestions how to handle different widgets.
  typeset -g ZSH_AUTOSUGGEST_EXECUTE_WIDGETS=()
  typeset -g ZSH_AUTOSUGGEST_CLEAR_WIDGETS=(
    accept-line
    up-line-or-beginning-search
    down-line-or-beginning-search
    z4h-up-local-history
    z4h-down-local-history
    z4h-fzf-history
  )
  typeset -g ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS=(
    forward-word
    emacs-forward-word
    vi-forward-word
    vi-forward-word-end
    vi-forward-blank-word
    vi-forward-blank-word-end
    vi-find-next-char
    vi-find-next-char-skip
  )
  typeset -g ZSH_AUTOSUGGEST_IGNORE_WIDGETS=(
    orig-\*
    beep
    run-help
    set-local-history
    which-command
    yank
    yank-pop
    zle-\*
    redisplay
    fzf-tab-complete
    z4h-autosuggest-accept
    autosuggest-accept
  )
  typeset -g ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=(
    z4h-end-of-buffer
  )

  if zstyle -t :z4h:autosuggestions forward-char accept; then
    ZSH_AUTOSUGGEST_ACCEPT_WIDGETS+=(forward-char vi-forward-char)
  else
    ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS+=(forward-char vi-forward-char)
  fi

  if zstyle -t :z4h:autosuggestions end-of-line accept; then
    ZSH_AUTOSUGGEST_ACCEPT_WIDGETS+=(end-of-line vi-end-of-line vi-add-eol)
  else
    ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS+=(end-of-line vi-end-of-line vi-add-eol)
  fi

  # Use lesspipe if available. It allows you to use less on binary files (zip archives, etc.).
  if (( $#commands[(i)lesspipe(|.sh)] )); then
    export LESSOPEN="| /usr/bin/env $commands[(i)lesspipe(|.sh)] %s 2>&-"
  fi

  # This affects every invocation of `less`.
  #
  #   -i   case-insensitive search unless search string contains uppercase letters
  #   -R   color
  #   -F   exit if there is less than one page of content
  #   -X   keep content on screen after exit
  #   -M   show more info at the bottom prompt line
  #   -x4  tabs are 4 instead of 8
  export LESS=-iRFXMx4

  export PAGER=less

  # LS_COLORS is used by GNU ls and Zsh completions. LSCOLORS is used by BSD ls.
  export LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:'
  LS_COLORS+='cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:'
  LS_COLORS+='st=37;44:ex=01;32:'
  export LSCOLORS='ExGxFxdaCxDaDahbadacec'

  # Configure completions.
  zstyle ':completion:*'                  matcher-list    'm:{a-zA-Z}={A-Za-z}' 'l:|=* r:|=*'
  zstyle ':completion:*'                  completer       _complete
  zstyle ':completion:*:*:-subscript-:*'  tag-order       indexes parameters
  zstyle ':completion:*'                  squeeze-slashes true
  zstyle '*'                              single-ignored  show
  zstyle ':completion:*:(rm|kill|diff):*' ignore-line     other
  zstyle ':completion:*:rm:*'             file-patterns   '*:all-files'
  zstyle ':completion::complete:*'        use-cache       on
  zstyle ':completion::complete:*'        cache-path      ${XDG_CACHE_HOME:-$HOME/.cache}/zcompcache-$ZSH_VERSION
  zstyle ':completion:*'                  list-colors     ${(s.:.)LS_COLORS}

  # Set POWERLEVEL9K_CONFIG_FILE to the default location if it's not set yet.
  : ${POWERLEVEL9K_CONFIG_FILE:=${ZDOTDIR:-~}/.p10k.zsh}

  # Initialize prompt. Type `p10k configure` or edit $POWERLEVEL9K_CONFIG_FILE to customize it.
  z4h source $Z4H/romkatv/powerlevel10k/powerlevel10k.zsh-theme
  z4h source $POWERLEVEL9K_CONFIG_FILE
  z4h-set-term-title-precmd || return

  z4h source $Z4H/zsh-users/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh

  function _z4h-post-init() {
    emulate -L zsh

    add-zsh-hook -d precmd _z4h-post-init

    # Initialize completions.
    unfunction compinit compdef
    autoload -Uz compinit
    local dump=$Z4H/.zcompdump-$ZSH_VERSION
    compinit -u -d $dump
    [[ -r $dump ]] && _z4h_compile $dump

    # Replay compdef calls.
    local args
    for args in $_z4h_compdef; do
      compdef "${(@0)args}"
    done
    unset _z4h_compdef

    # Make it possible to use completion specifications and functions written for bash.
    autoload -Uz bashcompinit
    bashcompinit

    # zsh-syntax-highlighting must be loaded after all widgets have been defined.
    z4h source $Z4H/zsh-users/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh
  }

  precmd_functions=(_z4h-post-init $precmd_functions)

  _z4h_compile $Z4H/z4h.zsh

  # Aliases.
  if (( $+commands[dircolors] )); then  # proxy for GNU coreutils vs BSD
    # Don't define aliases for commands that point to busybox.
    [[ ${${:-diff}:c:A:t} == busybox* ]] || alias diff='diff --color=auto'
    [[ ${${:-ls}:c:A:t}   == busybox* ]] || alias ls='ls --color=auto'
  else
    [[ ${${:-ls}:c:A:t}   == busybox* ]] || alias ls='ls -G'
  fi
  [[ ${${:-grep}:c:A:t}   == busybox* ]] || alias grep='grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn}'

  # Enable decent options. See http://zsh.sourceforge.net/Doc/Release/Options.html.
  emulate zsh                    # restore default options just in case something messed them up
  setopt ALWAYS_TO_END           # full completions move cursor to the end
  setopt AUTO_CD                 # `dirname` is equivalent to `cd dirname`
  setopt AUTO_PARAM_SLASH        # if completed parameter is a directory, add a trailing slash
  setopt AUTO_PUSHD              # `cd` pushes directories to the directory stack
  setopt COMPLETE_IN_WORD        # complete from the cursor rather than from the end of the word
  setopt EXTENDED_GLOB           # more powerful globbing
  setopt EXTENDED_HISTORY        # write timestamps to history
  setopt HIST_EXPIRE_DUPS_FIRST  # if history needs to be trimmed, evict dups first
  setopt HIST_FIND_NO_DUPS       # don't show dups when searching history
  setopt HIST_IGNORE_DUPS        # don't add consecutive dups to history
  setopt HIST_IGNORE_SPACE       # don't add commands starting with space to history
  setopt HIST_VERIFY             # if a command triggers history expansion, show it instead of running
  setopt INTERACTIVE_COMMENTS    # allow comments in command line
  setopt MULTIOS                 # allow multiple redirections for the same fd
  setopt NO_BG_NICE              # don't nice background jobs
  setopt NO_FLOW_CONTROL         # disable start/stop characters in shell editor
  setopt PATH_DIRS               # perform path search even on command names with slashes
  setopt SHARE_HISTORY           # write and import history on every command
  setopt C_BASES                 # print hex/oct numbers as 0xFF/077 instead of 16#FF/8#77
}
