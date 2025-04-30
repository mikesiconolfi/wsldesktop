# AWS Power User WSL Setup Guide

This guide provides a complete setup for transforming your fresh WSL installation into a powerful AWS development environment with best-in-class tools and theme.

## What's New

The setup script has been completely modularized for better maintainability and flexibility:

- **Modular Architecture**: Each component is now in its own script file
- **Selective Installation**: Choose which components you want to install
- **Improved Dependency Management**: Automatic detection and installation of required tools
- **Configuration Preservation**: Automatic backups of existing AWS and Kubernetes configurations
- **Enhanced Error Handling**: Better feedback and recovery from errors

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

## Installation

### Quick Start

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/wsldesktop.git
   cd wsldesktop
   ```

2. Make the script executable:
   ```bash
   chmod +x setup-aws-wsl.sh
   ```

3. Run the setup script:
   ```bash
   ./setup-aws-wsl.sh
   ```

4. Select the components you want to install using the interactive menu
   - Use space to select/deselect components
   - Press Enter to confirm your selection

5. Restart your terminal or run `exec zsh` to apply changes

### Dependencies

The script will automatically check for and install these required dependencies:
- `fzf`: Used for interactive selection menus
- Other dependencies will be installed as needed for selected components

## How to Use Your New Environment

### AWS Profile Management

#### Switching Between AWS Profiles

1. Type `awsp` to open the interactive profile selector
2. Use arrow keys to navigate the list of profiles
3. Press Enter to select a profile
4. Your prompt will update to show the selected profile

Example:
```bash
$ awsp
# Interactive menu appears with your AWS profiles
# Select "dev" profile
AWS Profile set to dev
```

#### Switching AWS Regions

1. Type `awsregion` to open the interactive region selector
2. Use arrow keys to navigate the list of regions
3. Press Enter to select a region

Example:
```bash
$ awsregion
# Interactive menu appears with AWS regions
# Select "us-west-2"
AWS Region set to us-west-2
```

#### Checking Current AWS Identity

```bash
$ awsid
{
    "UserId": "AROAXXXXXXXXXXXXXXXXX",
    "Account": "123456789012",
    "Arn": "arn:aws:sts::123456789012:assumed-role/PowerUserAccess/session-name"
}
```

### AWS Resource Management

#### Listing EC2 Instances

```bash
# Quick table view
$ awsec2
# Detailed view with more information
$ awsec2list
```

#### Working with CloudWatch Logs

```bash
$ awslogs
# Interactive menu appears with your log groups
# Select a log group, then a log stream
# Log events will be displayed
```

#### Checking CloudFormation Stacks

```bash
$ awscf
# Table showing all your CloudFormation stacks with status
```

### Docker and ECR

#### Logging into Amazon ECR

```bash
# Log in to ECR in the current region
$ ecr-login

# Log in to ECR in a specific region
$ ecr-login us-west-2
```

#### Docker Shortcuts

```bash
$ dps          # List running containers
$ dpsa         # List all containers
$ dimg         # List images
$ dcup         # docker-compose up -d
$ dcdown       # docker-compose down
$ dclogs       # docker-compose logs -f
$ dexec        # docker exec -it
$ dprune       # docker system prune -a
```

### Kubernetes and EKS

#### Managing EKS Clusters

```bash
# List all EKS clusters
$ eks-list

# Switch between clusters
$ eks-switch
# Interactive menu appears with your clusters
# Select a cluster to update kubeconfig

# Update kubeconfig for a specific cluster
$ eks-kubeconfig my-cluster

# Launch k9s for cluster management
$ eks-manage
```

#### Kubernetes Commands

```bash
$ k get pods                  # kubectl shortcut
$ eks-pods                    # List all pods across namespaces
$ eks-nodes                   # List all nodes with details
$ eks-shell                   # Get a shell on a pod (interactive)
$ eks-install-alb my-cluster  # Install AWS Load Balancer Controller
```

### AWS Session Manager

```bash
# Connect to an instance by ID
$ ssm-connect i-0123456789abcdef0

# List and select an instance to connect to
$ ssm-list-connect
# Interactive menu appears with your instances
# Select an instance to connect via Session Manager
```

### Terraform

```bash
$ tf           # terraform
$ tfi          # terraform init
$ tfp          # terraform plan
$ tfa          # terraform apply
$ tfd          # terraform destroy
$ tfo          # terraform output
$ tfs          # terraform state
$ tfv          # terraform validate
$ tff          # terraform fmt

# Select a workspace
$ tfws
# Interactive menu appears with your workspaces
# Select a workspace to switch to it

# Plan with output file
$ tfpo         # terraform plan -out=tfplan

