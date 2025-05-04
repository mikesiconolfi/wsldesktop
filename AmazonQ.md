# Uninstall/Revert Functionality for WSL Desktop Setup

This document describes the uninstall/revert functionality added to the WSL Desktop Setup script.

## Overview

The uninstall functionality allows users to:

1. Uninstall specific components that were previously installed
2. Revert to previous configurations by restoring backups
3. Selectively choose which components to uninstall

## How to Use

To use the uninstall functionality:

1. Run the setup script:
   ```bash
   ./setup-aws-wsl.sh
   ```

2. When prompted "Would you like to uninstall components or revert to previous configurations?", answer "Yes"

3. Select the components you want to uninstall using the interactive menu
   - Use space to select/deselect components
   - Press Enter to confirm your selection

4. Follow the prompts for each component to confirm uninstallation

## What Gets Uninstalled

The uninstall functionality can remove:

| Component | What Gets Uninstalled |
|-----------|------------------------|
| Base System | Oh My Zsh, revert to bash shell |
| Theme and Fonts | Powerlevel10k theme, Powerline fonts |
| AWS CLI | AWS CLI v2, restore AWS config backups |
| Docker | Docker, Docker Compose |
| Kubernetes | kubectl, eksctl, helm, k9s, kubectx, restore kubeconfig |
| Terraform | Terraform binary |
| Session Manager | AWS Session Manager plugin |
| Modern CLI Tools | bat, exa/eza, fzf, direnv, tldr |
| 1Password | 1Password CLI |
| AWS Dev Tools | AWS SAM CLI, CDK, Serverless Framework, Amplify CLI |
| ZSH Config | Restore original .zshrc |
| NeoVim | NeoVim and its configuration |
| Windows Nerd Fonts | Nerd Fonts installed to Windows |
| VSCode Nerd Fonts | VSCode font configuration for Nerd Fonts |

## Backup and Restore

The uninstall functionality leverages the backup system that was already in place:

- Configuration files are backed up during installation with timestamps
- During uninstall, the most recent backup is identified and can be restored
- Backups are stored with `.bak.YYYYMMDDHHMMSS` extensions

## Implementation Details

The uninstall functionality is implemented as a separate module:

- `modules/13_uninstall.sh` contains all uninstall functions
- Each function handles uninstalling a specific component
- The main script has been updated to support both install and uninstall modes
- Confirmation prompts ensure users don't accidentally uninstall components

## Logs

All uninstall operations are logged to the same log file as installations:
- `~/wsldesktop_install.log`

This helps track what was uninstalled and when.
