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
    fi
    
    # Apply AWS fix for p10k if available
    if [[ -f "/home/mike/github/wsldesktop/p10k-aws-fix.sh" ]]; then
        info "Applying AWS fix for Powerlevel10k..."
        bash "/home/mike/github/wsldesktop/p10k-aws-fix.sh"
    fi
    
    info "Theme and fonts setup complete"
}
