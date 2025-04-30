#!/bin/bash

# Base system setup - ZSH, Oh My Zsh, and basic system packages

install_base_system() {
    section "Setting up base system"
    
    # Update package lists
    info "Updating package lists..."
    sudo apt-get update
    
    # Install basic packages
    info "Installing basic packages..."
    sudo apt-get install -y \
        zsh \
        git \
        curl \
        wget \
        unzip \
        jq \
        python3 \
        python3-pip \
        build-essential \
        apt-transport-https \
        ca-certificates \
        gnupg \
        lsb-release
    
    # Install Oh My Zsh if not already installed
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        info "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        info "Oh My Zsh already installed"
    fi
    
    # Install ZSH plugins
    info "Installing ZSH plugins..."
    
    # zsh-autosuggestions
    if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    fi
    
    # zsh-syntax-highlighting
    if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    fi
    
    info "Base system setup complete"
}
