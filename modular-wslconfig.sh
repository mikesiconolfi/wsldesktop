#!/bin/bash

# AWS Power User WSL Setup Script - Modular Version
# This script provides a modular setup for AWS development on WSL
# Users can select which components they want to install

# Remove set -e to prevent script from exiting on errors
# set -e  # Exit on error

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
check_and_install_dependency() {
    local package=$1
    if ! command_exists "$package"; then
        info "Installing required dependency: $package"
        sudo apt-get update && sudo apt-get install -y "$package" || {
            error "Failed to install $package"
            return 1
        }
    fi
}

# Check for fzf which is required for interactive selections
check_and_install_dependency "fzf" || {
    error "Failed to install required dependency: fzf"
    echo "Please install fzf manually with: sudo apt-get install -y fzf"
    exit 1
}

# Check if we're running in WSL
if ! grep -q Microsoft /proc/version && ! grep -q microsoft /proc/version; then
    error "This script is designed to run on WSL (Windows Subsystem for Linux)"
    error "Please run this script from your WSL environment"
    exit 1
fi

# Ensure script is run as non-root
if [ "$(id -u)" = "0" ]; then
    error "This script should not be run as root"
    exit 1
fi

section "AWS Power User WSL Setup - Modular Installation"
info "This script allows you to customize your AWS development environment"
info "You'll be able to select which components you want to install"
echo ""

# Array of components with descriptions
declare -A components
components=(
    ["base"]="Base system (apt update and essential packages)"
    ["zsh"]="ZSH shell with Oh My Zsh"
    ["p10k"]="Powerlevel10k theme for ZSH"
    ["aws_cli"]="AWS CLI v2"
    ["aws_tools"]="AWS development tools (SAM, CDK, SSO utils)"
    ["aws_helpers"]="AWS helper functions (profile switcher, CloudWatch logs viewer, etc.)"
    ["node"]="Node.js and npm"
    ["python"]="Python development tools"
    ["docker"]="Docker with ECR integration"
    ["terraform"]="Terraform with workspace management"
    ["kubernetes"]="Kubernetes tools with EKS integration"
    ["modern_cli"]="Modern CLI replacements (bat, eza/exa, fzf, etc.)"
    ["fonts"]="Powerline/Nerd fonts for beautiful terminal"
    ["session_manager"]="AWS Session Manager plugin"
    ["onepassword"]="1Password CLI integration"
    ["terminal_config"]="Windows Terminal configuration"
)

# Arrays to track selections
declare -a selected_components
declare -a all_components

# Add all component keys to all_components array
for component in "${!components[@]}"; do
    all_components+=("$component")
done

# Function to display component menu
display_menu() {
    local i=1
    echo "Available components:"
    echo ""
    for component in "${all_components[@]}"; do
        local status="[ ]"
        # Check if component is in selected_components
        for selected in "${selected_components[@]}"; do
            if [[ "$selected" == "$component" ]]; then
                status="[x]"
                break
            fi
        done
        printf "%2d) %s %s\n" $i "$status" "${components[$component]}"
        ((i++))
    done
    echo ""
    echo " a) Select all components"
    echo " n) Select none"
    echo " i) Install selected components"
    echo " q) Quit without installing"
    echo ""
}

# Function to toggle component selection
toggle_component() {
    local index=$1
    local component="${all_components[$index-1]}"
    
    # Debug output
    info "Toggling component: $component (${components[$component]})"
    
    # Check if already selected
    local is_selected=false
    local i=0
    for selected in "${selected_components[@]}"; do
        if [[ "$selected" == "$component" ]]; then
            is_selected=true
            # Remove from selected_components
            unset 'selected_components[$i]'
            selected_components=("${selected_components[@]}")
            break
        fi
        ((i++))
    done
    
    # If not already selected, add it
    if ! $is_selected; then
        selected_components+=("$component")
        info "Added component: $component"
    else
        info "Removed component: $component"
    fi
    
    # Debug output of current selections
    info "Current selections: ${selected_components[*]}"
}

# Function to select all components
select_all() {
    selected_components=("${all_components[@]}")
}

# Function to deselect all components
select_none() {
    selected_components=()
}

# Default selection - base is always selected
selected_components=("base")

# Show menu and handle selection
while true; do
    clear
    section "Component Selection"
    display_menu
    read -p "Enter your choice: " choice
    
    # Debug output
    info "You entered: $choice"
    
    case "$choice" in
        [1-9]|[1-9][0-9])
            # Check if the number is within range
            if (( choice >= 1 && choice <= ${#all_components[@]} )); then
                toggle_component "$choice"
                # No pause needed
            else
                info "Invalid selection. Please try again."
            fi
            ;;
        a|A)
            select_all
            info "Selected all components"
            ;;
        n|N)
            select_none
            # Base is always selected
            selected_components=("base")
            info "Deselected all components except base"
            ;;
        i|I)
            # Make sure base is always selected
            has_base=false
            for component in "${selected_components[@]}"; do
                if [[ "$component" == "base" ]]; then
                    has_base=true
                    break
                fi
            done
            
            if ! $has_base; then
                selected_components+=("base")
            fi
            
            # Confirm and proceed with installation
            echo ""
            info "You've selected the following components:"
            for component in "${selected_components[@]}"; do
                echo "  - ${components[$component]}"
            done
            echo ""
            
            if confirm "Do you want to proceed with installation?"; then
                break  # Exit the menu loop and proceed with installation
            fi
            ;;
        q|Q)
            section "Installation cancelled"
            exit 0
            ;;
        *)
            info "Invalid selection. Please try again."
            ;;
    esac
done

# Create a directory to store installation logs
INSTALL_LOG_DIR="$HOME/.aws-setup-logs"
mkdir -p "$INSTALL_LOG_DIR"
INSTALL_LOG="$INSTALL_LOG_DIR/install-$(date +%Y%m%d-%H%M%S).log"

# Function to check if a component is selected
is_selected() {
    local component=$1
    for selected in "${selected_components[@]}"; do
        if [[ "$selected" == "$component" ]]; then
            return 0
        fi
    done
    return 1
}

# Function to log installation progress
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$INSTALL_LOG"
}

