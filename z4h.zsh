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
    >&2 printf 'z4h: invalid Z4H_URL: %s\n' "$Z4H_URL"
    return 1
  fi

  printf 'z4h: fetching %s\n' "$proj"
  command mkdir -p -- "$tmp" "$Z4H"/bin "$Z4H"/fn "$Z4H"/cache || return

  (
    cd "${ZSH_VERSION:+-q}" -- "$tmp" || exit

    local url="https://github.com/$proj/archive/$ref.tar.gz"
    local err

    if command -v curl >/dev/null 2>&1; then
      err="$(command curl -fsSLo snapshot.tar.gz -- "$url" 2>&1)"
    elif command -v wget >/dev/null 2>&1; then
      err="$(command wget -O snapshot.tar.gz -- "$url" 2>&1)"
    else
      >&2 echo "z4h: please install curl or wget"
      exit 1
    fi

    if [ $? != 0 ]; then
      >&2 printf "%s\n" "$err"
      >&2 echo "z4h: failed to download $url"
      exit 1
    fi

    command tar -xzf snapshot.tar.gz   || exit
    command rm -rf -- "$Z4H/$proj"     || exit
    command mv -f -- "$tmp/"*-* "$dir" || exit
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
