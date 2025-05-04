#!/bin/bash

# Uninstall/Revert Module for WSL Desktop Setup
# This module provides functionality to uninstall components or revert to previous configurations

# Function to uninstall base system components
uninstall_base_system() {
    section "Uninstalling Base System Components"
    
    # Restore original shell if it was changed
    if [[ "$SHELL" == *"zsh"* ]]; then
        if confirm "Would you like to revert to bash as your default shell?"; then
            chsh -s $(which bash)
            info "Default shell reverted to bash"
        fi
    fi
    
    # Remove Oh My Zsh if installed
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        if confirm "Would you like to uninstall Oh My Zsh?"; then
            info "Uninstalling Oh My Zsh..."
            if [[ -f "$HOME/.oh-my-zsh/tools/uninstall.sh" ]]; then
                sh "$HOME/.oh-my-zsh/tools/uninstall.sh" -y
                info "Oh My Zsh uninstalled"
            else
                rm -rf "$HOME/.oh-my-zsh"
                info "Oh My Zsh directory removed"
            fi
        fi
    fi
    
    info "Base system uninstall complete"
}

# Function to uninstall theme and fonts
uninstall_theme_fonts() {
    section "Uninstalling Theme and Fonts"
    
    # Remove Powerlevel10k theme
    if [[ -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]]; then
        if confirm "Would you like to remove the Powerlevel10k theme?"; then
            rm -rf "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
            info "Powerlevel10k theme removed"
        fi
    fi
    
    # Remove Powerline fonts
    if [[ -d "$HOME/.local/share/fonts/powerline" ]]; then
        if confirm "Would you like to remove Powerline fonts?"; then
            rm -rf "$HOME/.local/share/fonts/powerline"
            fc-cache -f -v > /dev/null
            info "Powerline fonts removed"
        fi
    fi
    
    info "Theme and fonts uninstall complete"
}

# Function to uninstall AWS CLI and tools
uninstall_aws_cli() {
    section "Uninstalling AWS CLI and Tools"
    
    # Uninstall AWS CLI v2
    if command_exists aws; then
        if confirm "Would you like to uninstall AWS CLI v2?"; then
            info "Uninstalling AWS CLI v2..."
            if [[ -f "/usr/local/bin/aws" ]]; then
                sudo rm /usr/local/bin/aws
                sudo rm /usr/local/bin/aws_completer
                sudo rm -rf /usr/local/aws-cli
                info "AWS CLI v2 uninstalled"
            fi
        fi
    fi
    
    # Restore AWS config backups if they exist
    if confirm "Would you like to restore AWS configuration backups (if available)?"; then
        # Find the most recent backup of AWS config
        local aws_config_backup=$(find "$HOME/.aws" -name "config.bak.*" -type f | sort -r | head -n 1)
        local aws_credentials_backup=$(find "$HOME/.aws" -name "credentials.bak.*" -type f | sort -r | head -n 1)
        
        if [[ -n "$aws_config_backup" ]]; then
            cp "$aws_config_backup" "$HOME/.aws/config"
            info "Restored AWS config from $aws_config_backup"
        fi
        
        if [[ -n "$aws_credentials_backup" ]]; then
            cp "$aws_credentials_backup" "$HOME/.aws/credentials"
            info "Restored AWS credentials from $aws_credentials_backup"
        fi
    fi
    
    info "AWS CLI and tools uninstall complete"
}

# Function to uninstall Docker and container tools
uninstall_docker() {
    section "Uninstalling Docker and Container Tools"
    
    if command_exists docker; then
        if confirm "Would you like to uninstall Docker?"; then
            info "Uninstalling Docker..."
            sudo apt-get purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            sudo rm -rf /var/lib/docker
            sudo rm -rf /var/lib/containerd
            info "Docker uninstalled"
        fi
    fi
    
    # Remove Docker Compose if installed separately
    if command_exists docker-compose; then
        if confirm "Would you like to uninstall Docker Compose?"; then
            sudo rm -f /usr/local/bin/docker-compose
            info "Docker Compose uninstalled"
        fi
    fi
    
    info "Docker and container tools uninstall complete"
}