# Main installation function
install_components() {
    section "Starting installation of selected components"
    log "Starting installation with components: ${selected_components[*]}"
    
    # Base component is always installed
    if is_selected "base"; then
        section "Installing base system"
        log "Installing base system"
        
        info "Updating package lists"
        sudo apt update >> "$INSTALL_LOG" 2>&1
        
        info "Installing essential packages"
        sudo apt install -y curl wget zip unzip build-essential git >> "$INSTALL_LOG" 2>&1
        
        log "Base system installation completed"
    fi
    
    # Install ZSH and Oh My Zsh
    if is_selected "zsh"; then
        section "Installing ZSH and Oh My Zsh"
        log "Installing ZSH and Oh My Zsh"
        
        if ! command_exists zsh; then
            info "Installing ZSH"
            sudo apt install -y zsh >> "$INSTALL_LOG" 2>&1
        else
            info "ZSH is already installed"
        fi
        
        if [ ! -d "$HOME/.oh-my-zsh" ]; then
            info "Installing Oh My Zsh"
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended >> "$INSTALL_LOG" 2>&1
        else
            info "Oh My Zsh is already installed"
        fi
        
        # Install ZSH plugins
        info "Installing ZSH plugins"
        if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
            git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions >> "$INSTALL_LOG" 2>&1
        else
            info "zsh-autosuggestions plugin is already installed"
        fi
        
        if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
            git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting >> "$INSTALL_LOG" 2>&1
        else
            info "zsh-syntax-highlighting plugin is already installed"
        fi
        
        log "ZSH and Oh My Zsh installation completed"
    fi
    
    # Install Powerlevel10k theme
    if is_selected "p10k"; then
        section "Installing Powerlevel10k theme"
        log "Installing Powerlevel10k theme"
        
        if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
            git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k >> "$INSTALL_LOG" 2>&1
        else
            info "Powerlevel10k theme is already installed"
        fi
        
        # Setup p10k configuration
        if [ ! -f "$HOME/.p10k.zsh" ]; then
            info "Creating new Powerlevel10k configuration file"
            curl -s https://raw.githubusercontent.com/romkatv/powerlevel10k/master/config/p10k-lean.zsh > "$HOME/.p10k.zsh"
            
            # Add AWS profile function to p10k config
            # This is a simplified version - in production, you'd use a template file
            info "Adding AWS profile segment to Powerlevel10k configuration"
            sed -i '/^}$/ i\
  # AWS segment: Show current AWS profile\
  function prompt_aws_profile() {\
    local aws_profile="$AWS_PROFILE"\
    if [[ -z "$aws_profile" ]]; then\
      aws_profile="$(aws configure list-profiles 2>/dev/null | head -1)"\
    fi\
    if [[ -n "$aws_profile" ]]; then\
      p10k segment -f yellow -i \x27☁️\x27 -t "${aws_profile}"\
    fi\
  }' "$HOME/.p10k.zsh"
            
            # Add aws_profile to left prompt elements
            sed -i '/POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=/ s/)/ aws_profile)/' "$HOME/.p10k.zsh"
        else
            info "Existing Powerlevel10k configuration detected"
            # Check if aws_profile function exists in the current p10k config
            if ! grep -q "prompt_aws_profile" "$HOME/.p10k.zsh"; then
                info "Adding AWS profile function to your Powerlevel10k configuration"
                # Add the AWS profile function to existing config
                bash p10k-aws-fix.sh >> "$INSTALL_LOG" 2>&1
            fi
        fi
        
        log "Powerlevel10k theme installation completed"
    fi
    
    # Install AWS CLI v2
    if is_selected "aws_cli"; then
        section "Installing AWS CLI v2"
        log "Installing AWS CLI v2"
        
        if ! command_exists aws || ! aws --version | grep -q "aws-cli/2"; then
            info "Downloading AWS CLI v2"
            curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip" >> "$INSTALL_LOG" 2>&1
            info "Extracting AWS CLI v2"
            unzip -q -o /tmp/awscliv2.zip -d /tmp >> "$INSTALL_LOG" 2>&1
            info "Installing AWS CLI v2"
            sudo /tmp/aws/install --update >> "$INSTALL_LOG" 2>&1
            rm -rf /tmp/aws /tmp/awscliv2.zip
        else
            info "AWS CLI v2 is already installed"
        fi
        
        # Check for existing AWS config and credentials
        if [ -f "$HOME/.aws/config" ]; then
            info "Existing AWS config found at ~/.aws/config"
            # Create a backup of the existing config
            cp "$HOME/.aws/config" "$HOME/.aws/config.backup.$(date +%Y%m%d%H%M%S)"
            info "Created backup of your AWS config at ~/.aws/config.backup.$(date +%Y%m%d%H%M%S)"
            info "Your existing AWS configuration will be preserved"
        else
            info "Creating sample AWS config file"
            mkdir -p "$HOME/.aws"
            cat > "$HOME/.aws/config" << 'EOF'
# Sample AWS Config File
# Replace with your actual AWS SSO info and account details

[default]
region = us-east-1
output = json

# Example SSO profile
[profile dev]
sso_start_url = https://your-company.awsapps.com/start
sso_region = us-east-1
sso_account_id = 123456789012
sso_role_name = Developer
region = us-east-1
output = json

# Example IAM profile
[profile personal]
region = us-east-1
output = json

# Example for AWS CLI call with role assumption
[profile prod]
role_arn = arn:aws:iam::987654321098:role/CrossAccountRole
source_profile = dev
region = us-east-1
output = json
EOF
            info "Created sample AWS config at ~/.aws/config"
            info "Please edit this file with your actual AWS account details"
        fi
        
        # Check for existing AWS credentials
        if [ -f "$HOME/.aws/credentials" ]; then
            info "Existing AWS credentials found at ~/.aws/credentials"
            # Create a backup of the existing credentials
            cp "$HOME/.aws/credentials" "$HOME/.aws/credentials.backup.$(date +%Y%m%d%H%M%S)"
            info "Created backup of your AWS credentials at ~/.aws/credentials.backup.$(date +%Y%m%d%H%M%S)"
            info "Your existing AWS credentials will be preserved"
        fi
        
        log "AWS CLI v2 installation completed"
    fi
    
    # Install AWS development tools
    if is_selected "aws_tools"; then
        section "Installing AWS development tools"
        log "Installing AWS development tools"
        
        info "Installing pipx for isolated Python application installation"
        sudo apt install -y pipx python3-full >> "$INSTALL_LOG" 2>&1
        pipx ensurepath >> "$INSTALL_LOG" 2>&1
        
        info "Installing AWS utilities using pipx"
        pipx install aws-sso-util >> "$INSTALL_LOG" 2>&1
        pipx install aws-profile-switcher >> "$INSTALL_LOG" 2>&1
        
        # Make pipx installed tools available in current shell
        export PATH="$HOME/.local/bin:$PATH"
        
        info "Installing AWS SAM CLI and CDK CLI using pipx"
        pipx install aws-sam-cli >> "$INSTALL_LOG" 2>&1
        pipx install aws-cdk-cli >> "$INSTALL_LOG" 2>&1
        
        log "AWS development tools installation completed"
    fi
    
    # Install AWS helper functions
    if is_selected "aws_helpers"; then
        section "Setting up AWS helper functions"
        log "Setting up AWS helper functions"
        
        # Create AWS tools directory
        mkdir -p "$HOME/.aws-tools"
        
        # Create AWS helper functions file
        info "Creating AWS helper functions file"
        cat > "$HOME/.aws-tools/aws-functions.sh" << 'EOF'
#!/bin/bash
# AWS Power User functions and aliases

# Profile switching
awsp() {
  local profiles=$(aws configure list-profiles 2>/dev/null)
  if [ -z "$profiles" ]; then
    echo "No AWS profiles found. Check your AWS configuration."
    return 1
  fi
  
  local selected=$(echo "$profiles" | fzf --height 15)
  if [ -n "$selected" ]; then
    export AWS_PROFILE="$selected"
    echo "Switched to AWS profile: $selected"
  else
    echo "No profile selected"
  fi
}

# AWS specific aliases and functions
alias awsid="aws sts get-caller-identity"
alias awsr="aws --region"
alias awss3="aws s3 ls"
alias awsec2="aws ec2 describe-instances --output table"
alias awslambda="aws lambda list-functions --output table"
alias awsw="aws --profile work"
alias awsd="aws --profile dev"
alias awsl="aws configure list-profiles"

# Region switching
awsregion() {
  local regions=$(aws ec2 describe-regions --query 'Regions[*].RegionName' --output text)
  if [[ -z "$regions" ]]; then
    echo "Could not retrieve AWS regions"
    return 1
  fi
  
  local selected=$(echo "$regions" | fzf)
  if [[ -n "$selected" ]]; then
    export AWS_REGION="$selected"
    export AWS_DEFAULT_REGION="$selected"
    echo "Switched to region: $selected"
  fi
}

# CloudWatch logs
awslogs() {
  local log_groups=$(aws logs describe-log-groups --query 'logGroups[*].logGroupName' --output text)
  if [[ -z "$log_groups" ]]; then
    echo "No log groups found"
    return 1
  fi
  
  local selected=$(echo "$log_groups" | fzf)
  if [[ -n "$selected" ]]; then
    aws logs tail "$selected" --follow
  fi
}

# EC2 instances
awsec2list() {
  aws ec2 describe-instances \
    --filters "Name=instance-state-name,Values=running" \
    --output table
}

# CloudFormation stacks
awscf() {
  aws cloudformation list-stacks --output table
}

# AWS Session Manager helper
ssm-connect() {
  if [ -z "$1" ]; then
    echo "Usage: ssm-connect <instance-id>"
    return 1
  fi
  aws ssm start-session --target "$1"
}

# AWS Session Manager helper with selection
ssm-list-connect() {
  local instances=$(aws ec2 describe-instances \
    --filters "Name=instance-state-name,Values=running" \
    --query 'Reservations[*].Instances[*].[InstanceId,Tags[?Key==`Name`].Value|[0],State.Name,PrivateIpAddress]' \
    --output text)
  
  if [[ -z "$instances" ]]; then
    echo "No running instances found"
    return 1
  fi
  
  local selected=$(echo "$instances" | column -t | fzf | awk '{print $1}')
  if [[ -n "$selected" ]]; then
    echo "Connecting to instance $selected..."
    aws ssm start-session --target "$selected"
  else
    echo "No instance selected"
  fi
}

# ECR login
ecr-login() {
  local region=${1:-$(aws configure get region)}
  if [[ -z "$region" ]]; then
    region="us-east-1"
  fi
  local account=$(aws sts get-caller-identity --query Account --output text)
  if [[ -z "$account" ]]; then
    echo "Could not get AWS account ID. Check your AWS credentials."
    return 1
  fi
  
  echo "Logging into ECR in region $region for account $account..."
  aws ecr get-login-password --region "$region" | docker login --username AWS --password-stdin "$account.dkr.ecr.$region.amazonaws.com"
}

# Install fzf if needed for these functions
command -v fzf >/dev/null 2>&1 || {
  echo "fzf is required for these functions. Please install it: sudo apt install -y fzf"
}
EOF
        
        # Make AWS functions executable
        chmod +x "$HOME/.aws-tools/aws-functions.sh"
        
        # Add AWS functions to .zshrc if not already added
        if is_selected "zsh" && ! grep -q "source.*aws-functions.sh" "$HOME/.zshrc" 2>/dev/null; then
            info "Adding AWS functions to .zshrc"
            echo "" >> "$HOME/.zshrc"
            echo "# AWS functions and aliases" >> "$HOME/.zshrc"
            echo "source \$HOME/.aws-tools/aws-functions.sh" >> "$HOME/.zshrc"
        else
            info "AWS functions will be added to your shell configuration"
            # Create a shell-independent file that can be sourced from .bashrc or .zshrc
            echo "# Source this file in your .bashrc or .zshrc to load AWS helper functions" > "$HOME/.aws-tools/aws-shell-config.sh"
            echo "source \$HOME/.aws-tools/aws-functions.sh" >> "$HOME/.aws-tools/aws-shell-config.sh"
            info "Created $HOME/.aws-tools/aws-shell-config.sh"
            info "Add the following line to your shell configuration to use AWS helper functions:"
            info "  source \$HOME/.aws-tools/aws-shell-config.sh"
        fi
        
        # Install fzf if needed for AWS helper functions
        if ! command_exists fzf; then
            info "Installing fzf for AWS helper functions"
            sudo apt install -y fzf >> "$INSTALL_LOG" 2>&1
        fi
        
        log "AWS helper functions setup completed"
    fi
    
    # Install Node.js and npm
    if is_selected "node"; then
        section "Installing Node.js and npm"
        log "Installing Node.js and npm"
        
        if ! command_exists node; then
            info "Adding NodeSource repository"
            curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - >> "$INSTALL_LOG" 2>&1
            info "Installing Node.js and npm"
            sudo apt install -y nodejs >> "$INSTALL_LOG" 2>&1
            info "Node.js $(node -v) and npm $(npm -v) installed"
            
            # Configure npm to install global packages in user directory
            info "Configuring npm to use a user directory for global packages"
            mkdir -p "$HOME/.npm-global"
            npm config set prefix "$HOME/.npm-global" >> "$INSTALL_LOG" 2>&1
            
            # Add npm global bin to PATH
            export PATH="$HOME/.npm-global/bin:$PATH"
            
            # Add npm global bin to shell config
            if is_selected "zsh" && ! grep -q "PATH.*\.npm-global/bin" "$HOME/.zshrc" 2>/dev/null; then
                echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> "$HOME/.zshrc"
            else
                info "Created npm global bin PATH configuration"
                echo 'export PATH="$HOME/.npm-global/bin:$PATH"' > "$HOME/.aws-tools/npm-path.sh"
                info "Add the following line to your shell configuration to use npm global packages:"
                info "  source \$HOME/.aws-tools/npm-path.sh"
            fi
            
            # Install Serverless Framework if AWS tools are selected
            if is_selected "aws_tools"; then
                info "Installing Serverless Framework"
                npm install -g serverless >> "$INSTALL_LOG" 2>&1
            fi
        else
            info "Node.js $(node -v) and npm $(npm -v) already installed"
        fi
        
        log "Node.js and npm installation completed"
    fi
    
    # Install Python development tools
    if is_selected "python"; then
        section "Installing Python development tools"
        log "Installing Python development tools"
        
        info "Installing Python development packages"
        sudo apt install -y python3 python3-pip python3-venv >> "$INSTALL_LOG" 2>&1
        
        # Setup virtualenv and virtualenvwrapper
        info "Installing virtualenv and virtualenvwrapper"
        pip3 install --user virtualenv virtualenvwrapper >> "$INSTALL_LOG" 2>&1
        
        # Add virtualenvwrapper configuration to shell
        if is_selected "zsh" && ! grep -q "virtualenvwrapper.sh" "$HOME/.zshrc" 2>/dev/null; then
            echo '' >> "$HOME/.zshrc"
            echo '# Virtualenvwrapper configuration' >> "$HOME/.zshrc"
            echo 'export WORKON_HOME=$HOME/.virtualenvs' >> "$HOME/.zshrc"
            echo 'export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3' >> "$HOME/.zshrc"
            echo 'source ~/.local/bin/virtualenvwrapper.sh' >> "$HOME/.zshrc"
        else
            info "Created virtualenvwrapper configuration"
            mkdir -p "$HOME/.aws-tools"
            echo '# Virtualenvwrapper configuration' > "$HOME/.aws-tools/python-config.sh"
            echo 'export WORKON_HOME=$HOME/.virtualenvs' >> "$HOME/.aws-tools/python-config.sh"
            echo 'export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3' >> "$HOME/.aws-tools/python-config.sh"
            echo 'source ~/.local/bin/virtualenvwrapper.sh' >> "$HOME/.aws-tools/python-config.sh"
            info "Add the following line to your shell configuration to use virtualenvwrapper:"
            info "  source \$HOME/.aws-tools/python-config.sh"
        fi
        
        # Install pylint and black
        info "Installing pylint and black for code quality"
        pip3 install --user pylint black >> "$INSTALL_LOG" 2>&1
        
        log "Python development tools installation completed"
    fi
    
    # Install Docker with ECR integration
    if is_selected "docker"; then
        section "Setting up Docker support"
        log "Setting up Docker support"
        
        if ! command_exists docker; then
            info "Installing Docker inside WSL"
            # Install Docker prerequisites
            sudo apt install -y apt-transport-https ca-certificates curl software-properties-common gnupg lsb-release >> "$INSTALL_LOG" 2>&1
            
            # Add Docker's official GPG key
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg >> "$INSTALL_LOG" 2>&1
            
            # Set up the stable repository
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
            
            # Install Docker Engine
            sudo apt update >> "$INSTALL_LOG" 2>&1
            sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin >> "$INSTALL_LOG" 2>&1
            
            # Add current user to the docker group
            sudo usermod -aG docker $USER
            
            # Create Docker config directory if it doesn't exist
            mkdir -p ~/.docker
            
            # Create Docker config file
            if is_selected "aws_cli"; then
                info "Setting up Docker ECR credential helper"
                cat > ~/.docker/config.json << 'EOF'
{
  "credHelpers": {
    "public.ecr.aws": "ecr-login",
    "*.dkr.ecr.*.amazonaws.com": "ecr-login"
  }
}
EOF
                
                # Install AWS ECR Docker credential helper
                pipx install amazon-ecr-credential-helper >> "$INSTALL_LOG" 2>&1
            else
                touch ~/.docker/config.json
                echo "{}" > ~/.docker/config.json
            fi
            
            info "Docker installed. You may need to restart your session to use Docker without sudo"
            info "Use Docker with: docker run hello-world"
        else
            info "Docker already installed"
        fi
        
        # Add Docker shortcuts
        if is_selected "aws_helpers"; then
            cat >> "$HOME/.aws-tools/aws-functions.sh" << 'EOF'

# Docker shortcuts
alias dps="docker ps"
alias dpsa="docker ps -a"
alias dimg="docker images"
alias drm="docker rm"
alias drmi="docker rmi"
alias drun="docker run -it"
alias dexec="docker exec -it"
alias dcup="docker compose up -d"
alias dcdown="docker compose down"
EOF
            info "Added Docker aliases to AWS helper functions"
        fi
        
        log "Docker setup completed"
    fi
    
    # Install Terraform
    if is_selected "terraform"; then
        section "Setting up Terraform"
        log "Setting up Terraform"
        
        if ! command_exists terraform; then
            info "Installing Terraform"
            # Add HashiCorp GPG key
            wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg >> "$INSTALL_LOG" 2>&1
            
            # Add HashiCorp repository
            echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list >> "$INSTALL_LOG" 2>&1
            
            # Install Terraform
            sudo apt update >> "$INSTALL_LOG" 2>&1
            sudo apt install -y terraform >> "$INSTALL_LOG" 2>&1
            
            # Enable Terraform autocompletion
            terraform -install-autocomplete >> "$INSTALL_LOG" 2>&1
            
            # Add Terraform workspace functions if AWS helpers are selected
            if is_selected "aws_helpers"; then
                cat >> "$HOME/.aws-tools/aws-functions.sh" << 'EOF'

# Terraform shortcuts
alias tf="terraform"
alias tfi="terraform init"
alias tfp="terraform plan"
alias tfa="terraform apply"
alias tfd="terraform destroy"
alias tfo="terraform output"

# Function to select Terraform workspace
tfws() {
  if [ ! -d ".terraform" ]; then
    echo "Not a Terraform directory or Terraform not initialized"
    return 1
  fi
  
  workspaces=$(terraform workspace list | sed 's/^[ *]*//')
  if [ -z "$workspaces" ]; then
    echo "No workspaces found"
    return 1
  fi
  
  selected=$(echo "$workspaces" | fzf)
  if [ -n "$selected" ]; then
    terraform workspace select "$selected"
  else
    echo "No workspace selected"
  fi
}
EOF
                info "Added Terraform shortcuts and workspace function to AWS helper functions"
            fi
        else
            info "Terraform already installed"
        fi
        
        log "Terraform setup completed"
    fi
    
    # Install Kubernetes tools with EKS integration
    if is_selected "kubernetes"; then
        section "Setting up Kubernetes tools with EKS integration"
        log "Setting up Kubernetes tools with EKS integration"
        
        # Install kubectl 
        if ! command_exists kubectl; then
            info "Installing kubectl"
            sudo apt update >> "$INSTALL_LOG" 2>&1
            sudo apt install -y apt-transport-https ca-certificates curl >> "$INSTALL_LOG" 2>&1
            
            # Download and install kubectl
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" >> "$INSTALL_LOG" 2>&1
            sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl >> "$INSTALL_LOG" 2>&1
            rm kubectl
            
            info "kubectl $(kubectl version --client -o yaml | grep -m 1 gitVersion | cut -d':' -f2 | tr -d ' ') installed"
        else
            info "kubectl already installed"
        fi
        
        # Install eksctl
        if ! command_exists eksctl; then
            info "Installing eksctl"
            # Get the latest eksctl version
            EKSCTL_VERSION=$(curl -s https://api.github.com/repos/weaveworks/eksctl/releases/latest | grep tag_name | cut -d '"' -f 4)
            if [ -z "$EKSCTL_VERSION" ]; then
                # Fallback to a known version if unable to get latest
                EKSCTL_VERSION="v0.156.0" 
            fi
            
            # Download and install eksctl
            curl -sLO "https://github.com/weaveworks/eksctl/releases/download/${EKSCTL_VERSION}/eksctl_$(uname -s)_amd64.tar.gz" >> "$INSTALL_LOG" 2>&1
            tar -xzf eksctl_$(uname -s)_amd64.tar.gz -C /tmp >> "$INSTALL_LOG" 2>&1
            sudo mv /tmp/eksctl /usr/local/bin >> "$INSTALL_LOG" 2>&1
            rm eksctl_$(uname -s)_amd64.tar.gz
            
            info "eksctl $(eksctl version) installed"
        else
            info "eksctl already installed"
        fi
        
        # Install Helm
        if ! command_exists helm; then
            info "Installing Helm"
            curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 >> "$INSTALL_LOG" 2>&1
            chmod 700 get_helm.sh
            ./get_helm.sh >> "$INSTALL_LOG" 2>&1
            rm get_helm.sh
            
            info "Helm $(helm version --short) installed"
        else
            info "Helm already installed"
        fi
        
        # Install k9s - Kubernetes CLI to manage clusters
        if ! command_exists k9s; then
            info "Installing k9s"
            K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep tag_name | cut -d '"' -f 4)
            if [ -z "$K9S_VERSION" ]; then
                # Fallback to a known version if unable to get latest
                K9S_VERSION="v0.26.7"
            fi
            
            curl -sLO "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz" >> "$INSTALL_LOG" 2>&1
            tar -xzf k9s_Linux_amd64.tar.gz -C /tmp >> "$INSTALL_LOG" 2>&1
            sudo mv /tmp/k9s /usr/local/bin >> "$INSTALL_LOG" 2>&1
            rm k9s_Linux_amd64.tar.gz
            
            info "k9s installed"
        else
            info "k9s already installed"
        fi
        
        # Install kubectx and kubens for easier context switching
        if ! command_exists kubectx; then
            info "Installing kubectx and kubens"
            sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx >> "$INSTALL_LOG" 2>&1
            sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
            sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens
            
            info "kubectx and kubens installed"
        else
            info "kubectx and kubens already installed"
        fi
        
        # Check for existing Kubernetes config
        if [ -f "$HOME/.kube/config" ]; then
            info "Existing Kubernetes config found at ~/.kube/config"
            # Create a backup of the existing config
            cp "$HOME/.kube/config" "$HOME/.kube/config.backup.$(date +%Y%m%d%H%M%S)"
            info "Created backup of your Kubernetes config at ~/.kube/config.backup.$(date +%Y%m%d%H%M%S)"
            info "Your existing Kubernetes cluster configurations will be preserved"
        else
            # Create Kubernetes config directory if it doesn't exist
            mkdir -p "$HOME/.kube"
        fi
        
        # Add EKS helper functions if AWS helpers are selected
        if is_selected "aws_helpers"; then
            info "Adding EKS helper functions"
            cat >> "$HOME/.aws-tools/aws-functions.sh" << 'EOF'

# Kubernetes/EKS helper functions and aliases

# Aliases for kubectl
alias k="kubectl"
alias kg="kubectl get"
alias kgp="kubectl get pods"
alias kgs="kubectl get services"
alias kgd="kubectl get deployments"
alias kgn="kubectl get nodes"
alias kd="kubectl describe"
alias kdp="kubectl describe pod"
alias ke="kubectl exec -it"
alias kl="kubectl logs"
alias klf="kubectl logs -f"

# Function to list all EKS clusters in the current AWS account/region
eks-list() {
  echo "Listing EKS clusters in region ${AWS_REGION:-$(aws configure get region)}"
  aws eks list-clusters --output table
}

# Function to get EKS cluster details
eks-describe() {
  if [ -z "$1" ]; then
    echo "Usage: eks-describe <cluster-name>"
    return 1
  fi
  
  aws eks describe-cluster --name "$1" --output table
}

# Function to update kubeconfig for EKS cluster
eks-kubeconfig() {
  if [ -z "$1" ]; then
    echo "Usage: eks-kubeconfig <cluster-name> [region]"
    return 1
  fi
  
  local cluster_name="$1"
  local region="${2:-${AWS_REGION:-$(aws configure get region)}}"
  
  # Check if we already have a kubeconfig and create a backup if needed
  if [ -f "$HOME/.kube/config" ]; then
    # Only create a backup if we haven't already done so in this session
    if [ ! -f "$HOME/.kube/config.eks-update-backup" ]; then
      cp "$HOME/.kube/config" "$HOME/.kube/config.eks-update-backup"
      echo "Created backup of your kubeconfig at ~/.kube/config.eks-update-backup"
    fi
  fi
  
  echo "Updating kubeconfig for EKS cluster $cluster_name in region $region"
  aws eks update-kubeconfig --name "$cluster_name" --region "$region"
  echo "Kubeconfig updated. Current context: $(kubectl config current-context)"
}

# Function to switch between EKS clusters interactively
eks-switch() {
  local clusters=$(aws eks list-clusters --output text --query 'clusters[]')
  if [[ -z "$clusters" ]]; then
    echo "No EKS clusters found in region ${AWS_REGION:-$(aws configure get region)}"
    return 1
  fi
  
  local selected=$(echo "$clusters" | fzf --height 15)
  if [[ -n "$selected" ]]; then
    eks-kubeconfig "$selected"
  else
    echo "No cluster selected"
  fi
}

# Function to update EKS credentials when switching AWS profiles
eks-update-credentials() {
  if [[ -z "$1" ]]; then
    # Use current context if no argument is provided
    local context="$(kubectl config current-context 2>/dev/null)"
    if [[ $? -ne 0 || -z "$context" ]]; then
      echo "No active Kubernetes context found"
      return 1
    fi
  else
    local context="$1"
  fi
  
  # Check if this is an EKS context
  if [[ "$context" == *"eks"* ]]; then
    local cluster_name=$(echo "$context" | sed -n 's/.*@\(.*\)\..*/\1/p')
    local region=$(echo "$context" | sed -n 's/.*\.\(.*\)\.eks.*/\1/p')
    
    if [[ -n "$cluster_name" && -n "$region" ]]; then
      echo "Updating credentials for EKS cluster $cluster_name in region $region"
      
      # Check if we already have a kubeconfig and create a backup if needed
      if [ -f "$HOME/.kube/config" ]; then
        # Create a backup with context name
        cp "$HOME/.kube/config" "$HOME/.kube/config.backup.$(date +%Y%m%d%H%M%S)"
        echo "Created backup of your kubeconfig at ~/.kube/config.backup.$(date +%Y%m%d%H%M%S)"
      fi
      
      aws eks update-kubeconfig --name "$cluster_name" --region "$region"
    else
      echo "Could not extract cluster name and region from context: $context"
      return 1
    fi
  else
    echo "The context '$context' does not appear to be an EKS cluster"
    return 1
  fi
}

# Hook into profile switching to update EKS credentials automatically
# Save original awsp function
eval "$(declare -f awsp | sed '1s/awsp/_original_awsp/')"

# Override awsp to also update EKS credentials
awsp() {
  # Call the original awsp function
  _original_awsp "$@"
  
  # If profile was switched successfully, update EKS credentials if we have an active context
  if [[ $? -eq 0 && -n "$AWS_PROFILE" ]]; then
    local context=$(kubectl config current-context 2>/dev/null)
    if [[ $? -eq 0 && -n "$context" && "$context" == *"eks"* ]]; then
      echo "Detected EKS context: $context"
      eks-update-credentials "$context"
    fi
  fi
}

# Function to list all pods across all namespaces with useful information
eks-pods() {
  kubectl get pods --all-namespaces -o wide
}

# Function to list all nodes with status and resource usage
eks-nodes() {
  kubectl get nodes -o wide
  echo ""
  echo "Node resource usage:"
  kubectl top nodes
}

# Function to get a shell on a pod
eks-shell() {
  if [ -z "$1" ]; then
    echo "Usage: eks-shell <pod-name> [namespace] [container]"
    return 1
  fi
  
  local pod="$1"
  local namespace="${2:-default}"
  local container_args=""
  
  if [ -n "$3" ]; then
    container_args="-c $3"
  fi
  
  kubectl exec -it -n "$namespace" "$pod" $container_args -- sh -c '(bash || ash || sh)'
}

# Function to install AWS Load Balancer Controller on EKS
eks-install-alb() {
  if [ -z "$1" ]; then
    echo "Usage: eks-install-alb <cluster-name> [region]"
    return 1
  fi
  
  local cluster_name="$1"
  local region="${2:-${AWS_REGION:-$(aws configure get region)}}"
  
  echo "Installing AWS Load Balancer Controller on EKS cluster $cluster_name in region $region"
  
  # Ensure we have the EKS charts repo
  helm repo add eks https://aws.github.io/eks-charts
  helm repo update
  
  # Get VPC ID for the cluster
  local vpc_id=$(aws eks describe-cluster --name "$cluster_name" --region "$region" --query "cluster.resourcesVpcConfig.vpcId" --output text)
  if [ -z "$vpc_id" ]; then
    echo "Could not get VPC ID for cluster $cluster_name"
    return 1
  fi
  
  # Get AWS account ID
  local account_id=$(aws sts get-caller-identity --query Account --output text)
  if [ -z "$account_id" ]; then
    echo "Could not get AWS account ID"
    return 1
  fi
  
  echo "Creating IAM policy for ALB Controller"
  curl -o alb-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json
  
  aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy-$cluster_name \
    --policy-document file://alb-policy.json \
    --region "$region"
  
  rm alb-policy.json
  
  echo "Creating service account for ALB Controller"
  eksctl create iamserviceaccount \
    --cluster="$cluster_name" \
    --namespace=kube-system \
    --name=aws-load-balancer-controller \
    --attach-policy-arn=arn:aws:iam::$account_id:policy/AWSLoadBalancerControllerIAMPolicy-$cluster_name \
    --override-existing-serviceaccounts \
    --region "$region" \
    --approve
  
  echo "Installing AWS Load Balancer Controller with Helm"
  helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
    -n kube-system \
    --set clusterName="$cluster_name" \
    --set serviceAccount.create=false \
    --set serviceAccount.name=aws-load-balancer-controller \
    --set region="$region" \
    --set vpcId="$vpc_id"
  
  echo "AWS Load Balancer Controller installation completed"
}
EOF
            info "Added EKS helper functions to AWS helper functions"
        fi
        
        # Create a sample EKS management script
        mkdir -p "$HOME/.aws-tools/eks"
        cat > "$HOME/.aws-tools/eks/eks-management.sh" << 'EOF'
#!/bin/bash
# EKS Management Script
# This script provides common operations for EKS clusters

set -e

# Color codes for output
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

# Display the menu
show_menu() {
    clear
    section "EKS Management"
    echo "1) List EKS clusters"
    echo "2) Create a new EKS cluster"
    echo "3) Delete an EKS cluster"
    echo "4) Update kubeconfig for cluster"
    echo "5) View cluster details"
    echo "6) View cluster nodes"
    echo "7) View cluster workloads"
    echo "8) Install AWS Load Balancer Controller"
    echo "9) Install common add-ons"
    echo "10) Show kubectl contexts"
    echo "11) Switch kubectl context"
    echo ""
    echo "q) Quit"
    echo ""
    read -p "Enter your choice: " choice
}

# List EKS clusters
list_clusters() {
    section "EKS Clusters"
    aws eks list-clusters --output table
    read -p "Press Enter to continue..."
}

# Create a new EKS cluster
create_cluster() {
    section "Create EKS Cluster"
    read -p "Enter cluster name: " cluster_name
    read -p "Enter AWS region [us-east-1]: " region
    region=${region:-us-east-1}
    read -p "Enter Kubernetes version [1.27]: " k8s_version
    k8s_version=${k8s_version:-1.27}
    read -p "Enter number of nodes [2]: " nodes
    nodes=${nodes:-2}
    read -p "Enter node instance type [t3.medium]: " instance_type
    instance_type=${instance_type:-t3.medium}
    
    info "Creating EKS cluster $cluster_name in region $region"
    info "This will take 15-20 minutes..."
    
    eksctl create cluster \
      --name "$cluster_name" \
      --region "$region" \
      --version "$k8s_version" \
      --nodes "$nodes" \
      --node-type "$instance_type" \
      --with-oidc
    
    info "EKS cluster $cluster_name created successfully"
    read -p "Press Enter to continue..."
}

# Delete an EKS cluster
delete_cluster() {
    section "Delete EKS Cluster"
    read -p "Enter cluster name: " cluster_name
    read -p "Enter AWS region [us-east-1]: " region
    region=${region:-us-east-1}
    
    read -p "Are you sure you want to delete cluster $cluster_name? This cannot be undone. [y/N] " confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        info "Deleting EKS cluster $cluster_name in region $region"
        info "This will take 10-15 minutes..."
        
        eksctl delete cluster --name "$cluster_name" --region "$region"
        
        info "EKS cluster $cluster_name deleted successfully"
    else
        info "Deletion cancelled"
    fi
    
    read -p "Press Enter to continue..."
}

# Update kubeconfig for cluster
update_kubeconfig() {
    section "Update Kubeconfig"
    read -p "Enter cluster name: " cluster_name
    read -p "Enter AWS region [us-east-1]: " region
    region=${region:-us-east-1}
    
    info "Updating kubeconfig for EKS cluster $cluster_name in region $region"
    
    # Check if we already have a kubeconfig and create a backup if needed
    if [ -f "$HOME/.kube/config" ]; then
        # Create a timestamped backup
        cp "$HOME/.kube/config" "$HOME/.kube/config.backup.$(date +%Y%m%d%H%M%S)"
        info "Created backup of your kubeconfig at ~/.kube/config.backup.$(date +%Y%m%d%H%M%S)"
    fi
    
    aws eks update-kubeconfig --name "$cluster_name" --region "$region"
    
    info "Kubeconfig updated. Current context: $(kubectl config current-context)"
    read -p "Press Enter to continue..."
}

# View cluster details
view_cluster_details() {
    section "Cluster Details"
    read -p "Enter cluster name: " cluster_name
    read -p "Enter AWS region [us-east-1]: " region
    region=${region:-us-east-1}
    
    aws eks describe-cluster --name "$cluster_name" --region "$region" --output table
    
    read -p "Press Enter to continue..."
}

# View cluster nodes
view_cluster_nodes() {
    section "Cluster Nodes"
    
    if ! kubectl get nodes &>/dev/null; then
        error "Could not connect to Kubernetes cluster. Make sure your kubeconfig is set up correctly"
        read -p "Press Enter to continue..."
        return 1
    fi
    
    info "Nodes in the cluster:"
    kubectl get nodes -o wide
    
    echo ""
    info "Node resource usage:"
    kubectl top nodes 2>/dev/null || echo "Metrics Server not installed - no resource usage data available"
    
    read -p "Press Enter to continue..."
}

# View cluster workloads
view_cluster_workloads() {
    section "Cluster Workloads"
    
    if ! kubectl get namespaces &>/dev/null; then
        error "Could not connect to Kubernetes cluster. Make sure your kubeconfig is set up correctly"
        read -p "Press Enter to continue..."
        return 1
    fi
    
    info "Namespaces in the cluster:"
    kubectl get namespaces
    
    echo ""
    info "Deployments across all namespaces:"
    kubectl get deployments --all-namespaces
    
    echo ""
    info "Services across all namespaces:"
    kubectl get services --all-namespaces
    
    echo ""
    info "Pods across all namespaces:"
    kubectl get pods --all-namespaces
    
    read -p "Press Enter to continue..."
}

# Install AWS Load Balancer Controller
install_alb_controller() {
    section "Install AWS Load Balancer Controller"
    read -p "Enter cluster name: " cluster_name
    read -p "Enter AWS region [us-east-1]: " region
    region=${region:-us-east-1}
    
    info "Installing AWS Load Balancer Controller on EKS cluster $cluster_name in region $region"
    
    # Ensure we have the EKS charts repo
    helm repo add eks https://aws.github.io/eks-charts
    helm repo update
    
    # Get VPC ID for the cluster
    vpc_id=$(aws eks describe-cluster --name "$cluster_name" --region "$region" --query "cluster.resourcesVpcConfig.vpcId" --output text)
    if [ -z "$vpc_id" ]; then
        error "Could not get VPC ID for cluster $cluster_name"
        read -p "Press Enter to continue..."
        return 1
    fi
    
    # Get AWS account ID
    account_id=$(aws sts get-caller-identity --query Account --output text)
    if [ -z "$account_id" ]; then
        error "Could not get AWS account ID"
        read -p "Press Enter to continue..."
        return 1
    fi
    
    info "Creating IAM policy for ALB Controller"
    curl -o alb-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json
    
    policy_exists=$(aws iam list-policies --query "Policies[?PolicyName=='AWSLoadBalancerControllerIAMPolicy-$cluster_name'].Arn" --output text)
    
    if [ -z "$policy_exists" ]; then
        aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy-$cluster_name \
          --policy-document file://alb-policy.json \
          --region "$region"
        
        policy_arn="arn:aws:iam::$account_id:policy/AWSLoadBalancerControllerIAMPolicy-$cluster_name"
    else
        policy_arn="$policy_exists"
        info "Policy already exists: $policy_arn"
    fi
    
    rm alb-policy.json
    
    info "Creating service account for ALB Controller"
    eksctl create iamserviceaccount \
      --cluster="$cluster_name" \
      --namespace=kube-system \
      --name=aws-load-balancer-controller \
      --attach-policy-arn="$policy_arn" \
      --override-existing-serviceaccounts \
      --region "$region" \
      --approve
    
    info "Installing AWS Load Balancer Controller with Helm"
    helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
      -n kube-system \
      --set clusterName="$cluster_name" \
      --set serviceAccount.create=false \
      --set serviceAccount.name=aws-load-balancer-controller \
      --set region="$region" \
      --set vpcId="$vpc_id"
    
    info "AWS Load Balancer Controller installation completed"
    read -p "Press Enter to continue..."
}

# Install common add-ons
install_addons() {
    section "Install Common Add-ons"
    
    echo "Available add-ons:"
    echo "1) Metrics Server"
    echo "2) Kubernetes Dashboard"
    echo "3) NGINX Ingress Controller"
    echo "4) Prometheus and Grafana"
    echo ""
    echo "b) Back to main menu"
    echo ""
    read -p "Enter your choice: " addon_choice
    
    case "$addon_choice" in
        1)
            info "Installing Metrics Server"
            kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
            info "Metrics Server installed. It may take a minute to become available."
            ;;
        2)
            info "Installing Kubernetes Dashboard"
            kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
            
            # Create admin user for dashboard
            cat << EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF
            
            info "Kubernetes Dashboard installed"
            info "To access the dashboard, run: kubectl proxy"
            info "Then visit: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"
            
            token=$(kubectl -n kubernetes-dashboard create token admin-user)
            info "Login token: $token"
            ;;
        3)
            info "Installing NGINX Ingress Controller"
            helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
            helm repo update
            helm install nginx-ingress ingress-nginx/ingress-nginx
            
            info "NGINX Ingress Controller installed"
            info "It may take a few minutes for the load balancer to be provisioned"
            ;;
        4)
            info "Installing Prometheus and Grafana"
            helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
            helm repo update
            helm install prometheus prometheus-community/kube-prometheus-stack
            
            info "Prometheus and Grafana installed"
            info "To access Grafana, run: kubectl port-forward svc/prometheus-grafana 8080:80"
            info "Then visit: http://localhost:8080"
            info "Default credentials: admin / prom-operator"
            ;;
        b|B)
            return 0
            ;;
        *)
            error "Invalid choice"
            ;;
    esac
    
    read -p "Press Enter to continue..."
}

