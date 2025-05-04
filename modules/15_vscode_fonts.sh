#!/bin/bash

# VSCode Nerd Fonts Configuration Module
# This module configures VSCode to use Nerd Fonts

configure_vscode_fonts() {
    section "Configuring VSCode to use Nerd Fonts"
    
    # Check if we're running in WSL
    if ! grep -q Microsoft /proc/version; then
        warning "Not running in WSL. Skipping VSCode font configuration."
        return 0
    fi
    
    # Get Windows username
    WIN_USER=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')
    if [[ -z "$WIN_USER" ]]; then
        error "Could not determine Windows username. Skipping VSCode font configuration."
        return 1
    fi
    
    info "Detected Windows username: $WIN_USER"
    
    # Define VSCode settings paths
    VSCODE_SETTINGS_DIR="/mnt/c/Users/$WIN_USER/AppData/Roaming/Code/User"
    VSCODE_SETTINGS_FILE="$VSCODE_SETTINGS_DIR/settings.json"
    
    # Check if VSCode settings directory exists
    if [[ ! -d "$VSCODE_SETTINGS_DIR" ]]; then
        warning "VSCode settings directory not found. VSCode may not be installed."
        warning "Expected path: $VSCODE_SETTINGS_DIR"
        
        # Create instructions for manual configuration
        info "Creating manual configuration instructions..."
        create_vscode_manual_instructions
        return 0
    fi
    
    # Check if settings.json exists
    if [[ ! -f "$VSCODE_SETTINGS_FILE" ]]; then
        info "VSCode settings.json not found. Creating a new one."
        mkdir -p "$VSCODE_SETTINGS_DIR"
        echo "{}" > "$VSCODE_SETTINGS_FILE"
    else
        # Backup existing settings
        info "Backing up existing VSCode settings..."
        backup_file "$VSCODE_SETTINGS_FILE"
    fi
    
    # Update VSCode settings to use Nerd Fonts
    info "Updating VSCode settings to use Nerd Fonts..."
    
    # Read current settings
    local settings=$(cat "$VSCODE_SETTINGS_FILE")
    
    # Check if settings is valid JSON
    if ! echo "$settings" | jq . >/dev/null 2>&1; then
        warning "VSCode settings.json is not valid JSON. Creating manual configuration instructions."
        create_vscode_manual_instructions
        return 0
    fi
    
    # Update font settings using jq
    local updated_settings=$(echo "$settings" | jq '
        . + {
            "editor.fontFamily": "\"JetBrainsMono Nerd Font\", \"JetBrains Mono\", Consolas, \"Courier New\", monospace",
            "editor.fontLigatures": true,
            "terminal.integrated.fontFamily": "\"JetBrainsMono Nerd Font Mono\", \"JetBrains Mono\", Consolas, \"Courier New\", monospace"
        }
    ')
    
    # Write updated settings back to file
    echo "$updated_settings" > "$VSCODE_SETTINGS_FILE"
    
    info "VSCode settings updated to use JetBrainsMono Nerd Font"
    info "Font settings have been applied to both the editor and integrated terminal"
    
    # Create instructions for additional customization
    create_vscode_customization_instructions
    
    info "VSCode font configuration complete"
}

create_vscode_manual_instructions() {
    cat << 'EOF' > ~/vscode-font-instructions.txt
VSCode Nerd Font Configuration Instructions
==========================================

To manually configure VSCode to use Nerd Fonts:

1. Open VSCode
2. Press Ctrl+Shift+P to open the Command Palette
3. Type "Preferences: Open Settings (JSON)" and select it
4. Add or update these settings in your settings.json file:

{
    "editor.fontFamily": "JetBrainsMono Nerd Font, JetBrains Mono, Consolas, 'Courier New', monospace",
    "editor.fontLigatures": true,
    "terminal.integrated.fontFamily": "JetBrainsMono Nerd Font Mono, JetBrains Mono, Consolas, 'Courier New', monospace"
}

5. Save the file and restart VSCode

Note: If JetBrainsMono Nerd Font is not available, you can use any other Nerd Font 
that was installed, such as:
- FiraCode Nerd Font
- Hack Nerd Font
- DejaVuSansMono Nerd Font
EOF
    
    info "Manual configuration instructions saved to ~/vscode-font-instructions.txt"
}

create_vscode_customization_instructions() {
    cat << 'EOF' > ~/vscode-font-customization.txt
VSCode Font Customization Options
===============================

You can further customize your VSCode font settings:

1. Font Size
   Add to settings.json:
   "editor.fontSize": 14,
   "terminal.integrated.fontSize": 14,

2. Font Weight
   Add to settings.json:
   "editor.fontWeight": "normal", // Options: "normal", "bold", "100" to "900"

3. Line Height
   Add to settings.json:
   "editor.lineHeight": 1.5,

4. Letter Spacing
   Add to settings.json:
   "editor.letterSpacing": 0.5,

5. Other Nerd Fonts Options
   If you prefer a different Nerd Font, replace "JetBrainsMono Nerd Font" with:
   - "FiraCode Nerd Font"
   - "Hack Nerd Font"
   - "CaskaydiaCove Nerd Font" (Cascadia Code)
   - "DejaVuSansMono Nerd Font"

6. Recommended Extensions for Font Enhancement:
   - "Material Icon Theme" - Better file icons
   - "Bracket Pair Colorizer 2" - Colorful brackets
   - "Indent Rainbow" - Colorful indentation

To apply these settings, open settings.json (Ctrl+Shift+P > "Preferences: Open Settings (JSON)")
and add the desired options.
EOF
    
    info "Font customization options saved to ~/vscode-font-customization.txt"
}

uninstall_vscode_fonts_config() {
    section "Reverting VSCode font configuration"
    
    # Check if we're running in WSL
    if ! grep -q Microsoft /proc/version; then
        warning "Not running in WSL. Skipping VSCode font configuration revert."
        return 0
    fi
    
    # Get Windows username
    WIN_USER=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')
    if [[ -z "$WIN_USER" ]]; then
        error "Could not determine Windows username. Skipping VSCode font configuration revert."
        return 1
    fi
    
    # Define VSCode settings path
    VSCODE_SETTINGS_FILE="/mnt/c/Users/$WIN_USER/AppData/Roaming/Code/User/settings.json"
    
    # Check if settings.json exists
    if [[ ! -f "$VSCODE_SETTINGS_FILE" ]]; then
        warning "VSCode settings.json not found. Nothing to revert."
        return 0
    fi
    
    # Check for backups
    local backup_file=$(find "/mnt/c/Users/$WIN_USER/AppData/Roaming/Code/User" -name "settings.json.bak.*" | sort -r | head -n 1)
    
    if [[ -n "$backup_file" ]]; then
        info "Found VSCode settings backup: $backup_file"
        if confirm "Would you like to restore this backup?"; then
            info "Restoring VSCode settings from backup..."
            cp "$backup_file" "$VSCODE_SETTINGS_FILE"
            info "VSCode settings restored from backup"
            return 0
        fi
    fi
    
    # If no backup or user declined, offer to remove font settings
    info "Removing Nerd Font settings from VSCode configuration..."
    
    # Read current settings
    local settings=$(cat "$VSCODE_SETTINGS_FILE")
    
    # Check if settings is valid JSON
    if ! echo "$settings" | jq . >/dev/null 2>&1; then
        warning "VSCode settings.json is not valid JSON. Cannot automatically revert."
        create_vscode_revert_instructions
        return 0
    fi
    
    # Update font settings using jq to remove Nerd Font references
    local updated_settings=$(echo "$settings" | jq '
        . + {
            "editor.fontFamily": "Consolas, \"Courier New\", monospace",
            "terminal.integrated.fontFamily": ""
        }
    ')
    
    # Write updated settings back to file
    echo "$updated_settings" > "$VSCODE_SETTINGS_FILE"
    
    info "VSCode font settings reverted to defaults"
    info "VSCode font configuration revert complete"
}

create_vscode_revert_instructions() {
    cat << 'EOF' > ~/vscode-font-revert-instructions.txt
VSCode Font Revert Instructions
=============================

To manually revert VSCode font settings to defaults:

1. Open VSCode
2. Press Ctrl+Shift+P to open the Command Palette
3. Type "Preferences: Open Settings (JSON)" and select it
4. Find and remove or modify these settings:

   "editor.fontFamily": "JetBrainsMono Nerd Font, ..."
   "editor.fontLigatures": true,
   "terminal.integrated.fontFamily": "JetBrainsMono Nerd Font Mono, ..."

5. Replace with default settings:

   "editor.fontFamily": "Consolas, 'Courier New', monospace",
   "editor.fontLigatures": false,
   "terminal.integrated.fontFamily": ""

6. Save the file and restart VSCode
EOF
    
    info "Manual revert instructions saved to ~/vscode-font-revert-instructions.txt"
}
