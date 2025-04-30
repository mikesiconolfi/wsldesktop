#!/bin/bash

# Modern CLI tools installation

install_modern_cli() {
    section "Setting up modern CLI tools"
    
    # Check for package manager lock
    if [[ "$IGNORE_LOCKS" != "1" ]] && pgrep -f "apt-get|dpkg" > /dev/null; then
        error "Another package manager process is running. Modern CLI tools installation will be skipped."
        info "You can install these tools manually later or re-run this module."
        info "To bypass this check, use: IGNORE_LOCKS=1 ./setup-aws-wsl.sh"
        return 1
    fi
    
    # Install bat (better cat) if not already installed
    if ! command_exists bat; then
        info "Installing bat..."
        sudo apt-get install -y bat
        
        # Create bat alias if needed (some distros use batcat)
        if command_exists batcat && ! command_exists bat; then
            mkdir -p "$HOME/.local/bin"
            ln -sf "$(which batcat)" "$HOME/.local/bin/bat"
            export PATH="$HOME/.local/bin:$PATH"
        fi
    else
        info "bat already installed"
    fi
    
    # Install exa/eza (better ls) if not already installed
    if ! command_exists exa && ! command_exists eza; then
        info "Installing eza..."
        # Try to install eza first (newer fork of exa)
        if ! sudo apt-get install -y eza 2>/dev/null; then
            # If eza fails, try to install exa
            sudo apt-get install -y exa || {
                # If both fail, try to install eza from binary
                mkdir -p "$HOME/.local/bin"
                EZA_VERSION=$(curl -s https://api.github.com/repos/eza-community/eza/releases/latest | grep tag_name | cut -d '"' -f 4)
                curl -L "https://github.com/eza-community/eza/releases/download/${EZA_VERSION}/eza_x86_64-unknown-linux-gnu.tar.gz" | tar xz -C /tmp
                mv /tmp/eza "$HOME/.local/bin/"
                chmod +x "$HOME/.local/bin/eza"
                export PATH="$HOME/.local/bin:$PATH"
            }
        fi
    else
        info "exa/eza already installed"
    fi
    
    # Install fzf (fuzzy finder) if not already installed
    if ! command_exists fzf; then
        info "Installing fzf..."
        sudo apt-get install -y fzf
    else
        info "fzf already installed"
    fi
    
    # Install direnv (directory environment) if not already installed
    if ! command_exists direnv; then
        info "Installing direnv..."
        sudo apt-get install -y direnv
    else
        info "direnv already installed"
    fi
    
    # Install tldr (simplified man pages) if not already installed
    if ! command_exists tldr; then
        info "Installing tldr..."
        sudo apt-get install -y tldr
    else
        info "tldr already installed"
    fi
    
    # Install jq (JSON processor) if not already installed
    if ! command_exists jq; then
        info "Installing jq..."
        sudo apt-get install -y jq
    else
        info "jq already installed"
    fi
    
    # Install yq (YAML processor) if not already installed
    if ! command_exists yq; then
        info "Installing yq..."
        sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
        sudo chmod +x /usr/local/bin/yq
    else
        info "yq already installed"
    fi
    
    # Create modern CLI tool aliases
    info "Setting up modern CLI tool aliases..."
    cat > "$HOME/.modern_cli_aliases" << 'EOF'
# Modern CLI tool aliases

# bat aliases (better cat)
alias cat='bat --paging=never'
alias less='bat'

# exa/eza aliases (better ls)
if command -v eza &> /dev/null; then
    alias ls='eza --icons'
    alias ll='eza -la --icons'
    alias lt='eza -T --icons'
    alias la='eza -a --icons'
elif command -v exa &> /dev/null; then
    alias ls='exa --icons'
    alias ll='exa -la --icons'
    alias lt='exa -T --icons'
    alias la='exa -a --icons'
fi

# fzf aliases and functions
alias preview='fzf --preview "bat --color=always {}"'
alias history-search='history | fzf'

# Find file and open in editor
ff() {
    local file=$(find . -type f -not -path "*/\.*" | fzf --preview "bat --color=always {}")
    if [[ -n "$file" ]]; then
        ${EDITOR:-vim} "$file"
    fi
}

# cd with fzf
fcd() {
    local dir=$(find . -type d -not -path "*/\.*" | fzf)
    if [[ -n "$dir" ]]; then
        cd "$dir"
    fi
}

# tldr aliases
alias help='tldr'
EOF
    
    info "Modern CLI tools setup complete"
}