# Show kubectl contexts
show_contexts() {
    section "Kubectl Contexts"
    
    if command_exists kubectx; then
        kubectx
    else
        kubectl config get-contexts
    fi
    
    read -p "Press Enter to continue..."
}

# Switch kubectl context
switch_context() {
    section "Switch Kubectl Context"
    
    if command_exists kubectx; then
        kubectx
    else
        contexts=$(kubectl config get-contexts -o name)
        
        if [ -z "$contexts" ]; then
            error "No Kubernetes contexts found"
            read -p "Press Enter to continue..."
            return 1
        fi
        
        echo "Available contexts:"
        i=1
        for ctx in $contexts; do
            echo "$i) $ctx"
            ((i++))
        done
        
        echo ""
        read -p "Enter context number: " ctx_num
        
        if [[ "$ctx_num" =~ ^[0-9]+$ ]] && [ "$ctx_num" -ge 1 ] && [ "$ctx_num" -le "$i" ]; then
            selected_ctx=$(echo "$contexts" | sed -n "${ctx_num}p")
            kubectl config use-context "$selected_ctx"
            info "Switched to context: $selected_ctx"
        else
            error "Invalid context number"
        fi
    fi
    
    read -p "Press Enter to continue..."
}

# Main loop
while true; do
    show_menu
    
    case "$choice" in
        1) list_clusters ;;
        2) create_cluster ;;
        3) delete_cluster ;;
        4) update_kubeconfig ;;
        5) view_cluster_details ;;
        6) view_cluster_nodes ;;
        7) view_cluster_workloads ;;
        8) install_alb_controller ;;
        9) install_addons ;;
        10) show_contexts ;;
        11) switch_context ;;
        q|Q) break ;;
        *) error "Invalid choice" ;;
    esac
