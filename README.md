# AWS Power User WSL Setup Guide

This guide provides a complete setup for transforming your fresh WSL installation into a powerful AWS development environment with best-in-class tools and theme.

## Setup Overview

The setup script automates the installation and configuration of:

- **ZSH with Oh My Zsh**: Modern shell with powerful customization
- **Powerlevel10k Theme**: Beautiful and informative prompt with AWS integration
- **AWS CLI v2**: Latest version of the AWS Command Line Interface
- **Multi-Account AWS Support**: Easily switch between AWS accounts and roles
- **Development Tools**: Git, GitHub CLI, and AWS-specific development tools
- **Terminal Customization**: Powerline fonts for beautiful icons and improved readability
- **Docker & Containers**: Docker with ECR integration
- **Infrastructure as Code**: Terraform with workspace management
- **Modern CLI Tools**: Enhanced replacements for common Unix tools
- **AWS Session Manager**: Direct EC2 instance access without SSH keys
- **1Password Integration**: Access secrets and credentials from 1Password# AWS Power User WSL Setup Guide

This guide provides a complete setup for transforming your fresh WSL installation into a powerful AWS development environment with best-in-class tools and theme.

## Setup Overview

The setup script automates the installation and configuration of:

- **ZSH with Oh My Zsh**: Modern shell with powerful customization
- **Powerlevel10k Theme**: Beautiful and informative prompt with AWS integration
- **AWS CLI v2**: Latest version of the AWS Command Line Interface
- **Multi-Account AWS Support**: Easily switch between AWS accounts and roles
- **EKS Integration**: Complete Kubernetes toolset for AWS EKS clusters
- **Development Tools**: Git, GitHub CLI, and AWS-specific development tools
- **Terminal Customization**: Nerd Fonts for beautiful icons and improved readability

## Key Features

### 🚀 AWS-Optimized Terminal

- **AWS Profile Indicator**: Your prompt shows the current AWS profile
- **Fast Profile Switching**: Use `awsp` command to quickly switch between accounts
- **Multi-Account Support**: Sample configuration for SSO, IAM, and cross-account access
- **Region Switching**: Quickly change AWS regions with `awsregion` command
- **AWS Helper Functions**: Shortcuts for common AWS tasks:
  - EC2 instance listing with `awsec2list`
  - CloudWatch log viewing with `awslogs`
  - CloudFormation stack status with `awscf`
  - ECR login with `ecr-login`
  - Session Manager connections with `ssm-connect` and `ssm-list-connect`

### 💻 Development Environment

- **AWS Tools**: AWS CLI, SSO utilities, SAM CLI, CDK, and Serverless Framework
- **Docker Integration**: Docker with ECR credential helper
- **Terraform Support**: Complete Terraform setup with workspace management
- **Kubernetes/EKS Tools**: kubectl, eksctl, helm, k9s, and kubectx for EKS management
- **Git Workflow**: GitHub CLI and useful Git aliases
- **AWS Session Manager**: Connect to EC2 instances without SSH keys

### 🎨 Visual and Productivity Enhancements

- **Powerlevel10k Theme**: Clean, informative, and fast prompt
- **Powerline Fonts**: Better terminal fonts with icons
- **Modern CLI Tools**:
  - `bat` - A cat clone with syntax highlighting
  - `eza/exa` - A modern replacement for ls
  - `fzf` - Fuzzy finder for command history and file searching
  - `direnv` - Automatic environment switching
  - `tldr` - Simplified command examples

## What You Get

After running the script, your environment will include:

| Component | Description |
|-----------|-------------|
| **Shell** | ZSH with Oh My Zsh |
| **Theme** | Powerlevel10k (AWS-optimized) |
| **AWS CLI** | Version 2 with multi-profile support |
| **AWS Utilities** | AWS SSO Utils, Profile Switcher, Session Manager |
| **Security Tools** | 1Password CLI integration for credentials |
| **Dev Tools** | AWS SAM, CDK, Serverless Framework |
| **IaC Tools** | Terraform with workspace management |
| **Container Tools** | Docker with ECR integration |
| **Kubernetes Tools** | kubectl, eksctl, Helm, k9s, kubectx |
| **Git Tools** | GitHub CLI with custom aliases |
| **Terminal Tools** | bat, eza/exa, fzf, direnv, tldr |
| **Font** | Powerline Fonts |
| **ZSH Plugins** | git, aws, docker, vscode, autosuggestions, syntax-highlighting |

## Usage Tips

