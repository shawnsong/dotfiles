#!/bin/bash
# Install standalone commands without changing shell/tmux/editor configuration.
set -euo pipefail

DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source="$DOTFILES_DIR/bin/git-wt-clean"
target="$HOME/.local/bin/git-wt-clean"

for dependency in git python3; do
  if ! command -v "$dependency" >/dev/null 2>&1; then
    printf 'Install %s first, then rerun.\n' "$dependency" >&2
    exit 1
  fi
done
if [ ! -x "$source" ]; then
  printf 'Missing executable: %s\n' "$source" >&2
  exit 1
fi

if [ -e "$target" ] || [ -L "$target" ]; then
  if [ -L "$target" ] && { [ "$(readlink "$target")" = "$source" ] || [ "$target" -ef "$source" ]; }; then
    printf 'Already linked: %s\n' "$target"
    exit 0
  fi
  if [ -f "$target" ] && [ ! -L "$target" ] && cmp -s "$source" "$target"; then
    backup="$target.pre-dotfiles"
    if [ -e "$backup" ] || [ -L "$backup" ]; then
      printf 'Refusing to overwrite backup: %s\n' "$backup" >&2
      exit 1
    fi
    mv "$target" "$backup"
    printf 'Preserved identical standalone copy: %s\n' "$backup"
  else
    printf 'Refusing to replace %s. Move or back it up, then rerun.\n' "$target" >&2
    exit 1
  fi
fi

mkdir -p "$HOME/.local/bin"
ln -s "$source" "$target"
printf 'Installed %s -> %s\n' "$target" "$source"
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) printf '%s\n' 'Add ~/.local/bin to PATH: export PATH="$HOME/.local/bin:$PATH"' ;;
esac
