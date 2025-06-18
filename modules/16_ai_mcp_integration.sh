#!/bin/bash

# File Name: 16_ai_mcp_integration.sh
# Relative Path: ~/github/wsldesktop/modules/16_ai_mcp_integration.sh
# Purpose: Optional integration module for AI & MCP tools with the main WSL desktop setup.
# Detailed Overview: This module provides optional integration of the AI & MCP setup manager
# with the main WSL desktop installation. It creates convenient shortcuts and integrates
# the AI tools launcher into the system PATH without forcing installation of AI components.

# AI & MCP Integration Module

integrate_ai_mcp_tools() {
    section "AI & MCP Tools Integration"
    
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    local ai_mcp_script="$script_dir/ai-mcp"
    local setup_script="$script_dir/setup-ai-mcp.sh"
    
    # Check if AI/MCP scripts exist
    if [[ ! -f "$ai_mcp_script" ]] || [[ ! -f "$setup_script" ]]; then
        info "AI & MCP scripts not found. Skipping integration."
        return 0
    fi
    
    # Create symlink in local bin for global access
    mkdir -p "$HOME/.local/bin"
    
    if [[ ! -L "$HOME/.local/bin/ai-mcp" ]]; then
        ln -sf "$ai_mcp_script" "$HOME/.local/bin/ai-mcp"
        info "Created ai-mcp command shortcut"
    else
        info "ai-mcp command shortcut already exists"
    fi
    
    # Add to PATH if not already there
    local shell_config=""
    if [[ -n "$ZSH_VERSION" ]] && [[ -f "$HOME/.zshrc" ]]; then
        shell_config="$HOME/.zshrc"
    elif [[ -f "$HOME/.bashrc" ]]; then
        shell_config="$HOME/.bashrc"
    fi
    
    if [[ -n "$shell_config" ]]; then
        if ! grep -q '$HOME/.local/bin' "$shell_config"; then
            echo '' >> "$shell_config"
            echo '# Add local bin to PATH' >> "$shell_config"
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$shell_config"
            info "Added ~/.local/bin to PATH in $shell_config"
        fi
    fi
    
    # Create desktop entry for easy access (if desktop environment is available)
    if command_exists xdg-user-dir && [[ -d "$(xdg-user-dir DESKTOP 2>/dev/null)" ]]; then
        local desktop_file="$(xdg-user-dir DESKTOP)/AI-MCP-Setup.desktop"
        cat > "$desktop_file" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=AI & MCP Setup
Comment=Setup and manage AI tools and MCP servers
Exec=gnome-terminal -- $ai_mcp_script setup
Icon=applications-development
Terminal=true
Categories=Development;
EOF
        chmod +x "$desktop_file"
        info "Created desktop shortcut for AI & MCP Setup"
    fi
    
    # Add informational aliases
    if [[ -n "$shell_config" ]]; then
        if ! grep -q "# AI & MCP Tools" "$shell_config"; then
            cat >> "$shell_config" << 'EOF'

# AI & MCP Tools
alias ai-setup='ai-mcp setup'
alias ai-status='ai-mcp status'
alias ai-help='ai-mcp help'

EOF
            info "Added AI & MCP aliases to $shell_config"
        fi
    fi
    
    info "AI & MCP tools integration completed"
    info "Available commands:"
    info "  ai-mcp setup   - Launch AI & MCP setup manager"
    info "  ai-mcp status  - Check AI tools status"
    info "  ai-setup       - Alias for ai-mcp setup"
    info "  ai-status      - Alias for ai-mcp status"
}

# Only run if sourced as part of main setup
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    integrate_ai_mcp_tools
fi
