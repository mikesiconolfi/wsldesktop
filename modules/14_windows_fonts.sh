#!/bin/bash

# Windows Nerd Fonts Installation Module
# This module installs Nerd Fonts to Windows from WSL

install_windows_fonts() {
    section "Installing Nerd Fonts to Windows"
    
    # Check if we're running in WSL
    if ! grep -q Microsoft /proc/version; then
        warning "Not running in WSL. Skipping Windows font installation."
        return 0
    fi
    
    # Get Windows username
    WIN_USER=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')
    if [[ -z "$WIN_USER" ]]; then
        error "Could not determine Windows username. Skipping Windows font installation."
        return 1
    fi
    
    info "Detected Windows username: $WIN_USER"
    
    # Create directory for fonts in Windows user folder
    FONTS_DIR="/mnt/c/Users/$WIN_USER/NerdFonts"
    info "Creating fonts directory: $FONTS_DIR"
    mkdir -p "$FONTS_DIR"
    
    if [[ ! -d "$FONTS_DIR" ]]; then
        error "Failed to create fonts directory in Windows. Skipping Windows font installation."
        return 1
    fi
    
    # Copy Nerd Fonts to Windows directory
    info "Copying Nerd Fonts to Windows..."
    
    # Check if JetBrains Mono Nerd Fonts exist
    JETBRAINS_FONTS=$(find ~/.local/share/fonts -name "JetBrains*Nerd*.ttf" 2>/dev/null)
    if [[ -n "$JETBRAINS_FONTS" ]]; then
        info "Copying JetBrains Mono Nerd Fonts..."
        cp ~/.local/share/fonts/JetBrains*Nerd*.ttf "$FONTS_DIR/" 2>/dev/null
    else
        warning "JetBrains Mono Nerd Fonts not found in ~/.local/share/fonts"
        
        # Try to find any Nerd Fonts
        NERD_FONTS=$(find ~/.local/share/fonts -name "*Nerd*.ttf" 2>/dev/null)
        if [[ -n "$NERD_FONTS" ]]; then
            info "Copying available Nerd Fonts..."
            cp ~/.local/share/fonts/*Nerd*.ttf "$FONTS_DIR/" 2>/dev/null
        else
            warning "No Nerd Fonts found in ~/.local/share/fonts"
            
            # Copy Powerline fonts as fallback
            info "Copying Powerline fonts as fallback..."
            cp ~/.local/share/fonts/*Powerline*.ttf "$FONTS_DIR/" 2>/dev/null
        fi
    fi
    
    # Count copied fonts
    FONT_COUNT=$(find "$FONTS_DIR" -name "*.ttf" | wc -l)
    if [[ "$FONT_COUNT" -eq 0 ]]; then
        error "No fonts were copied to Windows. Font installation failed."
        return 1
    fi
    
    info "Successfully copied $FONT_COUNT fonts to Windows"
    
    # Create PowerShell script to install fonts
    info "Creating font installation script..."
    cat << 'EOF' > ~/install-fonts.ps1
$FONTS = 0x14
$objShell = New-Object -ComObject Shell.Application
$objFolder = $objShell.Namespace($FONTS)

$username = $env:USERNAME
$fontDir = "C:\Users\$username\NerdFonts"
$fonts = Get-ChildItem $fontDir -Filter "*.ttf"

foreach ($font in $fonts) {
    $fontPath = Join-Path $fontDir $font.Name
    Write-Host "Installing font: $($font.Name)"
    $objFolder.CopyHere($fontPath)
}
Write-Host "Font installation complete!"

# Create a Windows Terminal settings backup if it exists
$settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
if (Test-Path $settingsPath) {
    Copy-Item $settingsPath "$settingsPath.bak"
    Write-Host "Windows Terminal settings backed up to $settingsPath.bak"
}
EOF
    
    # Run the PowerShell script with administrator privileges
    info "Installing fonts in Windows (requires admin privileges)..."
    info "A PowerShell window will open. Please approve the UAC prompt if it appears."
    powershell.exe -ExecutionPolicy Bypass -Command "Start-Process PowerShell -ArgumentList '-ExecutionPolicy Bypass -File ~/install-fonts.ps1' -Verb RunAs"
    
    # Create instructions for Windows Terminal configuration
    info "Creating Windows Terminal configuration instructions..."
    cat << 'EOF' > ~/windows-terminal-instructions.txt
Windows Terminal Configuration Instructions
==========================================

To configure Windows Terminal to use the newly installed Nerd Fonts:

1. Open Windows Terminal
2. Click on the dropdown arrow in the title bar and select "Settings" (or press Ctrl+,)
3. In the Settings UI:
   - Click on your WSL profile in the left sidebar
   - Scroll down to "Appearance"
   - Under "Font face", select one of the Nerd Fonts you installed:
     * JetBrainsMono NF
     * JetBrainsMono Nerd Font
     * JetBrainsMono Nerd Font Mono
   - Click "Save"

If you prefer to edit the settings.json file directly:

1. Open Windows Terminal Settings
2. Click on "Open JSON file" in the bottom left corner
3. Find your WSL profile in the "profiles" -> "list" section
4. Add or modify the "font" section:

{
    "guid": "{your-wsl-profile-guid}",
    "name": "Ubuntu",
    // ... other settings ...
    "font": {
        "face": "JetBrainsMono Nerd Font",
        "size": 10
    }
}

After making these changes, restart Windows Terminal completely.
EOF
    
    info "Instructions saved to ~/windows-terminal-instructions.txt"
    info "Please follow these instructions to configure Windows Terminal to use the Nerd Fonts"
    
    info "Windows Nerd Fonts installation complete"
}

uninstall_windows_fonts() {
    section "Uninstalling Windows Nerd Fonts"
    
    # Check if we're running in WSL
    if ! grep -q Microsoft /proc/version; then
        warning "Not running in WSL. Skipping Windows font uninstallation."
        return 0
    fi
    
    # Get Windows username
    WIN_USER=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')
    if [[ -z "$WIN_USER" ]]; then
        error "Could not determine Windows username. Skipping Windows font uninstallation."
        return 1
    fi
    
    # Check if fonts directory exists
    FONTS_DIR="/mnt/c/Users/$WIN_USER/NerdFonts"
    if [[ ! -d "$FONTS_DIR" ]]; then
        warning "Windows Nerd Fonts directory not found. Nothing to uninstall."
        return 0
    fi
    
    info "Creating font uninstallation instructions..."
    cat << 'EOF' > ~/windows-fonts-uninstall.txt
Windows Nerd Fonts Uninstallation Instructions
============================================

To uninstall the Nerd Fonts from Windows:

1. Open Control Panel
2. Go to Appearance and Personalization > Fonts
3. Search for "Nerd" or "JetBrains"
4. Right-click on each font and select "Delete"
5. Confirm the deletion

The fonts directory at C:\Users\<YourUsername>\NerdFonts can be safely deleted.

To revert Windows Terminal to use a standard font:

1. Open Windows Terminal
2. Click on the dropdown arrow in the title bar and select "Settings"
3. In the Settings UI:
   - Click on your WSL profile in the left sidebar
   - Scroll down to "Appearance"
   - Under "Font face", select a standard font like "Cascadia Mono"
   - Click "Save"
EOF
    
    info "Uninstallation instructions saved to ~/windows-fonts-uninstall.txt"
    info "Please follow these instructions to uninstall the Nerd Fonts from Windows"
    
    # Ask if user wants to delete the fonts directory
    if confirm "Would you like to delete the Windows Nerd Fonts directory ($FONTS_DIR)?"; then
        info "Deleting Windows Nerd Fonts directory..."
        rm -rf "$FONTS_DIR"
        info "Windows Nerd Fonts directory deleted"
    else
        info "Windows Nerd Fonts directory not deleted"
    fi
    
    info "Windows Nerd Fonts uninstallation complete"
}
