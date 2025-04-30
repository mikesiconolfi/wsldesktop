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
    
    # Install Oh My Zsh if not already installed or if it's incomplete
    if [[ ! -d "$HOME/.oh-my-zsh" ]] || [[ ! -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]]; then
        info "Installing Oh My Zsh..."
        
        # Backup custom folder if it exists
        if [[ -d "$HOME/.oh-my-zsh/custom" ]]; then
            info "Backing up existing custom folder..."
            cp -r "$HOME/.oh-my-zsh/custom" "$HOME/oh-my-zsh-custom-backup"
        fi
        
        # Remove existing incomplete installation if it exists
        if [[ -d "$HOME/.oh-my-zsh" ]]; then
            info "Removing incomplete Oh My Zsh installation..."
            rm -rf "$HOME/.oh-my-zsh"
        fi
        
        # Install Oh My Zsh
        info "Downloading and installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        
        # Restore custom folder if backup exists
        if [[ -d "$HOME/oh-my-zsh-custom-backup" ]]; then
            info "Restoring custom folder..."
            rm -rf "$HOME/.oh-my-zsh/custom"
            cp -r "$HOME/oh-my-zsh-custom-backup" "$HOME/.oh-my-zsh/custom"
            rm -rf "$HOME/oh-my-zsh-custom-backup"
        fi
        
        # Verify installation
        if [[ ! -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]]; then
            error "Oh My Zsh installation failed. Downloading main script directly..."
            curl -fsSL -o "$HOME/.oh-my-zsh/oh-my-zsh.sh" https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/oh-my-zsh.sh
            chmod +x "$HOME/.oh-my-zsh/oh-my-zsh.sh"
        fi
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
