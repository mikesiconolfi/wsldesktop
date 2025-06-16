#!/bin/bash

# File Name: setup-enhanced-aws-switcher.sh
# Relative Path: ~/github/wsldesktop/setup-enhanced-aws-switcher.sh
# Purpose: Complete setup script for enhanced AWS profile switcher with role-based selection.
# Detailed Overview: This script installs and configures the enhanced AWS profile switcher, updates
# shell configurations, applies P10K enhancements, and provides setup guidance for AWS SSO profiles.
# It ensures all components work together seamlessly for role-based AWS profile management.

# =============================================================================
# ENHANCED AWS PROFILE SWITCHER SETUP SCRIPT
# =============================================================================

set -euo pipefail

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m' # No Color

print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

print_header() {
    echo
    print_color "$CYAN" "═══════════════════════════════════════════════════════════════"
    print_color "$WHITE" "  $1"
    print_color "$CYAN" "═══════════════════════════════════════════════════════════════"
}

print_success() { print_color "$GREEN" "✓ $1"; }
print_error() { print_color "$RED" "✗ $1"; }
print_warning() { print_color "$YELLOW" "⚠ $1"; }
print_info() { print_color "$BLUE" "ℹ $1"; }

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

print_header "Enhanced AWS Profile Switcher Setup"

# Check prerequisites
print_info "Checking prerequisites..."

if ! command_exists aws; then
    print_error "AWS CLI not found. Please install AWS CLI first."
    exit 1
fi

if ! command_exists fzf; then
    print_warning "fzf not found. Installing fzf for better user experience..."
    if command_exists apt; then
        sudo apt update && sudo apt install -y fzf
    elif command_exists yum; then
        sudo yum install -y fzf
    elif command_exists brew; then
        brew install fzf
    else
        print_warning "Could not install fzf automatically. Please install it manually for the best experience."
    fi
fi

if ! command_exists jq; then
    print_warning "jq not found. Installing jq for JSON parsing..."
    if command_exists apt; then
        sudo apt update && sudo apt install -y jq
    elif command_exists yum; then
        sudo yum install -y jq
    elif command_exists brew; then
        brew install jq
    else
        print_warning "Could not install jq automatically. Please install it manually."
    fi
fi

print_success "Prerequisites checked"

# Backup existing configurations
print_info "Creating backups of existing configurations..."

BACKUP_DIR="$HOME/.aws_switcher_backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup existing files
[[ -f "$HOME/.aws_profile_switcher" ]] && cp "$HOME/.aws_profile_switcher" "$BACKUP_DIR/"
[[ -f "$HOME/.aws/config" ]] && cp "$HOME/.aws/config" "$BACKUP_DIR/"
[[ -f "$HOME/.zshrc" ]] && cp "$HOME/.zshrc" "$BACKUP_DIR/"
[[ -f "$HOME/.bashrc" ]] && cp "$HOME/.bashrc" "$BACKUP_DIR/"

print_success "Backups created in $BACKUP_DIR"

# The enhanced AWS profile switcher is already created, so we just need to ensure it's sourced
print_info "Configuring shell integration..."

# Add sourcing to .zshrc if it exists and not already present
if [[ -f "$HOME/.zshrc" ]]; then
    if ! grep -q "source.*\.aws_profile_switcher" "$HOME/.zshrc"; then
        echo "" >> "$HOME/.zshrc"
        echo "# Enhanced AWS Profile Switcher" >> "$HOME/.zshrc"
        echo "if [[ -f ~/.aws_profile_switcher ]]; then" >> "$HOME/.zshrc"
        echo "    source ~/.aws_profile_switcher" >> "$HOME/.zshrc"
        echo "fi" >> "$HOME/.zshrc"
        print_success "Added AWS profile switcher to .zshrc"
    else
        print_info "AWS profile switcher already configured in .zshrc"
    fi
fi

# Add sourcing to .bashrc if it exists and not already present
if [[ -f "$HOME/.bashrc" ]]; then
    if ! grep -q "source.*\.aws_profile_switcher" "$HOME/.bashrc"; then
        echo "" >> "$HOME/.bashrc"
        echo "# Enhanced AWS Profile Switcher" >> "$HOME/.bashrc"
        echo "if [[ -f ~/.aws_profile_switcher ]]; then" >> "$HOME/.bashrc"
        echo "    source ~/.aws_profile_switcher" >> "$HOME/.bashrc"
        echo "fi" >> "$HOME/.bashrc"
        print_success "Added AWS profile switcher to .bashrc"
    else
        print_info "AWS profile switcher already configured in .bashrc"
    fi
