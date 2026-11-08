#!/bin/bash
# Install standalone commands without changing shell/tmux/editor configuration.
set -euo pipefail

DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
commands=(git-wt-clean git-worktree-clean)

for dependency in git python3; do
  if ! command -v "$dependency" >/dev/null 2>&1; then
    printf 'Install %s first, then rerun.\n' "$dependency" >&2
    exit 1
  fi
done

check_command() {
  local source="$DOTFILES_DIR/bin/$1"
  local target="$HOME/.local/bin/$1"
  local backup="$target.pre-dotfiles"
  if [ ! -x "$source" ]; then
    printf 'Missing executable: %s\n' "$source" >&2
    return 1
  fi
  if [ ! -e "$target" ] && [ ! -L "$target" ]; then
    return 0
  fi
  if [ -L "$target" ] && { [ "$(readlink "$target")" = "$source" ] || [ "$target" -ef "$source" ]; }; then
    return 0
  fi
  if [ -f "$target" ] && [ ! -L "$target" ] && cmp -s "$source" "$target"; then
    if [ -e "$backup" ] || [ -L "$backup" ]; then
      printf 'Refusing to overwrite backup: %s\n' "$backup" >&2
      return 1
    fi
  else
    printf 'Refusing to replace %s. Move or back it up, then rerun.\n' "$target" >&2
    return 1
  fi
}

# Check every destination before changing any of them.
for name in "${commands[@]}"; do
  check_command "$name"
done
mkdir -p "$HOME/.local/bin"
for name in "${commands[@]}"; do
  check_command "$name"
  source="$DOTFILES_DIR/bin/$name"
  target="$HOME/.local/bin/$name"
  if [ -L "$target" ]; then
    printf 'Already linked: %s\n' "$target"
    continue
  fi
  if [ -f "$target" ]; then
    mv "$target" "$target.pre-dotfiles"
    printf 'Preserved identical standalone copy: %s\n' "$target.pre-dotfiles"
  fi
  ln -s "$source" "$target"
  printf 'Installed %s -> %s\n' "$target" "$source"
done
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) printf '%s\n' 'Add ~/.local/bin to PATH: export PATH="$HOME/.local/bin:$PATH"' ;;
esac