# Function to uninstall Kubernetes and EKS tools
uninstall_kubernetes() {
    section "Uninstalling Kubernetes and EKS Tools"
    
    # Uninstall kubectl
    if command_exists kubectl; then
        if confirm "Would you like to uninstall kubectl?"; then
            sudo rm -f /usr/local/bin/kubectl
            info "kubectl uninstalled"
        fi
    fi
    
    # Uninstall eksctl
    if command_exists eksctl; then
        if confirm "Would you like to uninstall eksctl?"; then
            sudo rm -f /usr/local/bin/eksctl
            info "eksctl uninstalled"
        fi
    fi
    
    # Uninstall helm
    if command_exists helm; then
        if confirm "Would you like to uninstall Helm?"; then
            sudo rm -f /usr/local/bin/helm
            info "Helm uninstalled"
        fi
    fi
    
    # Uninstall k9s
    if command_exists k9s; then
        if confirm "Would you like to uninstall k9s?"; then
            sudo rm -f /usr/local/bin/k9s
            info "k9s uninstalled"
        fi
    fi
    
    # Uninstall kubectx and kubens
    if command_exists kubectx; then
        if confirm "Would you like to uninstall kubectx and kubens?"; then
            sudo rm -f /usr/local/bin/kubectx
            sudo rm -f /usr/local/bin/kubens
            info "kubectx and kubens uninstalled"
        fi
    fi
    
    # Restore kubeconfig backup if it exists
    if confirm "Would you like to restore kubeconfig backup (if available)?"; then
        local kube_config_backup=$(find "$HOME/.kube" -name "config.bak.*" -type f | sort -r | head -n 1)
        
        if [[ -n "$kube_config_backup" ]]; then
            cp "$kube_config_backup" "$HOME/.kube/config"
            info "Restored kubeconfig from $kube_config_backup"
        fi
    fi
    
    info "Kubernetes and EKS tools uninstall complete"
}

# Function to uninstall Terraform
uninstall_terraform() {
    section "Uninstalling Terraform"
    
    if command_exists terraform; then
        if confirm "Would you like to uninstall Terraform?"; then
            sudo rm -f /usr/local/bin/terraform
            info "Terraform uninstalled"
        fi
    fi
    
    info "Terraform uninstall complete"
}

# Function to uninstall Session Manager
uninstall_session_manager() {
    section "Uninstalling Session Manager"
    
    if [[ -f "$HOME/.local/lib/aws-cli/bin/session-manager-plugin" ]]; then
        if confirm "Would you like to uninstall AWS Session Manager plugin?"; then
            sudo rm -f /usr/local/bin/session-manager-plugin
            rm -rf "$HOME/.local/lib/aws-cli/bin/session-manager-plugin"
            info "AWS Session Manager plugin uninstalled"
        fi
    fi
    
    info "Session Manager uninstall complete"
}

# Function to uninstall Modern CLI tools
uninstall_modern_cli() {
    section "Uninstalling Modern CLI Tools"
    
    # Uninstall bat
    if command_exists bat; then
        if confirm "Would you like to uninstall bat?"; then
            sudo apt-get purge -y bat
            info "bat uninstalled"
        fi
    fi
    
    # Uninstall exa/eza
    if command_exists exa || command_exists eza; then
        if confirm "Would you like to uninstall exa/eza?"; then
            sudo apt-get purge -y exa
            sudo rm -f /usr/local/bin/eza
            info "exa/eza uninstalled"
        fi
    fi
    
    # Uninstall fzf
    if command_exists fzf; then
        if confirm "Would you like to uninstall fzf?"; then
            if [[ -f "$HOME/.fzf/uninstall" ]]; then
                "$HOME/.fzf/uninstall" --all
            else
                sudo apt-get purge -y fzf
            fi
            info "fzf uninstalled"
        fi
    fi
    
    # Uninstall direnv
    if command_exists direnv; then
        if confirm "Would you like to uninstall direnv?"; then
            sudo apt-get purge -y direnv
            info "direnv uninstalled"
        fi
    fi
    
    # Uninstall tldr
    if command_exists tldr; then
        if confirm "Would you like to uninstall tldr?"; then
            npm uninstall -g tldr
            info "tldr uninstalled"
        fi
    fi
    
    info "Modern CLI tools uninstall complete"
}

# Function to uninstall 1Password integration
uninstall_1password() {
    section "Uninstalling 1Password Integration"
    
    if command_exists op; then
        if confirm "Would you like to uninstall 1Password CLI?"; then
            sudo rm -f /usr/local/bin/op
            info "1Password CLI uninstalled"
        fi
    fi
    
    info "1Password integration uninstall complete"
}

