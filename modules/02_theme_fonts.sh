#!/bin/bash

# Theme and fonts setup - Powerlevel10k and Powerline fonts

install_theme_and_fonts() {
    section "Setting up theme and fonts"
    
    # Install Powerlevel10k theme
    if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]]; then
        info "Installing Powerlevel10k theme..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    else
        info "Powerlevel10k theme already installed"
    fi
    
    # Install Powerline fonts
    info "Installing Powerline fonts..."
    if [[ ! -d "$HOME/powerline-fonts" ]]; then
        git clone --depth=1 https://github.com/powerline/fonts.git "$HOME/powerline-fonts"
        cd "$HOME/powerline-fonts"
        ./install.sh
        cd - > /dev/null
    else
        info "Powerline fonts already installed"
    fi
    
    # Configure p10k
    info "Setting up Powerlevel10k configuration..."
    if [[ ! -f "$HOME/.p10k.zsh" ]]; then
        curl -fsSL -o "$HOME/.p10k.zsh" https://raw.githubusercontent.com/romkatv/powerlevel10k/master/config/p10k-lean.zsh
        
        # Add AWS profile to prompt
        sed -i 's/typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(/typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(\n    aws\n    /' "$HOME/.p10k.zsh"
        
        # Configure AWS segment to always show
        cat >> "$HOME/.p10k.zsh" << 'EOF'

# AWS profile configuration
# Note: We don't set POWERLEVEL9K_AWS_SHOW_ON_COMMAND to use default behavior
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
    
    # Apply AWS fix for p10k if available
    if [[ -f "/home/mike/github/wsldesktop/p10k-aws-fix.sh" ]]; then
        info "Applying AWS fix for Powerlevel10k..."
        bash "/home/mike/github/wsldesktop/p10k-aws-fix.sh"
    fi
    
    info "Theme and fonts setup complete"
}