done

section "Exiting EKS Management Tool"
EOF
        
        # Make the EKS management script executable
        chmod +x "$HOME/.aws-tools/eks/eks-management.sh"
        
        # Add EKS management script launcher if AWS helpers are selected
        if is_selected "aws_helpers"; then
            cat >> "$HOME/.aws-tools/aws-functions.sh" << 'EOF'

# Function to launch the EKS management script
eks-manage() {
  "$HOME/.aws-tools/eks/eks-management.sh"
}
EOF
        fi
        
        # Add kubectl bash completion
        if command_exists kubectl; then
            info "Setting up kubectl bash completion"
            kubectl completion bash > /tmp/kubectl_completion
            sudo mv /tmp/kubectl_completion /etc/bash_completion.d/kubectl
            
            # Add to ZSH if selected
            if is_selected "zsh"; then
                info "Setting up kubectl zsh completion"
                kubectl completion zsh > "$HOME/.oh-my-zsh/completions/_kubectl"
                
                # Add Helm completion
                if command_exists helm; then
                    info "Setting up Helm zsh completion"
                    helm completion zsh > "$HOME/.oh-my-zsh/completions/_helm"
                fi
                
                # Add eksctl completion
                if command_exists eksctl; then
                    info "Setting up eksctl zsh completion"
                    eksctl completion zsh > "$HOME/.oh-my-zsh/completions/_eksctl"
                fi
            fi
        fi
        
        info "Kubernetes tools with EKS integration setup complete"
        log "Kubernetes tools with EKS integration setup completed"
    fi
    
    # Install modern CLI tools
    if is_selected "modern_cli"; then
        section "Installing modern CLI tools"
        log "Installing modern CLI tools"
        
        # Install and configure tldr for simplified man pages
        info "Installing tldr for simplified command examples"
        sudo apt install -y tldr >> "$INSTALL_LOG" 2>&1
        tldr --update >> "$INSTALL_LOG" 2>&1
        
        # Install and configure direnv for environment switching
        info "Installing direnv for automatic environment switching"
        sudo apt install -y direnv >> "$INSTALL_LOG" 2>&1
        if is_selected "zsh" && ! grep -q "direnv hook" "$HOME/.zshrc" 2>/dev/null; then
            echo 'eval "$(direnv hook zsh)"' >> "$HOME/.zshrc"
        else
            info "Created direnv configuration"
            echo 'eval "$(direnv hook bash)"  # Change bash to your shell if different' > "$HOME/.aws-tools/direnv-config.sh"
            info "Add the following line to your shell configuration to use direnv:"
            info "  source \$HOME/.aws-tools/direnv-config.sh"
        fi
        
        # Install and configure bat for better file viewing
        info "Installing bat for syntax highlighted file viewing"
        sudo apt install -y bat >> "$INSTALL_LOG" 2>&1
        if ! command -v bat &> /dev/null; then
            # On some systems, bat is installed as batcat
            if is_selected "zsh"; then
                echo 'alias bat="batcat"' >> "$HOME/.zshrc"
            else
                echo 'alias bat="batcat"' > "$HOME/.aws-tools/bat-alias.sh"
                info "Add the following line to your shell configuration to use bat:"
                info "  source \$HOME/.aws-tools/bat-alias.sh"
            fi
        fi
        
        # Install and configure exa/eza for better directory listings
        if apt-cache show eza &> /dev/null; then
            info "Installing eza for enhanced directory listings"
            sudo apt install -y eza >> "$INSTALL_LOG" 2>&1
            if is_selected "zsh"; then
                cat >> "$HOME/.zshrc" << 'EOF'

