#!/bin/bash

# ZSH configuration setup

configure_zsh() {
    section "Setting up ZSH configuration"
    
    # Verify Oh My Zsh is properly installed
    if [[ ! -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]]; then
        error "Oh My Zsh main script is missing. Attempting to fix..."
        
        # Download the main script directly
        curl -fsSL -o "$HOME/.oh-my-zsh/oh-my-zsh.sh" https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/oh-my-zsh.sh
        chmod +x "$HOME/.oh-my-zsh/oh-my-zsh.sh"
        
        # Check if the download was successful
        if [[ ! -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]]; then
            error "Failed to download Oh My Zsh main script. ZSH configuration may not work properly."
            info "You may need to reinstall Oh My Zsh manually: sh -c \"$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""
            return 1
        fi
    fi
    
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
if [[ -f "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
else
  echo "Warning: Oh My Zsh main script not found at $ZSH/oh-my-zsh.sh"
fi

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
    
    # Add AWS profile to prompt
    if [[ -f "$HOME/.p10k.zsh" ]]; then
        info "Ensuring AWS profile is shown in prompt..."
        if ! grep -q "aws" "$HOME/.p10k.zsh"; then
            sed -i 's/typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(/typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(\n    aws\n    /' "$HOME/.p10k.zsh"
        fi
        
        # Configure AWS segment to always show if not already configured
        if ! grep -q "POWERLEVEL9K_AWS_SHOW_ON_COMMAND=''" "$HOME/.p10k.zsh"; then
            info "Configuring AWS prompt segment to always show..."
            cat >> "$HOME/.p10k.zsh" << 'EOF'

# AWS profile configuration
typeset -g POWERLEVEL9K_AWS_SHOW_ON_COMMAND=''  # Always show AWS profile
typeset -g POWERLEVEL9K_AWS_CLASSES=(
  '*prod*' PROD
  '*stg*' STG
  '*dev*' DEV
  '*' DEFAULT
)
typeset -g POWERLEVEL9K_AWS_DEFAULT_FOREGROUND=7
typeset -g POWERLEVEL9K_AWS_DEFAULT_BACKGROUND=1
typeset -g POWERLEVEL9K_AWS_PROD_FOREGROUND=0
typeset -g POWERLEVEL9K_AWS_PROD_BACKGROUND=1
typeset -g POWERLEVEL9K_AWS_DEV_FOREGROUND=0
typeset -g POWERLEVEL9K_AWS_DEV_BACKGROUND=2
typeset -g POWERLEVEL9K_AWS_STG_FOREGROUND=0
typeset -g POWERLEVEL9K_AWS_STG_BACKGROUND=3
EOF
        fi
    fi
    
    # Add Python virtual environment to PATH
    add_venv_to_path
    
    info "ZSH configuration setup complete"
}
