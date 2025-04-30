#!/bin/bash

# AWS Power User WSL Setup Script - Main Script
# This script provides a modular setup for AWS development on WSL
# Users can select which components they want to install

# Source common functions
source "$(dirname "$0")/modules/00_common.sh"

# Initialize log file
init_log

# Display welcome message
section "AWS Power User WSL Setup"
info "This script will set up your WSL environment for AWS development"
info "You can select which components to install"
info "Installation log will be saved to: $LOG_FILE"

# Check for stale lock files
if pgrep -f "apt-get|dpkg" > /dev/null; then
    info "Checking for package manager processes..."
    ps_output=$(ps aux | grep -E 'apt-get|dpkg' | grep -v grep)
    echo "$ps_output" >> "$LOG_FILE"
    
    if [[ -n "$ps_output" ]]; then
        info "Found the following package manager processes:"
        echo "$ps_output"
        info "You can either:"
        info "1. Wait for these processes to complete"
        info "2. Terminate them if safe to do so: sudo kill <PID>"
        info "3. Run with IGNORE_LOCKS=1 to bypass (if you're sure it's safe):"
        info "   IGNORE_LOCKS=1 ./setup-aws-wsl.sh"
    else
        info "No actual package manager processes found, but lock detection triggered."
        info "This might be due to stale lock files. You can try:"
        info "1. Run with IGNORE_LOCKS=1 to bypass: IGNORE_LOCKS=1 ./setup-aws-wsl.sh"
        info "2. Remove lock files (if you're sure no apt process is running):"
        info "   sudo rm /var/lib/apt/lists/lock"
        info "   sudo rm /var/lib/dpkg/lock"
        info "   sudo rm /var/lib/dpkg/lock-frontend"
    fi
fi

# Check dependencies
check_dependencies || {
    error "Failed to install required prerequisites. Please fix the issues and try again."
    info "Check the log file for details: $LOG_FILE"
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
    
    # Create a temporary file for fzf output
    local tmp_file=$(mktemp)
    
    # Use process substitution to capture fzf output
    echo "Select components to install (use SPACE to select/deselect, ENTER to confirm):"
    
    # Run fzf with explicit --bind for space to toggle selection
    # and write results to the temporary file
    (for i in "${!options[@]}"; do 
        echo "$i ${options[$i]}"
    done) | fzf --multi \
              --height=50% \
              --reverse \
              --header="SPACE to select/deselect, ENTER to confirm" \
              --bind="space:toggle+down" \
              > "$tmp_file"
    
    # Read selected items from the temporary file
    while read -r line; do
        selected+=($(echo "$line" | awk '{print $1}'))
    done < "$tmp_file"
    
    # Clean up
    rm "$tmp_file"
    
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
        echo "No components selected. Installation aborted." >> "$LOG_FILE"
        exit 0
    fi
    
    # Log selected components
    echo "Selected components: ${selected_components[*]}" >> "$LOG_FILE"
    
    # Install selected components
    install_selected_components "${selected_components[@]}"
    
    # Final message
    section "Setup Complete!"
    info "Your AWS Power User WSL environment has been set up successfully."
    info "Please restart your terminal or run 'exec zsh' to apply all changes."
    info "If you installed Powerline fonts, you may need to configure your terminal to use them."
    info "Installation log has been saved to: $LOG_FILE"
    
    # Log completion
    echo "=== Installation completed successfully at $(date) ===" >> "$LOG_FILE"
    
    # Ask to switch to ZSH
    if confirm "Would you like to switch to ZSH now?"; then
        echo "User chose to switch to ZSH" >> "$LOG_FILE"
        exec zsh -l
    else
        echo "User chose not to switch to ZSH" >> "$LOG_FILE"
    fi
}

# Run main function
main
