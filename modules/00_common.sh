#!/bin/bash

# Common functions and utilities used across all modules

# Color codes for pretty output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Print section header
section() {
    echo -e "\n${BLUE}==>${NC} ${GREEN}$1${NC}\n"
}

# Print info message
info() {
    echo -e "${YELLOW}-->${NC} $1"
}

# Print error message
error() {
    echo -e "${RED}ERROR:${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Ask user for yes/no confirmation
confirm() {
    read -p "$1 [y/N] " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Check for required dependencies and install if missing
check_dependencies() {
    section "Checking dependencies"
    
    # Check for fzf - required for selection menus
    if ! command_exists fzf; then
        info "Installing fzf for interactive selections..."
        sudo apt-get update
        sudo apt-get install -y fzf || {
            error "Failed to install fzf. Please install it manually."
            return 1
        }
    fi
    
    # Add checks for other critical dependencies here
    
    info "All dependencies satisfied"
    return 0
}

# Create backup of a file if it exists
backup_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        local backup="${file}.bak.$(date +%Y%m%d%H%M%S)"
        info "Creating backup of $file to $backup"
        cp "$file" "$backup"
        return 0
    fi
    return 1
}
