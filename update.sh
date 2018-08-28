#!/bin/sh

if test -n "$BASH_VERSION"; then
  thisdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
else
  thisdir="$(cd "$(dirname "$0")" >/dev/null && pwd)"
fi

for file in .bashrc .xinitrc .vimrc .xvimrc .profile .tmux.conf \
            .spacemacs .gitconfig; do
  from="$HOME/$file"
  to="$thisdir/$file" 
  if test -f "$to"; then
    if ! diff "$from" "$to" >/dev/null 2>&1; then
      rm -f "$to"
      cp "$from" "$to"
    fi
  else
    echo "$from does not exist or is not a regular file"
  fi
done

