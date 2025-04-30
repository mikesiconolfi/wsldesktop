#!/bin/bash

# AWS Power User WSL Setup Script - Main Script
# This script provides a modular setup for AWS development on WSL
# Users can select which components they want to install

# Source common functions
source "$(dirname "$0")/modules/00_common.sh"

# Display welcome message
section "AWS Power User WSL Setup"
info "This script will set up your WSL environment for AWS development"
info "You can select which components to install"

# Check dependencies
check_dependencies || {
    error "Failed to install required dependencies. Please install them manually and try again."
    exit 1
}

# Menu for component selection
select_components() {
    local options=(
        "Base System (ZSH, Oh My Zsh, basic packages)"
        "Theme and Fonts (Powerlevel10k, Powerline fonts)"
        "AWS CLI and Tools"
        "Docker and Container Tools"
        "Kubernetes and EKS Tools"
        "Terraform"
        "AWS Session Manager"
        "Modern CLI Tools"
        "1Password Integration"
        "AWS Development Tools"
        "ZSH Configuration"
        "All Components"
    )
    
    local selected=()
    
    echo "Select components to install (use space to select/deselect, enter to confirm):"
    selected=($(for i in "${!options[@]}"; do echo "$i ${options[$i]}"; done | fzf --multi --height=50% --reverse --header="Space to select, Enter to confirm" | awk '{print $1}'))
    
    # Check if "All Components" was selected
    if [[ " ${selected[*]} " =~ " 11 " ]]; then
        selected=(0 1 2 3 4 5 6 7 8 9 10)
    fi
    
    echo "${selected[@]}"
}

# Install selected components
install_selected_components() {
    local selected=("$@")
    
    for component in "${selected[@]}"; do
        case $component in
            0)
                source "$(dirname "$0")/modules/01_base_system.sh"
                install_base_system
                ;;
            1)
                source "$(dirname "$0")/modules/02_theme_fonts.sh"
                install_theme_and_fonts
                ;;
            2)
                source "$(dirname "$0")/modules/03_aws_cli.sh"
                install_aws_cli
                ;;
            3)
                source "$(dirname "$0")/modules/04_docker.sh"
                install_docker
                ;;
            4)
                source "$(dirname "$0")/modules/05_kubernetes.sh"
                install_kubernetes
                ;;
            5)
                source "$(dirname "$0")/modules/06_terraform.sh"
                install_terraform
                ;;
            6)
                source "$(dirname "$0")/modules/07_session_manager.sh"
                install_session_manager
                ;;
            7)
                source "$(dirname "$0")/modules/08_modern_cli.sh"
                install_modern_cli
                ;;
            8)
                source "$(dirname "$0")/modules/09_1password.sh"
                install_1password
                ;;
            9)
                source "$(dirname "$0")/modules/10_aws_dev_tools.sh"
                install_aws_dev_tools
                ;;
            10)
                source "$(dirname "$0")/modules/11_zsh_config.sh"
                configure_zsh
                ;;
        esac
    done
}

# Main function
main() {
    # Select components to install
    local selected_components=($(select_components))
    
    if [[ ${#selected_components[@]} -eq 0 ]]; then
        info "No components selected. Exiting."
        exit 0
    fi
    
    # Install selected components
    install_selected_components "${selected_components[@]}"
    
    # Final message
    section "Setup Complete!"
    info "Your AWS Power User WSL environment has been set up successfully."
    info "Please restart your terminal or run 'exec zsh' to apply all changes."
    info "If you installed Powerline fonts, you may need to configure your terminal to use them."
    
    # Ask to switch to ZSH
    if confirm "Would you like to switch to ZSH now?"; then
        exec zsh -l
    fi
}

# Run main function
main
