#!/bin/bash

# Common functions and utilities used across all modules

# Color codes for pretty output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Log file path
LOG_FILE="$HOME/wsldesktop_install.log"

# Initialize log file
init_log() {
    echo "=== WSL Desktop Setup Log - $(date) ===" > "$LOG_FILE"
    echo "System: $(uname -a)" >> "$LOG_FILE"
    echo "User: $(whoami)" >> "$LOG_FILE"
    echo "Directory: $(pwd)" >> "$LOG_FILE"
    echo "===================================" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
}

# Print section header
section() {
    local message="\n==> $1\n"
    echo -e "\n${BLUE}==>${NC} ${GREEN}$1${NC}\n"
    echo -e "$message" >> "$LOG_FILE"
}

# Print info message
info() {
    local message="--> $1"
    echo -e "${YELLOW}-->${NC} $1"
    echo "$message" >> "$LOG_FILE"
}

# Print error message
error() {
    local message="ERROR: $1"
    echo -e "${RED}ERROR:${NC} $1"
    echo "$message" >> "$LOG_FILE"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
    local result=$?
    if [ $result -eq 0 ]; then
        echo "Command check: $1 exists" >> "$LOG_FILE"
    else
        echo "Command check: $1 does not exist" >> "$LOG_FILE"
    fi
    return $result
}

# Ask user for yes/no confirmation
confirm() {
    read -p "$1 [y/N] " response
    echo "Confirmation prompt: $1 - Response: $response" >> "$LOG_FILE"
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
    section "Checking prerequisites"
    
    # Create a function to install a package if it's missing
    install_if_missing() {
        local package="$1"
        local check_cmd="${2:-$package}"
        local install_cmd="${3:-sudo apt-get install -y $package}"
        
        info "Checking for $package..."
        if ! command_exists "$check_cmd"; then
            info "Installing $package..."
            echo "Running: $install_cmd" >> "$LOG_FILE"
            eval "$install_cmd" >> "$LOG_FILE" 2>&1 || {
                error "Failed to install $package. Please install it manually."
                return 1
            }
            info "$package installed successfully"
        else
            info "$package is already installed"
        fi
        return 0
    }
    
    # Check for package manager lock, but allow bypass with IGNORE_LOCKS=1
    if [[ "$IGNORE_LOCKS" != "1" ]] && pgrep -f "apt-get|dpkg" > /dev/null; then
        error "Another package manager process is running. Please wait for it to finish or terminate it."
        info "You can check running processes with: ps aux | grep -E 'apt-get|dpkg'"
        info "To bypass this check (if you're sure no apt process is running), use: IGNORE_LOCKS=1 ./setup-aws-wsl.sh"
        return 1
    fi
    
    # Update package lists
    info "Updating package lists..."
    sudo apt-get update >> "$LOG_FILE" 2>&1 || {
        error "Failed to update package lists. Please check your internet connection."
        return 1
    }
    
    # Install essential packages
    install_if_missing "fzf" || return 1
    install_if_missing "curl" || return 1
    install_if_missing "wget" || return 1
    install_if_missing "git" || return 1
    install_if_missing "jq" || return 1
    
    # Install Python and pip
    install_if_missing "python3" || return 1
    install_if_missing "python3-pip" "pip3" || return 1
    
    # Install Node.js and npm if not already installed
    if ! command_exists node || ! command_exists npm; then
        info "Installing Node.js and npm..."
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - >> "$LOG_FILE" 2>&1
        sudo apt-get install -y nodejs >> "$LOG_FILE" 2>&1 || {
            error "Failed to install Node.js and npm. Please install them manually."
            return 1
        }
        info "Node.js and npm installed successfully"
    else
        info "Node.js and npm are already installed"
    fi
    
    # Create npm global directory to avoid permission issues
    if [ ! -d "$HOME/.npm-global" ]; then
        info "Creating npm global directory..."
        mkdir -p "$HOME/.npm-global"
        npm config set prefix "$HOME/.npm-global" >> "$LOG_FILE" 2>&1
        export PATH="$HOME/.npm-global/bin:$PATH"
    fi
    
    # Add checks for other critical dependencies here
    
    info "All prerequisites satisfied"
    return 0
}

# Create backup of a file if it exists
backup_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        local backup="${file}.bak.$(date +%Y%m%d%H%M%S)"
        info "Creating backup of $file to $backup"
        echo "Creating backup: $file -> $backup" >> "$LOG_FILE"
        cp "$file" "$backup"
        return 0
    fi
    echo "No backup needed for $file (file does not exist)" >> "$LOG_FILE"
    return 1
}

# Add Python virtual environment bin to PATH in .zshrc
add_venv_to_path() {
    local zshrc="$HOME/.zshrc"
    if [[ -f "$zshrc" ]]; then
        if ! grep -q "export PATH=\"\$HOME/.venvs/aws-tools/bin:\$PATH\"" "$zshrc"; then
            info "Adding Python virtual environment to PATH in .zshrc"
            echo "" >> "$zshrc"
            echo "# Add Python virtual environment to PATH" >> "$zshrc"
            echo "export PATH=\"\$HOME/.venvs/aws-tools/bin:\$PATH\"" >> "$zshrc"
        fi
    fi
}

# Log command output
log_command() {
    local cmd="$1"
    local desc="$2"
    
    echo "=== Running command: $cmd ($desc) ===" >> "$LOG_FILE"
    eval "$cmd" >> "$LOG_FILE" 2>&1
    local result=$?
    echo "=== Command completed with status: $result ===" >> "$LOG_FILE"
    return $result
}

# Print warning message
warning() {
    local message="WARNING: $1"
    echo -e "${YELLOW}WARNING:${NC} $1"
    echo "$message" >> "$LOG_FILE"
}
