#!/bin/bash
set -e

DOTFILES_DIR="$HOME/dotfiles"

echo "==> Installing packages..."
sudo apt update
sudo apt install -y stow git zsh tmux neovim curl wget unzip fontconfig

# -- oh-my-zsh ----------------------------------------------------------------
echo "==> Installing oh-my-zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "    oh-my-zsh already installed, skipping"
fi

# -- zsh plugins --------------------------------------------------------------
echo "==> Installing zsh plugins..."
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
  echo "    zsh-autosuggestions already installed, skipping"
fi
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
  echo "    zsh-syntax-highlighting already installed, skipping"
fi

# -- oh-my-tmux ---------------------------------------------------------------
echo "==> Installing oh-my-tmux..."
if [ ! -d "$HOME/.tmux" ]; then
  git clone https://github.com/gpakosz/.tmux.git "$HOME/.tmux"
  ln -sf "$HOME/.tmux/.tmux.conf" "$HOME/.tmux.conf"
else
  echo "    oh-my-tmux already installed, skipping"
fi

# -- packer.nvim --------------------------------------------------------------
echo "==> Installing packer.nvim..."
PACKER_DIR="$HOME/.local/share/nvim/site/pack/packer/start/packer.nvim"
if [ ! -d "$PACKER_DIR" ]; then
  git clone --depth 1 https://github.com/wbthomason/packer.nvim "$PACKER_DIR"
else
  echo "    packer.nvim already installed, skipping"
fi

# -- Nerd Font ----------------------------------------------------------------
echo "==> Installing JetBrainsMono Nerd Font..."
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
if ! fc-list | grep -q "JetBrainsMono"; then
  cd /tmp
  wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip
  unzip -q JetBrainsMono.zip -d "$FONT_DIR"
  fc-cache -fv
  echo "    JetBrainsMono Nerd Font installed"
else
  echo "    JetBrainsMono Nerd Font already installed, skipping"
fi

# -- stow dotfiles ------------------------------------------------------------
echo "==> Stowing dotfiles..."
cd "$DOTFILES_DIR"
stow nvim
stow zsh
stow tmux

# -- .zshrc setup -------------------------------------------------------------
echo "==> Configuring .zshrc..."
if ! grep -q "source ~/.alias" "$HOME/.zshrc"; then
  echo "source ~/.alias" >> "$HOME/.zshrc"
fi

# -- default shell ------------------------------------------------------------
echo "==> Setting zsh as default shell..."
if [ "$SHELL" != "$(which zsh)" ]; then
  chsh -s "$(which zsh)"
  echo "    zsh set as default shell, takes effect on next login"
else
  echo "    zsh already default shell, skipping"
fi

echo ""
echo "==> Done! Please:"
echo "    1. Restart terminal or run: source ~/.zshrc"
echo "    2. Open nvim and run: :PackerSync"
echo "    3. Set XFCE Terminal font to: JetBrainsMono Nerd Font Mono"