# Use eza instead of ls
alias ls="eza --icons"
alias ll="eza --icons -la"
alias lt="eza --icons -T --level=2"
alias ltl="eza --icons -T --level=2 -l"
EOF
            else
                cat > "$HOME/.aws-tools/eza-aliases.sh" << 'EOF'
# Use eza instead of ls
alias ls="eza --icons"
alias ll="eza --icons -la"
alias lt="eza --icons -T --level=2"
alias ltl="eza --icons -T --level=2 -l"
EOF
                info "Add the following line to your shell configuration to use eza:"
                info "  source \$HOME/.aws-tools/eza-aliases.sh"
            fi
        elif apt-cache show exa &> /dev/null; then
            info "Installing exa for enhanced directory listings"
            sudo apt install -y exa >> "$INSTALL_LOG" 2>&1
            if is_selected "zsh"; then
                cat >> "$HOME/.zshrc" << 'EOF'

# Use exa instead of ls
alias ls="exa --icons"
alias ll="exa --icons -la"
alias lt="exa --icons -T --level=2"
alias ltl="exa --icons -T --level=2 -l"
EOF
            else
                cat > "$HOME/.aws-tools/exa-aliases.sh" << 'EOF'
# Use exa instead of ls
alias ls="exa --icons"
alias ll="exa --icons -la"
alias lt="exa --icons -T --level=2"
alias ltl="exa --icons -T --level=2 -l"
EOF
                info "Add the following line to your shell configuration to use exa:"
                info "  source \$HOME/.aws-tools/exa-aliases.sh"
            fi
        fi
        
        log "Modern CLI tools installation completed"
    fi
    
    # Install Powerline fonts
    if is_selected "fonts"; then
        section "Installing Powerline fonts"
        log "Installing Powerline fonts"
        
        info "Downloading and installing Powerline fonts"
        git clone https://github.com/powerline/fonts.git --depth=1 "/tmp/powerline-fonts" >> "$INSTALL_LOG" 2>&1
        cd "/tmp/powerline-fonts"
        ./install.sh >> "$INSTALL_LOG" 2>&1
        cd "$HOME"
        rm -rf "/tmp/powerline-fonts"
        
        info "Powerline fonts installed"
        info "Recommended fonts for your terminal:"
        info "- DejaVu Sans Mono for Powerline"
        info "- Ubuntu Mono derivative Powerline"
        info "- Source Code Pro for Powerline"
        
        log "Powerline fonts installation completed"
    fi
    
    # Install AWS Session Manager plugin
    if is_selected "session_manager"; then
        section "Setting up AWS Session Manager Plugin"
        log "Setting up AWS Session Manager Plugin"
        
        if ! command_exists session-manager-plugin; then
            info "Installing AWS Session Manager Plugin"
            curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "/tmp/session-manager-plugin.deb" >> "$INSTALL_LOG" 2>&1
            sudo dpkg -i "/tmp/session-manager-plugin.deb" >> "$INSTALL_LOG" 2>&1
            rm "/tmp/session-manager-plugin.deb"
        else
            info "AWS Session Manager Plugin already installed"
        fi
        
        log "AWS Session Manager Plugin setup completed"
    fi
    
    # Install 1Password CLI integration
    if is_selected "onepassword"; then
        section "Setting up 1Password CLI integration"
        log "Setting up 1Password CLI integration"
        
        info "Checking for 1Password CLI on Windows side"
        
        # Check if 1Password CLI is installed on Windows
        if command -v /mnt/c/Program\ Files/1Password/app/8/op.exe &> /dev/null || command -v /mnt/c/Program\ Files/1Password\ CLI/op.exe &> /dev/null; then
            info "1Password CLI detected on Windows"
            
            # Create directory for 1Password CLI
            mkdir -p "$HOME/.1password"
            
            # Create wrapper script for 1Password CLI
            cat > "$HOME/.1password/op" << 'EOF'
