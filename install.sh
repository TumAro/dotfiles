#!/usr/bin/env bash
set -e
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "→ Installing packages..."
sudo apt update -qq
sudo apt install -y \
  zsh git curl wget stow fzf ripgrep fd-find bat \
  i3 i3status rofi picom xclip \
  build-essential cmake python3 python3-pip \
  fontconfig

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

echo "→ bat symlink..."
mkdir -p ~/.local/bin
ln -sf /usr/bin/batcat ~/.local/bin/bat

echo "→ Linking dotfiles..."
cd "$DOTFILES"
for pkg in zsh kitty nvim i3 git yazi; do
  mkdir -p "$HOME/.config"
  # manual symlink to avoid stow bugs
  case $pkg in
  zsh) ln -sf "$DOTFILES/zsh/.zshrc" "$HOME/.zshrc" ;;
  kitty) ln -sf "$DOTFILES/kitty/.config/kitty" "$HOME/.config/kitty" ;;
  nvim) ln -sf "$DOTFILES/nvim/.config/nvim" "$HOME/.config/nvim" ;;
  i3) ln -sf "$DOTFILES/i3/.config/i3" "$HOME/.config/i3" ;;
  git) ln -sf "$DOTFILES/git/.gitconfig" "$HOME/.gitconfig" ;;
  yazi) ln -sf "$DOTFILES/yazi/.config/yazi" "$HOME/.config/yazi" ;;
  esac
  echo "  ✓ $pkg"
done

echo "→ Setting zsh as default shell..."
chsh -s "$(which zsh)"

echo "→ Creating ~/.zshrc.local if missing..."
if [[ ! -f ~/.zshrc.local ]]; then
  cat >~/.zshrc.local <<'EOF'
# Machine-specific secrets and aliases — not tracked by git
# Add your API keys, local paths, app aliases here
EOF
fi

echo ""
echo "DONE! Next steps:"
echo "  1. Add secrets to ~/.zshrc.local"
echo "  2. Log out → select i3 session"
echo "  3. Open nvim → plugins auto-install"
echo "  4. Run $(:MasonInstall clangd pyright marksman) inside nvim"
