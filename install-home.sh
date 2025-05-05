#!/bin/bash
#
#TODO: Add papirus installation command.

# This script does not work unless executed from its folder
if ! ls "$PWD/$(basename $0)" >/dev/null 2>&1; then
    echo 'execute this script from its location'
    exit 1
fi

# List of required packages to check
required_packages=("curl" "git" "zsh" "vim")  # Replace these with your actual package names
missing_packages=()

# Function to check if a package is installed
check_package() {
  if ! dpkg -l | grep -q "$1"; then
    missing_packages+=("$1")
  fi
}

# Check each package
for package in "${required_packages[@]}"; do
  check_package "$package"
done

# If there are missing packages, print them and exit with error code
if [ ${#missing_packages[@]} -gt 0 ]; then
  echo "The following packages are missing:"
  for missing in "${missing_packages[@]}"; do
    echo "- $missing"
  done
  exit 1
else
  echo "All required packages are installed."
  #exit 0
fi

# Install Vundle (Vim plugin Manager) if it's not installed.
repo_path="$HOME/.vim/bundle/Vundle.vim"  # Change this to your desired directory
repo_url="https://github.com/VundleVim/Vundle.vim.git"  # Change this to your Git repository URL

# Check if the repository directory exists and is a Git repository
if [ -d "$repo_path" ] && [ -d "$repo_path/.git" ]; then
  echo "The Git repository already exists at $repo_path."
else
  echo "The repository does not exist. Cloning from $repo_url..."
  
  # Clone the repository from the URL
  git clone "$repo_url" "$repo_path"
  
  if [ $? -eq 0 ]; then
    echo "Repository cloned successfully to $repo_path."
  else
    echo "Failed to clone the repository."
    #exit 1
  fi
fi

# Install starship shell theme
curl -sS https://starship.rs/install.sh | sh


# Create your local share folder if it doesn't exist
if ! ls "$HOME/.local/share" >/dev/null 2>&1; then
    mkdir -p $HOME/.local/share
fi

if ! ls "$HOME/.local/share/fonts" >/dev/null 2>&1; then
    mkdir -p $HOME/.local/share/fonts
fi

# Copy Nerd Fonts
cp -f $PWD/fonts/* $HOME/.local/share/fonts

# Link files to your home directory
ln -sf $PWD/zsh $HOME/.local/share/
ln -sf $PWD/zshrc $HOME/.zshrc
ln -sf $PWD/vimrc $HOME/.vimrc
ln -sf $PWD/starship.toml $HOME/.config/

# Get the current user
current_user=$(whoami)

# Check if the user's default shell is /bin/zsh
if grep -q "^$current_user:.*$zsh_path" /etc/passwd; then
  echo "Zsh is already the current default shell for $current_user."
else
  echo "Current shell is not zsh. Changing default shell to $zsh_path."
  
  # Change the default shell to zsh
  sudo chsh -s "$zsh_path" "$current_user"
fi