#!/bin/bash
# 1Password CLI wrapper for WSL

# Detect the location of the 1Password CLI on Windows
if [ -f "/mnt/c/Program Files/1Password/app/8/op.exe" ]; then
  OP_PATH="/mnt/c/Program Files/1Password/app/8/op.exe"
elif [ -f "/mnt/c/Program Files/1Password CLI/op.exe" ]; then
  OP_PATH="/mnt/c/Program Files/1Password CLI/op.exe"
else
  echo "Error: 1Password CLI not found on Windows" >&2
  exit 1
fi

# Run 1Password CLI with all arguments passed to this script
"$OP_PATH" "$@"
EOF
            
            # Make the wrapper script executable
            chmod +x "$HOME/.1password/op"
            
            # Add 1Password CLI to PATH
            if is_selected "zsh" && ! grep -q "PATH.*\.1password" "$HOME/.zshrc" 2>/dev/null; then
                echo 'export PATH="$HOME/.1password:$PATH"' >> "$HOME/.zshrc"
            else
                echo 'export PATH="$HOME/.1password:$PATH"' > "$HOME/.aws-tools/1password-path.sh"
                info "Add the following line to your shell configuration to use 1Password CLI:"
                info "  source \$HOME/.aws-tools/1password-path.sh"
            fi
            
            # Add 1Password helper functions if AWS helpers are selected
            if is_selected "aws_helpers"; then
                cat >> "$HOME/.aws-tools/aws-functions.sh" << 'EOF'

