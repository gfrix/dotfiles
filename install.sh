#!/bin/sh

# -f for force, -v for verbose
force=false
verbose=false
case " $* " in *" -f "*) force=: ;; esac
case " $* " in *" -v "*) verbose=: ;; esac

if test -n "$BASH_VERSION"; then
  thisdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
else
  thisdir="$(cd "$(dirname "$0")" >/dev/null && pwd)"
fi

for file in .bashrc .xinitrc .vimrc .xvimrc .profile .tmux.conf \
            .spacemacs .gitconfig; do
  from="$thisdir/$file" 
  to="$HOME/$file"
  if test -f "$to"; then
    if ! diff "$from" "$to" >/dev/null 2>&1; then
      $force && tense=will || tense=would
      echo "'$to' has changes that $tense be overwritten."
      $verbose && echo "diff:"
      $verbose && diff -u "$from" "$to"
      $force || echo "skipping $file"
    fi
    $force && {
      rm -f "$to"
      cp "$from" "$to"
    }
  elif test -e "$to"; then
    echo "something other than a regular file exists at $to"
    echo "skipping $file"
  else
    cp "$from" "$to"
  fi
done