- **Switch AWS Profiles**: Type `awsp` to quickly switch between profiles
- **Switch AWS Regions**: Type `awsregion` to select an AWS region
- **AWS Aliases**: 
  - `awsw` - Use AWS CLI with work profile
  - `awsd` - Use AWS CLI with dev profile
  - `awsl` - List all configured AWS profiles
  - `awsid` - Show current AWS identity
  - `awsec2` - List EC2 instances in a table format
  - `awss3` - List S3 buckets
  - `awslambda` - List Lambda functions
- **AWS Functions**:
  - `awslogs` - Select and tail CloudWatch logs
  - `awsec2list` - Show detailed EC2 instance information
  - `awscf` - Show CloudFormation stack status
  - `ssm-connect <instance-id>` - Connect to EC2 via Session Manager
  - `ssm-list-connect` - Select and connect to EC2 instances
  - `ecr-login [region]` - Log in to ECR
- **Docker Shortcuts**:
  - `dps` - Docker ps
  - `dpsa` - Docker ps -a
  - `dimg` - Docker images
  - `dcup` - Docker compose up -d
  - `dcdown` - Docker compose down
- **Terraform Shortcuts**:
  - `tf` - Terraform
  - `tfi` - Terraform init
  - `tfp` - Terraform plan
  - `tfa` - Terraform apply
  - `tfws` - Select Terraform workspace
- **Kubernetes/EKS Shortcuts and Tools**:
  - `k` - Shortcut for kubectl
  - `eks-list` - List all EKS clusters
  - `eks-switch` - Interactively switch between EKS clusters
  - `eks-kubeconfig` - Update kubeconfig for a cluster
  - `eks-manage` - Launch the EKS management tool
  - `eks-pods` - List all pods across namespaces
  - `eks-nodes` - List all nodes with status and resource usage
  - `eks-shell` - Get a shell on a pod
  - `eks-install-alb` - Install AWS Load Balancer Controller
- **Modern CLI Tools**:
  - Use `bat` instead of `cat` for syntax highlighted file viewing
  - Use enhanced `ls`, `ll`, and `lt` for better directory listings
  - Press `Ctrl+R` for enhanced command history search

## Installation

1. Save the setup script to a file (e.g., `setup-aws-wsl.sh`)
2. Make it executable: `chmod +x setup-aws-wsl.sh`
3. Run it: `./setup-aws-wsl.sh`
4. Restart your terminal

The script can be run multiple times safely - it will only install packages that aren't already installed.

## Post-Installation

After running the script:

1. Edit `~/.aws/config` with your actual AWS account details
2. Install Powerline fonts in Windows (if using Windows Terminal)
3. Configure Windows Terminal to use one of the Powerline fonts:
   - DejaVu Sans Mono for Powerline
   - Source Code Pro for Powerline
   - Ubuntu Mono derivative Powerline
4. You may need to restart your WSL session for all changes to take effect

## Customization

- **Powerlevel10k**: Run `p10k configure` for interactive theme customization
- **ZSH Plugins**: Edit `~/.zshrc` to add or remove plugins
- **AWS Config**: Edit `~/.aws/config` to add more profiles as needed
- **Docker**: Edit `~/.docker/config.json` to customize Docker settings
- **Terraform**: Create `.terraformrc` in your home directory for additional settings

## Included AWS Functions

### Profile and Region Management
- **awsp()**: Interactive AWS profile selection with fuzzy finding
- **awsregion()**: Interactive AWS region selection with fuzzy finding

### EC2 Management
- **awsec2list()**: List running EC2 instances with details
- **ssm-connect()**: Connect to EC2 instances via Session Manager
- **ssm-list-connect()**: Select and connect to EC2 instances interactively

### Container Registry
- **ecr-login()**: Authenticate with Amazon ECR in the specified region

### Monitoring
- **awslogs()**: Interactive CloudWatch log group selection and tailing
- **awscf()**: List CloudFormation stacks with their status

### Security and Credentials Management
- **1Password Integration**: Seamless access to credentials stored in 1Password
- **AWS Session Manager**: Connect to EC2 instances without SSH keys
- **ECR Helpers**: Automatic authentication with Amazon ECR

## 1Password Integration

The script checks if 1Password CLI is installed on the Windows side and sets up integration:

- Creates a wrapper script to access the Windows 1Password CLI from WSL
- Provides helper functions to securely manage credentials:
  - `op-signin`: Sign in to 1Password and set the session token
  - `op-aws`: Load AWS credentials directly from a 1Password item
  - `op-ssh`: Extract and load SSH keys from 1Password

This integration keeps your credentials secure while making them easily accessible within your WSL environment. You never need to store AWS credentials or SSH keys in plain text files.

---

*Script and guide created for AWS power users on WSL*