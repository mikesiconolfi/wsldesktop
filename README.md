# AWS Power User WSL Setup Guide

This guide provides a complete setup for transforming your fresh WSL installation into a powerful AWS development environment with best-in-class tools and theme.

## Setup Overview

The setup script automates the installation and configuration of:

- **ZSH with Oh My Zsh**: Modern shell with powerful customization
- **Powerlevel10k Theme**: Beautiful and informative prompt with AWS integration
- **AWS CLI v2**: Latest version of the AWS Command Line Interface
- **Multi-Account AWS Support**: Easily switch between AWS accounts and roles
- **Development Tools**: Git, GitHub CLI, and AWS-specific development tools
- **Terminal Customization**: Nerd Fonts for beautiful icons and improved readability

## Key Features

### 🚀 AWS-Optimized Terminal

- **AWS Profile Indicator**: Your prompt shows the current AWS profile
- **Fast Profile Switching**: Use `awsp` command to quickly switch between accounts
- **Multi-Account Support**: Sample configuration for SSO, IAM, and cross-account access

### 💻 Development Environment

- **VSCode Integration**: Ready for remote development with WSL
- **AWS Tools**: AWS CLI, SSO utilities, SAM CLI, CDK, and Serverless Framework
- **Git Workflow**: GitHub CLI and useful Git aliases

### 🎨 Visual Enhancements

- **Powerlevel10k Theme**: Clean, informative, and fast prompt
- **JetBrainsMono Nerd Font**: Modern coding font with icons
- **Syntax Highlighting**: Code highlighting directly in your terminal

## What You Get

After running the script, your environment will include:

| Component | Description |
|-----------|-------------|
| **Shell** | ZSH with Oh My Zsh |
| **Theme** | Powerlevel10k (AWS-optimized) |
| **AWS CLI** | Version 2 with multi-profile support |
| **AWS Utilities** | AWS SSO Utils, Profile Switcher |
| **Dev Tools** | AWS SAM, CDK, Serverless Framework |
| **Git Tools** | GitHub CLI with custom aliases |
| **Font** | JetBrainsMono Nerd Font |
| **ZSH Plugins** | git, aws, docker, vscode, autosuggestions, syntax-highlighting |

## Usage Tips

- **Switch AWS Profiles**: Type `awsp` to quickly switch between profiles
- **AWS Aliases**: 
  - `awsw` - Use AWS CLI with work profile
  - `awsp` - Use AWS CLI with personal profile
  - `awsl` - List all configured AWS profiles
- **Git Shortcuts**:
  - `gs` - Git status
  - `gc` - Git commit
  - `gp` - Git push
  - `gl` - Git pull

## Installation

1. Save the setup script to a file (e.g., `setup-aws-wsl.sh`)
2. Make it executable: `chmod +x setup-aws-wsl.sh`
3. Run it: `./setup-aws-wsl.sh`
4. Restart your terminal

## Post-Installation

After running the script:

1. Edit `~/.aws/config` with your actual AWS account details
2. Install JetBrainsMono Nerd Font in Windows (if using Windows Terminal)
3. Configure Windows Terminal to use the installed font

## Customization

- **Powerlevel10k**: Run `p10k configure` for interactive theme customization
- **ZSH Plugins**: Edit `~/.zshrc` to add or remove plugins
- **AWS Config**: Edit `~/.aws/config` to add more profiles as needed

---

*Script and guide created for AWS power users on WSL*