# Apply plan file
$ tfao         # terraform apply tfplan

# Generate documentation
$ tfdoc        # Generate README.md from Terraform code
```

### Modern CLI Tools

```bash
# Enhanced file viewing with syntax highlighting
$ cat file.js      # Uses bat with syntax highlighting

# Enhanced directory listing
$ ls               # Uses eza/exa with icons
$ ll               # Long listing with details
$ lt               # Tree view of directory

# Fuzzy finding
$ ctrl+r           # Search command history
$ preview          # Browse files with preview
$ ff               # Find and open a file in editor
$ fcd              # Find and change to a directory

# Simplified help
$ help ls          # Show tldr help for ls command
```

### 1Password Integration

```bash
# Sign in to 1Password
$ op-signin

# Load AWS credentials from 1Password
$ op-aws my-aws-credentials

# Load SSH key from 1Password
$ op-ssh my-ssh-key

# Load environment variables from 1Password
$ op-env my-env-vars
```

### AWS Development Tools

```bash
# AWS SAM
$ saml         # sam local
$ sami         # sam init
$ samd         # sam deploy

# AWS CDK
$ cdki         # cdk init
$ cdkd         # cdk deploy
$ cdks         # cdk synth

# Serverless Framework
$ sls          # serverless
$ slsd         # serverless deploy
$ slsi         # serverless invoke

# AWS Amplify
$ ampi         # amplify init
$ ampd         # amplify deploy
$ ampp         # amplify publish
```

## Customization

### Powerlevel10k Theme

To customize your Powerlevel10k theme:

```bash
p10k configure
```

This will launch an interactive configuration wizard.

### ZSH Configuration

Edit your ZSH configuration:

```bash
vim ~/.zshrc
```

Key sections to customize:

- **Plugins**: Add or remove ZSH plugins in the `plugins=()` section
- **Path**: Add additional directories to your PATH
- **Aliases**: Add your own aliases at the end of the file

### AWS Configuration

Edit your AWS configuration:

```bash
vim ~/.aws/config
```

Example profile configurations:

```ini
# SSO profile
[profile sso-dev]
sso_start_url = https://your-company.awsapps.com/start
sso_region = us-east-1
sso_account_id = 123456789012
sso_role_name = PowerUserAccess
region = us-east-1
output = json

# Role assumption profile
[profile cross-account]
role_arn = arn:aws:iam::987654321098:role/CrossAccountRole
source_profile = default
region = us-east-1
output = json

# Static credentials profile
[profile static]
aws_access_key_id = YOUR_ACCESS_KEY
aws_secret_access_key = YOUR_SECRET_KEY
region = us-east-1
output = json
```

## Troubleshooting

### Common Issues

1. **ZSH not starting after installation**
   - Run `chsh -s $(which zsh)` to set ZSH as your default shell
   - Log out and log back in

2. **AWS profiles not showing in awsp**
   - Check that your AWS config file is properly formatted
   - Ensure there are no syntax errors in ~/.aws/config

3. **Powerline fonts not displaying correctly**
   - Install the fonts in Windows (if using WSL)
   - Configure your terminal to use a Powerline font

4. **Docker permission issues**
   - Run `sudo usermod -aG docker $USER`
   - Log out and log back in

5. **Missing commands after installation**
   - Run `source ~/.zshrc` to reload your configuration
   - Check if the PATH is correctly set in ~/.zshrc

### Getting Help

If you encounter issues:

1. Check that all dependencies are installed
2. Verify that your configuration files are correctly formatted
3. Try running the specific module script directly:
   ```bash
   ./modules/03_aws_cli.sh
   ```
4. Open an issue on the GitHub repository

## Advanced Configuration

### Adding Custom Modules

You can create your own modules by following these steps:

1. Create a new script in the `modules` directory:
   ```bash
   touch modules/12_my_custom_module.sh
   chmod +x modules/12_my_custom_module.sh
   ```

2. Use this template for your module:
   ```bash
   #!/bin/bash

   # My custom module

   install_my_custom_module() {
       section "Setting up my custom module"
       
       # Your installation code here
       
       info "My custom module setup complete"
   }
   ```

3. Add your module to the main script's selection menu

### Extending Existing Modules

To extend an existing module:

1. Edit the module file directly
2. Add your customizations at the end of the installation function
3. Make sure to follow the same error handling pattern

## Acknowledgments

- [Oh My Zsh](https://ohmyz.sh/) for the ZSH framework
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k) for the theme
- [AWS CLI](https://aws.amazon.com/cli/) for the AWS command line interface
- All the open-source projects that make this environment possible

---

*Script and guide created for AWS power users on WSL*
