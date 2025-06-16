#!/bin/bash

# File Name: fix-venv.sh
# Relative Path: ~/github/wsldesktop/fix-venv.sh
# Purpose: Fix corrupted Python virtual environment for AI tools.
# Detailed Overview: This script removes and recreates the Python virtual environment
# when the directory exists but the activation script is missing or corrupted.

set -euo pipefail

readonly VENV_DIR="$HOME/.venvs/ai-tools"
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

print_success() { print_color "$GREEN" "✓ $1"; }
print_error() { print_color "$RED" "✗ $1"; }
print_warning() { print_color "$YELLOW" "⚠ $1"; }
print_info() { print_color "$BLUE" "ℹ $1"; }

echo "🔧 Fixing Python Virtual Environment"
echo "===================================="

# Check if virtual environment directory exists
if [[ -d "$VENV_DIR" ]]; then
    print_warning "Found existing virtual environment directory: $VENV_DIR"
    
    # Check if activation script exists
    if [[ ! -f "$VENV_DIR/bin/activate" ]]; then
        print_error "Activation script missing - virtual environment is corrupted"
        print_info "Removing corrupted virtual environment..."
        rm -rf "$VENV_DIR"
        print_success "Corrupted virtual environment removed"
    else
        print_info "Activation script exists, but let's verify it works..."
        if source "$VENV_DIR/bin/activate" 2>/dev/null; then
            print_success "Virtual environment appears to be working"
            deactivate 2>/dev/null || true
            exit 0
        else
            print_error "Virtual environment is corrupted"
            print_info "Removing corrupted virtual environment..."
            rm -rf "$VENV_DIR"
            print_success "Corrupted virtual environment removed"
        fi
    fi
else
    print_info "No existing virtual environment found"
fi

# Create fresh virtual environment
print_info "Creating fresh Python virtual environment..."

# Ensure parent directory exists
mkdir -p "$(dirname "$VENV_DIR")"

# Create virtual environment
if python3 -m venv "$VENV_DIR"; then
    print_success "Virtual environment created successfully"
else
    print_error "Failed to create virtual environment with python3 -m venv"
    
    # Try alternative method
    if command -v virtualenv >/dev/null 2>&1; then
        print_info "Trying alternative method with virtualenv..."
        if virtualenv "$VENV_DIR"; then
            print_success "Virtual environment created with virtualenv"
        else
            print_error "Failed to create virtual environment with virtualenv"
            exit 1
        fi
    else
        print_error "virtualenv not available as fallback"
        print_info "Installing virtualenv..."
        pip3 install --user virtualenv
        if "$HOME/.local/bin/virtualenv" "$VENV_DIR"; then
            print_success "Virtual environment created with user-installed virtualenv"
        else
            print_error "All virtual environment creation methods failed"
            exit 1
        fi
    fi
fi

# Verify the virtual environment works
print_info "Verifying virtual environment..."
if [[ -f "$VENV_DIR/bin/activate" ]]; then
    if source "$VENV_DIR/bin/activate"; then
        print_success "Virtual environment activation successful"
        print_info "Python version: $(python --version)"
        
        # Upgrade pip
        print_info "Upgrading pip..."
        pip install --upgrade pip setuptools wheel
        
        deactivate
        print_success "Virtual environment is ready for use"
    else
        print_error "Virtual environment activation failed"
        exit 1
    fi
else
    print_error "Activation script still missing after creation"
    exit 1
fi

echo
print_success "Virtual environment fix completed!"
print_info "You can now run the AI setup script again."
print_info "Location: $VENV_DIR"
