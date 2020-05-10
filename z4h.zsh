if [ -e "$Z4H"/romkatv/zsh4humans/main.zsh ]; then
  . "$Z4H"/romkatv/zsh4humans/main.zsh
  return
fi

_z4h_bootstrap() {
  local id="${Z4H_URL#https://raw.githubusercontent.com/}"
  local ref="${id##*/}"
  local proj="${id%/*}"
  local dir="$Z4H/$proj"
  local tmp="$dir.tmp.$$"
  if [ "$mid" = "$Z4H_URL" -o -z "$ref" -o -z "$proj" ]; then
    if [ -t 2 ]; then
      >&2 printf '\033[33mz4h\033[0m: invalid \033[1mZ4H_URL\033[0m: \033[31m%s\033[0m\n' "$Z4H_URL"
    else
      >&2 printf 'z4h: invalid Z4H_URL: %s\n' "$Z4H_URL"
    fi
    return 1
  fi

  if [ -t 2 ]; then
    >&2 printf '\033[33mz4h\033[0m: fetching \033[1m%s\033[0m\n' "$proj"
  else
    >&2 printf 'z4h: fetching %s\n' "$proj"
  fi
  command mkdir -p -- "$tmp" "$Z4H"/bin "$Z4H"/fn "$Z4H"/cache || return
  echo -n > $Z4H/cache/.last-update-ts || return

  (
    cd "${ZSH_VERSION:+-q}" -- "$tmp" || exit

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

    command tar -xzf snapshot.tar.gz || exit
    command rm -rf -- "$Z4H/$proj"   || exit
    command mv -f -- ./*-* "$dir"    || exit
  )

  local ret=$?
  command rm -rf -- "$tmp"

  return "$ret"
}

if _z4h_bootstrap; then
  unset -f _z4h_bootstrap
  . "$Z4H"/romkatv/zsh4humans/main.zsh
else
  unset -f _z4h_bootstrap
  return 1
fi