# Function to uninstall AWS Development Tools
uninstall_aws_dev_tools() {
    section "Uninstalling AWS Development Tools"
    
    # Uninstall AWS SAM CLI
    if command_exists sam; then
        if confirm "Would you like to uninstall AWS SAM CLI?"; then
            pip uninstall -y aws-sam-cli
            info "AWS SAM CLI uninstalled"
        fi
    fi
    
    # Uninstall AWS CDK
    if command_exists cdk; then
        if confirm "Would you like to uninstall AWS CDK?"; then
            npm uninstall -g aws-cdk
            info "AWS CDK uninstalled"
        fi
    fi
    
    # Uninstall Serverless Framework
    if command_exists serverless; then
        if confirm "Would you like to uninstall Serverless Framework?"; then
            npm uninstall -g serverless
            info "Serverless Framework uninstalled"
        fi
    fi
    
    # Uninstall AWS Amplify CLI
    if command_exists amplify; then
        if confirm "Would you like to uninstall AWS Amplify CLI?"; then
            npm uninstall -g @aws-amplify/cli
            info "AWS Amplify CLI uninstalled"
        fi
    fi
    
    info "AWS Development Tools uninstall complete"
}

# Function to revert ZSH configuration
revert_zsh_config() {
    section "Reverting ZSH Configuration"
    
    # Restore .zshrc backup if it exists
    local zshrc_backup=$(find "$HOME" -name ".zshrc.bak.*" -type f | sort -r | head -n 1)
    
    if [[ -n "$zshrc_backup" ]]; then
        if confirm "Would you like to restore your original .zshrc from $zshrc_backup?"; then
            cp "$zshrc_backup" "$HOME/.zshrc"
            info "Restored .zshrc from $zshrc_backup"
        fi
    else
        info "No .zshrc backup found"
    fi
    
    info "ZSH configuration revert complete"
}

# Function to uninstall NeoVim
uninstall_neovim() {
    section "Uninstalling NeoVim"
    
    if command_exists nvim; then
        if confirm "Would you like to uninstall NeoVim?"; then
            sudo apt-get purge -y neovim
            info "NeoVim uninstalled"
        fi
    fi
    
    # Remove NeoVim configuration
    if [[ -d "$HOME/.config/nvim" ]]; then
        if confirm "Would you like to remove NeoVim configuration?"; then
            # Backup existing config first
            backup_file "$HOME/.config/nvim"
            rm -rf "$HOME/.config/nvim"
            info "NeoVim configuration removed"
        fi
    fi
    
    info "NeoVim uninstall complete"
}

# Main uninstall function
uninstall_wsl_desktop() {
    section "WSL Desktop Uninstall/Revert"
    info "This will help you uninstall components or revert to previous configurations"
    
    # Select components to uninstall
    local options=(
        "Base System (ZSH, Oh My Zsh)"
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
        "NeoVim"
        "Windows Nerd Fonts"
        "VSCode Nerd Fonts Configuration"
        "All Components"
    )
    
    local selected=()
    
    # Create a temporary file for fzf output
    local tmp_file=$(mktemp)
    
    # Use process substitution to capture fzf output
    echo "Select components to uninstall (use SPACE to select/deselect, ENTER to confirm):"
    
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
    if [[ " ${selected[*]} " =~ " 14 " ]]; then
        selected=(0 1 2 3 4 5 6 7 8 9 10 11 12 13)
    fi
    
    # If nothing was selected, exit
    if [[ ${#selected[@]} -eq 0 ]]; then
        info "No components selected. Exiting."
        return 0
    fi
    
    # Log selected components
    echo "Selected components for uninstall: ${selected[*]}" >> "$LOG_FILE"
    
    # Uninstall selected components
    for component in "${selected[@]}"; do
        case $component in
            0)
                uninstall_base_system
                ;;
            1)
                uninstall_theme_fonts
                ;;
            2)
                uninstall_aws_cli
                ;;
            3)
                uninstall_docker
                ;;
            4)
                uninstall_kubernetes
                ;;
            5)
                uninstall_terraform
                ;;
            6)
                uninstall_session_manager
                ;;
            7)
                uninstall_modern_cli
                ;;
            8)
                uninstall_1password
                ;;
            9)
                uninstall_aws_dev_tools
                ;;
            10)
                revert_zsh_config
                ;;
            11)
                uninstall_neovim
                ;;
            12)
                source "$(dirname "$0")/modules/14_windows_fonts.sh"
                uninstall_windows_fonts
                ;;
            13)
                source "$(dirname "$0")/modules/15_vscode_fonts.sh"
                uninstall_vscode_fonts_config
                ;;
        esac
    done
    
    # Final message
    section "Uninstall/Revert Complete!"
    info "Selected components have been uninstalled or reverted to previous configurations."
    info "You may need to restart your terminal for all changes to take effect."
    info "Uninstall log has been appended to: $LOG_FILE"
    
    # Log completion
    echo "=== Uninstall/Revert completed at $(date) ===" >> "$LOG_FILE"
}