fi

# Apply P10K enhancements if P10K is installed
if [[ -f "$HOME/.p10k.zsh" ]]; then
    print_info "Applying Powerlevel10k enhancements..."
    if [[ -f "$(dirname "$0")/p10k-aws-role-enhancement.sh" ]]; then
        bash "$(dirname "$0")/p10k-aws-role-enhancement.sh"
    else
        print_warning "P10K enhancement script not found. Skipping P10K configuration."
    fi
else
    print_info "Powerlevel10k not detected. Skipping P10K enhancements."
fi

# Create AWS config directory if it doesn't exist
mkdir -p "$HOME/.aws"

# Check if AWS config exists, if not, offer to create from template
if [[ ! -f "$HOME/.aws/config" ]]; then
    print_warning "AWS config file not found."
    echo -n "Would you like to create a sample AWS config with role-based profiles? (y/n): "
    read -r create_config
    
    if [[ "$create_config" =~ ^[Yy]$ ]]; then
        if [[ -f "$HOME/.aws/config.template" ]]; then
            cp "$HOME/.aws/config.template" "$HOME/.aws/config"
            print_success "Sample AWS config created from template"
            print_warning "Please edit ~/.aws/config and update the placeholder values:"
            print_info "  - Replace 'your-company.awsapps.com/start' with your SSO start URL"
            print_info "  - Replace account IDs with your actual account IDs"
            print_info "  - Update role names to match your available roles"
        else
            print_error "AWS config template not found. Please create ~/.aws/config manually."
        fi
    fi
else
    print_info "Existing AWS config found. Please review it for role-based profiles."
fi

print_header "Setup Complete!"

print_success "Enhanced AWS Profile Switcher has been installed and configured."

echo
print_info "Available Commands:"
print_info "  awsp              - Interactive profile switcher with role selection"
print_info "  awsrole           - Switch roles within current account"
print_info "  awsquick <role>   - Quick switch (admin, readonly, poweruser, dev)"
print_info "  awsperms          - Display current permissions and role info"
print_info "  awsaccounts       - List all accounts and available roles"
print_info "  awshelp           - Show detailed help"

echo
print_info "Quick Role Aliases:"
print_info "  awsp-admin        - Switch to administrator role"
print_info "  awsp-readonly     - Switch to read-only role"
print_info "  awsp-poweruser    - Switch to power user role"
print_info "  awsp-dev          - Switch to developer role"

echo
print_header "Next Steps"

print_warning "1. Restart your shell or run: source ~/.zshrc (or ~/.bashrc)"

if [[ -f "$HOME/.aws/config.template" ]]; then
    print_warning "2. Edit ~/.aws/config and update placeholder values:"
    print_info "   - SSO start URL"
    print_info "   - Account IDs"
    print_info "   - Role names"
fi

print_warning "3. Configure your AWS SSO profiles:"
print_info "   - Log into your AWS SSO portal to get the start URL"
print_info "   - Note available roles for each account"
print_info "   - Update ~/.aws/config with your specific values"

print_warning "4. Test the setup:"
print_info "   - Run 'awshelp' to see all available commands"
print_info "   - Run 'awsp' to test profile switching"
print_info "   - Run 'awsperms' to check current permissions"

echo
print_header "AWS Config Template Location"
print_info "Template: ~/.aws/config.template"
print_info "Active config: ~/.aws/config"
print_info "Backups: $BACKUP_DIR"

echo
print_header "Troubleshooting"
print_info "If you encounter issues:"
print_info "1. Check AWS CLI installation: aws --version"
print_info "2. Verify AWS config syntax: aws configure list-profiles"
print_info "3. Test SSO login: aws sso login --profile <profile-name>"
print_info "4. Check function loading: type awsp"

echo
print_success "Setup completed successfully! Enjoy your enhanced AWS profile switcher with role-based selection."

# Source the profile switcher in the current session if possible
if [[ -f "$HOME/.aws_profile_switcher" ]]; then
    print_info "Loading AWS profile switcher in current session..."
    # shellcheck source=/dev/null
    source "$HOME/.aws_profile_switcher" 2>/dev/null || print_warning "Could not load in current session. Please restart your shell."
fi
