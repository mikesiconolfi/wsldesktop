#!/bin/bash

# ZSH configuration setup

configure_zsh() {
    section "Setting up ZSH configuration"
    
    # Backup existing .zshrc if it exists
    backup_file "$HOME/.zshrc"
    
    # Create new .zshrc
    info "Creating .zshrc configuration..."
    cat > "$HOME/.zshrc" << 'EOF'
# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Set theme to Powerlevel10k
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set plugins
plugins=(
  git
  aws
  docker
  kubectl
  terraform
  vscode
  npm
  python
  pip
  zsh-autosuggestions
  zsh-syntax-highlighting
)

# Source oh-my-zsh
source $ZSH/oh-my-zsh.sh

# User configuration
export LANG=en_US.UTF-8
export EDITOR='vim'

# Path configuration
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.npm-global/bin:$PATH"

# Source Powerlevel10k configuration
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# Source AWS profile switcher
[[ -f ~/.aws_profile_switcher ]] && source ~/.aws_profile_switcher

# Source Docker aliases
[[ -f ~/.docker_aliases ]] && source ~/.docker_aliases

# Source ECR functions
[[ -f ~/.ecr_functions ]] && source ~/.ecr_functions

# Source Terraform functions
[[ -f ~/.terraform_functions ]] && source ~/.terraform_functions

# Source Session Manager functions
[[ -f ~/.session_manager_functions ]] && source ~/.session_manager_functions

# Source EKS functions
[[ -f ~/.eks_functions ]] && source ~/.eks_functions

# Source Kubernetes aliases
[[ -f ~/.kubernetes_aliases ]] && source ~/.kubernetes_aliases

# Source modern CLI aliases
[[ -f ~/.modern_cli_aliases ]] && source ~/.modern_cli_aliases

# Source 1Password functions
[[ -f ~/.1password_functions ]] && source ~/.1password_functions

# Source 1Password path
[[ -f ~/.1password_path ]] && source ~/.1password_path

# Source AWS development tool aliases
[[ -f ~/.aws_dev_tools_aliases ]] && source ~/.aws_dev_tools_aliases

# Setup direnv
if command -v direnv &> /dev/null; then
  eval "$(direnv hook zsh)"
fi

# Setup fzf
if command -v fzf &> /dev/null; then
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
fi

# Welcome message
echo "AWS Power User WSL Environment loaded!"
echo "Type 'awsp' to switch AWS profiles"
echo "Type 'awsregion' to switch AWS regions"
EOF
    
    info "ZSH configuration setup complete"
}
