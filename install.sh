#!/usr/bin/env bash
# Symlink each config dir into ~/.config. Existing dirs are moved to *.bak.<timestamp>, never deleted.
set -euo pipefail

src="$(cd "$(dirname "$0")" && pwd)"
cfg="${XDG_CONFIG_HOME:-$HOME/.config}"
mkdir -p "$cfg"

for d in hypr kitty quickshell wallpapers; do
    target="$cfg/$d"
    if [ -L "$target" ]; then
        rm "$target"
    elif [ -e "$target" ]; then
        mv "$target" "$target.bak.$(date +%s)"
        echo "backed up $target"
    fi
    ln -s "$src/$d" "$target"
    echo "linked $target -> $src/$d"
done