# 1Password helper functions
op-signin() {
  eval $(op signin)
  echo "1Password signin successful. Session token has been set."
}

# Function to get AWS credentials from 1Password
op-aws() {
  if [ -z "$1" ]; then
    echo "Usage: op-aws <item-name>"
    return 1
  fi
  
  # Get AWS credentials from 1Password
  creds=$(op item get "$1" --format json)
  if [ $? -ne 0 ]; then
    echo "Error retrieving AWS credentials from 1Password"
    return 1
  fi
  
  # Extract fields from JSON
  access_key=$(echo "$creds" | jq -r '.fields[] | select(.id == "username" or .label == "access key ID" or .label == "Access Key ID") | .value')
  secret_key=$(echo "$creds" | jq -r '.fields[] | select(.id == "password" or .label == "secret access key" or .label == "Secret Access Key") | .value')
  
  if [ -z "$access_key" ] || [ -z "$secret_key" ]; then
    echo "Could not find AWS credentials in 1Password item"
    return 1
  fi
  
  # Set AWS environment variables
  export AWS_ACCESS_KEY_ID="$access_key"
  export AWS_SECRET_ACCESS_KEY="$secret_key"
  echo "AWS credentials have been set from 1Password item: $1"
}

# Function to get SSH key from 1Password
op-ssh() {
  if [ -z "$1" ]; then
    echo "Usage: op-ssh <item-name> [field-name]"
    echo "Field name is optional, defaults to 'private key'"
    return 1
  fi
  
  field=${2:-"private key"}
  
  # Create or clean SSH directory
  mkdir -p ~/.ssh
  chmod 700 ~/.ssh
  
  # Get SSH key from 1Password
  key_path="$HOME/.ssh/id_rsa_op"
  op item get "$1" --field "$field" > "$key_path"
  
  if [ $? -ne 0 ] || [ ! -s "$key_path" ]; then
    echo "Error retrieving SSH key from 1Password"
    rm -f "$key_path"
    return 1
  fi
  
  # Set proper permissions
  chmod 600 "$key_path"
  
  # Add key to SSH agent
  eval $(ssh-agent -s)
  ssh-add "$key_path"
  
  echo "SSH key from 1Password item '$1' has been loaded"
}
EOF
                
                # Install jq for JSON parsing (needed for op-aws function)
                sudo apt install -y jq >> "$INSTALL_LOG" 2>&1
            fi
            
            info "1Password CLI integration setup complete"
            info "You can use 'op' command to access 1Password CLI"
            info "Use 'op-signin' to sign in to 1Password"
            if is_selected "aws_helpers"; then
                info "Use 'op-aws <item-name>' to load AWS credentials from 1Password"
                info "Use 'op-ssh <item-name>' to load SSH key from 1Password"
            fi
        else
            info "1Password CLI not detected on Windows"
            info "If you install 1Password CLI later, run this script again to set up integration"
        fi
        
        log "1Password CLI integration setup completed"
    fi
    
    # Create Windows Terminal configuration
    if is_selected "terminal_config"; then
        section "Setting up Windows Terminal configuration"
        log "Setting up Windows Terminal configuration"
        
        WT_CONFIG_DIR="$HOME/.wt-config"
        mkdir -p "$WT_CONFIG_DIR"
        
        # Generate Windows Terminal settings fragment
        info "Generating Windows Terminal settings fragment"
        cat > "$WT_CONFIG_DIR/wt-settings-fragment.json" << 'EOF'
{
    "profiles": {
        "list": [
            {
                "name": "AWS Power User",
                "source": "Windows.Terminal.Wsl",
                "colorScheme": "AWS Dark",
                "cursorShape": "filledBox",
                "font": {
                    "face": "CaskaydiaCove Nerd Font",
                    "size": 11,
                    "weight": "medium"
                },
                "useAcrylic": true,
                "acrylicOpacity": 0.8,
                "padding": "8, 8, 8, 8",
                "startingDirectory": "//wsl$/Ubuntu/home/$USER",
                "bellStyle": "none",
                "tabTitle": "AWS Power User"
            }
        ]
    },
    "schemes": [
        {
            "name": "AWS Dark",
            "background": "#0E1C36",
            "foreground": "#FFFFFF",
            "cursorColor": "#FF9900",
            "selectionBackground": "#FF9900",
            "black": "#0E1C36",
            "blue": "#3B8EEA",
            "cyan": "#00A1C0",
            "green": "#3EB489",
            "purple": "#CC70A7",
            "red": "#E53935",
            "white": "#FFFFFF",
            "yellow": "#FF9900",
            "brightBlack": "#545B6B",
            "brightBlue": "#67A2EE",
            "brightCyan": "#37C3D6",
            "brightGreen": "#5CC69B",
            "brightPurple": "#D490B5",
            "brightRed": "#EB6A67",
            "brightWhite": "#FFFFFF",
            "brightYellow": "#FFA94D"
        }
    ]
}
EOF
        
        # Create a README with instructions
        cat > "$WT_CONFIG_DIR/README.md" << 'EOF'
