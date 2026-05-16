#!/usr/bin/env bash
set -e
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "→ Installing packages..."
sudo apt update -qq
sudo apt install -y \
  zsh git curl wget fzf ripgrep fd-find bat \
  i3 i3status rofi picom xclip polybar \
  build-essential cmake python3 python3-pip \
  fontconfig wmctrl

echo "→ Installing Neovim..."
wget -qO /tmp/nvim.appimage \
  https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
chmod +x /tmp/nvim.appimage
sudo mv /tmp/nvim.appimage /usr/local/bin/nvim

echo "→ Installing kitty..."
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
mkdir -p ~/.local/bin
ln -sf ~/.local/kitty.app/bin/kitty ~/.local/bin/kitty

echo "→ Installing delta..."
wget -qO /tmp/delta.deb \
  https://github.com/dandavison/delta/releases/download/0.18.2/git-delta_0.18.2_amd64.deb
sudo dpkg -i /tmp/delta.deb

echo "→ Installing yazi..."
sudo snap install yazi --classic

echo "→ Installing starship..."
curl -sS https://starship.rs/install.sh | sh

echo "→ Installing zoxide..."
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

echo "→ Installing zinit..."
bash -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"

echo "→ Installing JetBrainsMono Nerd Font (fixes polybar icons)..."
mkdir -p ~/.local/share/fonts
wget -qO /tmp/JetBrainsMono.zip \
  https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip -o /tmp/JetBrainsMono.zip -d ~/.local/share/fonts/JetBrainsMono/ '*.ttf' 2>/dev/null || true
fc-cache -fv ~/.local/share/fonts

echo "→ Fonts..."
cp "$DOTFILES/fonts/"* ~/.local/share/fonts/ && fc-cache -fv > /dev/null

echo "→ Installing Vesktop..."
VESKTOP_URL=$(curl -s https://api.github.com/repos/Vencord/Vesktop/releases/latest \
  | grep "browser_download_url.*amd64\.deb" | cut -d'"' -f4)
wget -qO /tmp/vesktop.deb "$VESKTOP_URL"
sudo dpkg -i /tmp/vesktop.deb

echo "→ bat symlink..."
mkdir -p ~/.local/bin
ln -sf /usr/bin/batcat ~/.local/bin/bat

echo "→ Linking dotfiles..."
cd "$DOTFILES"
symlink() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  ln -sf "$src" "$dst"
  echo "  ✓ $dst → $src"
}

symlink "$DOTFILES/zsh/.zshrc"                    "$HOME/.zshrc"
symlink "$DOTFILES/git/.gitconfig"                "$HOME/.gitconfig"
symlink "$DOTFILES/kitty/.config/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
symlink "$DOTFILES/kitty/.config/kitty/colors.conf" "$HOME/.config/kitty/colors.conf"
symlink "$DOTFILES/nvim/.config/nvim"             "$HOME/.config/nvim"
symlink "$DOTFILES/i3/.config/i3"                 "$HOME/.config/i3"
symlink "$DOTFILES/yazi/.config/yazi"             "$HOME/.config/yazi"
symlink "$DOTFILES/polybar/.config/polybar"       "$HOME/.config/polybar"
symlink "$DOTFILES/starship/.config/starship.toml" "$HOME/.config/starship.toml"
chmod +x "$DOTFILES/polybar/.config/polybar/launch.sh"

echo "→ Setting zsh as default shell..."
chsh -s "$(which zsh)"

echo "→ Creating ~/.zshrc.local if missing..."
if [[ ! -f ~/.zshrc.local ]]; then
  cat > ~/.zshrc.local << 'EOF'
# Machine-specific secrets and aliases — not tracked by git
EOF
fi

echo ""
echo "DONE! Next steps:"
echo "  1. Add secrets to ~/.zshrc.local"
echo "  2. Log out → select i3 session"
echo "  3. Open nvim → plugins auto-install"
echo "  4. Run :MasonInstall clangd pyright inside nvim"