# Windows Terminal Configuration for AWS Power User

This directory contains configuration files for Windows Terminal to provide an optimal AWS Power User experience.

## Setup Instructions

1. Install a Nerd Font (recommended: CaskaydiaCove Nerd Font):
   - Visit https://www.nerdfonts.com/font-downloads
   - Download "CaskaydiaCove Nerd Font" (or your preferred Nerd Font)
   - Extract and install the font files in Windows

2. Add the configuration to Windows Terminal:
   - Open Windows Terminal
   - Open Settings (Ctrl+,)
   - Click "Open JSON file" in the bottom-left corner
   - Copy the contents of `wt-settings-fragment.json` from this directory
   - Paste it into the appropriate sections of your settings.json file
     - Paste the profile under "profiles.list"
     - Paste the color scheme under "schemes"

3. Save the settings file and restart Windows Terminal

Your Windows Terminal is now configured with:
- AWS-themed color scheme
- Modern Nerd Font with icons support
- Acrylic transparency effect
- Custom cursor and padding for better readability

You can further customize the settings by editing the values in your Windows Terminal settings.json directly.

## Optional Visual Enhancements

For additional visual customization, you can add a background image to your terminal profile by adding these lines to the profile configuration:

```json
"backgroundImage": "%USERPROFILE%\\Pictures\\aws-terminal-bg.jpg",
"backgroundImageOpacity": 0.15,
"backgroundImageStretchMode": "uniformToFill",
```

Then save an AWS-themed background image to that location in your Windows user profile.
EOF
        
        info "Windows Terminal configuration created in $WT_CONFIG_DIR"
        info "Follow the instructions in $WT_CONFIG_DIR/README.md to set up Windows Terminal"
        
        log "Windows Terminal configuration setup completed"
    fi
    
    # Configure zsh as default shell if selected
    if is_selected "zsh" && is_selected "p10k"; then
        section "Setting up ZSH as default shell"
        log "Setting up ZSH as default shell"
        
        if [ "$SHELL" != "$(which zsh)" ]; then
            info "Setting ZSH as default shell"
            chsh -s "$(which zsh)" >> "$INSTALL_LOG" 2>&1
            
            # Create a new .zshrc if it doesn't exist or wasn't already configured
            if [ ! -f "$HOME/.zshrc" ] || ! grep -q "# AWS Power User WSL Setup" "$HOME/.zshrc"; then
                info "Creating new .zshrc with our configuration"
                # Backup existing .zshrc if it exists
                if [ -f "$HOME/.zshrc" ]; then
                    cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%s)"
                fi
                
                # Create new .zshrc with our configuration
                cat > "$HOME/.zshrc" << 'EOF'
# AWS Power User WSL Setup - Configuration file
# This file was generated by the AWS Power User WSL Setup script

# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Set theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set plugins
plugins=(
  git
  aws
  docker
  vscode
  zsh-autosuggestions
  zsh-syntax-highlighting
)

# Source oh-my-zsh
source $ZSH/oh-my-zsh.sh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Add pipx installed binaries to path
export PATH="$HOME/.local/bin:$PATH"

# Add npm global bin to PATH
export PATH="$HOME/.npm-global/bin:$PATH"

# Source AWS functions and aliases if installed
[[ ! -f ~/.aws-tools/aws-functions.sh ]] || source ~/.aws-tools/aws-functions.sh

# Set up AWS CLI autocompletion
autoload -Uz compinit && compinit
command -v aws_completer >/dev/null 2>&1 && complete -C "$(which aws_completer)" aws
EOF
            fi
        else
            info "ZSH is already the default shell"
        fi
        
        log "ZSH setup as default shell completed"
    fi
}

# Perform the installation
install_components

section "Installation complete!"

# Print a summary of what was installed
info "Your AWS Power User WSL environment has been configured with:"

for component in "${selected_components[@]}"; do
    case "$component" in
        "base")
            info "✓ Base system with essential packages"
            ;;
        "zsh")
            info "✓ ZSH with Oh My Zsh"
            ;;
        "p10k")
            info "✓ Powerlevel10k theme optimized for AWS"
            ;;
        "aws_cli")
            info "✓ AWS CLI v2 with multi-account support"
            ;;
        "aws_tools")
            info "✓ AWS development tools (SAM, CDK, SSO utils)"
            ;;
        "aws_helpers")
            info "✓ AWS helper functions for EC2, CloudWatch, Lambda"
            ;;
        "node")
            info "✓ Node.js and npm with global package configuration"
            ;;
        "python")
            info "✓ Python development tools with virtualenv support"
            ;;
        "docker")
            info "✓ Docker with ECR integration"
            ;;
        "terraform")
            info "✓ Terraform with workspace management"
            ;;
        "kubernetes")
            info "✓ Kubernetes tools with EKS integration (kubectl, eksctl, helm, k9s)"
            ;;
        "modern_cli")
            info "✓ Modern CLI tools (bat, eza/exa, fzf, direnv)"
            ;;
        "fonts")
            info "✓ Powerline fonts for better terminal experience"
            ;;
        "session_manager")
            info "✓ AWS Session Manager Plugin for direct EC2 instance access"
            ;;
        "onepassword")
            info "✓ 1Password CLI integration (if detected on Windows)"
            ;;
        "terminal_config")
            info "✓ Windows Terminal configuration"
            ;;
    esac
done

info "\nTo complete the setup:"
if is_selected "zsh"; then
    info "1. Restart your terminal or run: exec zsh -l"
else
    info "1. Configure your shell by sourcing the appropriate files in ~/.aws-tools/"
fi

if is_selected "aws_cli"; then
    info "2. Edit your AWS config file at ~/.aws/config with your actual credentials"
    info "   (Your existing AWS configuration has been preserved and backed up)"
    info "3. To switch between AWS profiles, type 'awsp'"
    info "4. To switch AWS regions, type 'awsregion'"
fi

if is_selected "fonts" || is_selected "terminal_config"; then
    info "5. Configure your terminal font to use one of the Powerline fonts"
    if is_selected "terminal_config"; then
        info "6. Follow the instructions in ~/.wt-config/README.md to set up Windows Terminal"
    fi
fi

info "\nInstallation log is available at: $INSTALL_LOG"

# Setup success
echo -e "\n${GREEN}AWS Power User WSL Setup complete! 🚀${NC}"
echo -e "${YELLOW}Please restart your terminal to apply all changes.${NC}"