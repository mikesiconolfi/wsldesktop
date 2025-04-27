#!/bin/bash

# AWS Power User WSL Setup Script
# This script sets up a complete development environment for AWS on WSL
# It installs ZSH, Oh My Zsh, Powerlevel10k, AWS CLI, and other essential tools

set -e  # Exit on error

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

section "Updating package lists"
sudo apt update

section "Installing prerequisites"
info "Installing basic development tools and dependencies"
sudo apt install -y git curl wget zip unzip build-essential python3 python3-pip python3-venv

# Install Node.js and npm from NodeSource repository
section "Installing Node.js and npm"
if ! command_exists node; then
    info "Adding NodeSource repository"
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    info "Installing Node.js and npm"
    sudo apt install -y nodejs
    info "Node.js $(node -v) and npm $(npm -v) installed"
else
    info "Node.js $(node -v) and npm $(npm -v) already installed"
fi

# Install ZSH if not already installed
if ! command_exists zsh; then
    section "Installing ZSH"
    sudo apt install -y zsh
else
    info "ZSH is already installed"
fi

# Install Oh My Zsh if not already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    section "Installing Oh My Zsh"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    info "Oh My Zsh is already installed"
fi

# Install Powerlevel10k theme
section "Installing Powerlevel10k theme"
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
else
    info "Powerlevel10k theme is already installed"
fi

# Install ZSH plugins
section "Installing ZSH plugins"
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
else
    info "zsh-autosuggestions plugin is already installed"
fi

if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
else
    info "zsh-syntax-highlighting plugin is already installed"
fi

# Install AWS CLI v2
section "Installing AWS CLI v2"
if ! command_exists aws || ! aws --version | grep -q "aws-cli/2"; then
    info "Downloading AWS CLI v2"
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
    info "Extracting AWS CLI v2"
    unzip -q -o /tmp/awscliv2.zip -d /tmp
    info "Installing AWS CLI v2"
    sudo /tmp/aws/install --update
    rm -rf /tmp/aws /tmp/awscliv2.zip
else
    info "AWS CLI v2 is already installed"
fi

# Install additional productivity tools
section "Installing productivity enhancements"

# Install and configure fzf for better command history search
info "Setting up enhanced command history search with fzf"
cat >> "$HOME/.zshrc" << 'EOL'

# fzf integration for command history search
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# CTRL-R - Search command history with fzf
bindkey '^R' fzf-history-widget
EOL

# Install and configure tldr for simplified man pages
info "Installing tldr for simplified command examples"
sudo apt install -y tldr
tldr --update

# Install and configure direnv for environment switching
info "Installing direnv for automatic environment switching"
sudo apt install -y direnv
cat >> "$HOME/.zshrc" << 'EOL'

# direnv integration for automatic env switching
eval "$(direnv hook zsh)"
EOL

# Install and configure bat for better file viewing
info "Installing bat for syntax highlighted file viewing"
sudo apt install -y bat
if ! command -v bat &> /dev/null; then
  # On some systems, bat is installed as batcat
  echo 'alias bat="batcat"' >> "$HOME/.zshrc"
fi

# Install and configure exa/eza for better directory listings
if apt-cache show eza &> /dev/null; then
  info "Installing eza for enhanced directory listings"
  sudo apt install -y eza
  cat >> "$HOME/.zshrc" << 'EOL'

# Use eza instead of ls
alias ls="eza --icons"
alias ll="eza --icons -la"
alias lt="eza --icons -T --level=2"
alias ltl="eza --icons -T --level=2 -l"
EOL
elif apt-cache show exa &> /dev/null; then
  info "Installing exa for enhanced directory listings"
  sudo apt install -y exa
  cat >> "$HOME/.zshrc" << 'EOL'

# Use exa instead of ls
alias ls="exa --icons"
alias ll="exa --icons -la"
alias lt="exa --icons -T --level=2"
alias ltl="exa --icons -T --level=2 -l"
EOL
fi

# Install AWS auto-completion
info "Setting up AWS CLI autocompletion"
echo 'autoload -Uz compinit && compinit' >> "$HOME/.zshrc"
echo 'complete -C "$(which aws_completer)" aws' >> "$HOME/.zshrc"

# Create AWS specific aliases and functions
info "Creating AWS specific aliases and functions"
cat >> "$HOME/.zshrc" << 'EOL'

# AWS specific aliases and functions
alias awsid="aws sts get-caller-identity"
alias awsr="aws --region"
alias awss3="aws s3 ls"
alias awsec2="aws ec2 describe-instances --query 'Reservations[].Instances[].[InstanceId,State.Name,Tags[?Key==`Name`].Value|[0],InstanceType,PublicIpAddress,PrivateIpAddress]' --output table"
alias awslambda="aws lambda list-functions --query 'Functions[*].[FunctionName,Runtime,MemorySize]' --output table"

# Function to quickly find and tail CloudWatch logs
function awslogs() {
  log_groups=$(aws logs describe-log-groups --query 'logGroups[*].logGroupName' --output text)
  if [[ -z "$log_groups" ]]; then
    echo "No log groups found"
    return 1
  fi
  
  selected=$(echo "$log_groups" | fzf)
  if [[ -n "$selected" ]]; then
    aws logs tail "$selected" --follow
  fi
}

# Function to show all running EC2 instances with important details
function awsec2list() {
  aws ec2 describe-instances \
    --filters "Name=instance-state-name,Values=running" \
    --query 'Reservations[*].Instances[*].{ID:InstanceId,Name:Tags[?Key==`Name`]|[0].Value,Type:InstanceType,State:State.Name,IP:PublicIpAddress,PrivateIP:PrivateIpAddress,AZ:Placement.AvailabilityZone}' \
    --output table
}

# Function to quickly switch between AWS regions
function awsregion() {
  regions=$(aws ec2 describe-regions --query 'Regions[*].RegionName' --output text)
  if [[ -z "$regions" ]]; then
    echo "Could not retrieve AWS regions"
    return 1
  fi
  
  selected=$(echo "$regions" | fzf)
  if [[ -n "$selected" ]]; then
    export AWS_REGION="$selected"
    export AWS_DEFAULT_REGION="$selected"
    echo "Switched to region: $selected"
  fi
}

# Show CloudFormation stack status
function awscf() {
  aws cloudformation list-stacks \
    --query 'StackSummaries[*].{Name:StackName,Status:StackStatus,CreationTime:CreationTime}' \
    --output table
}
EOL

# Install AWS utilities
section "Installing AWS utilities"
info "Installing pipx for isolated Python application installation"
sudo apt install -y pipx python3-full
pipx ensurepath

info "Installing AWS utilities using pipx"
pipx install aws-sso-util
pipx install aws-profile-switcher

# Make pipx installed tools available in current shell
export PATH="$HOME/.local/bin:$PATH"

# Create AWS config directory if it doesn't exist
mkdir -p ~/.aws

# Install GitHub CLI
section "Installing GitHub CLI"
if ! command_exists gh; then
    type -p curl >/dev/null || sudo apt install -y curl
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt update
    sudo apt install -y gh
else
    info "GitHub CLI is already installed"
fi

# Install AWS development tools
section "Installing AWS development tools"
info "Installing AWS SAM CLI and CDK CLI using pipx"
pipx install aws-sam-cli
pipx install aws-cdk-cli

# Configure npm to install global packages in user directory
info "Configuring npm to use a user directory for global packages"
mkdir -p "$HOME/.npm-global"
npm config set prefix "$HOME/.npm-global"

# Add npm global bin to PATH for current session
export PATH="$HOME/.npm-global/bin:$PATH"

# Add npm global bin to PATH in .zshrc
cat >> "$HOME/.zshrc" << 'EOL'

# Add npm global bin to PATH
export PATH="$HOME/.npm-global/bin:$PATH"
EOL

if ! command_exists serverless; then
    info "Installing Serverless Framework"
    npm install -g serverless
else
    info "Serverless Framework is already installed"
fi

# Configure ZSH
section "Configuring ZSH"

# Backup existing .zshrc if it exists
if [ -f "$HOME/.zshrc" ]; then
    info "Backing up existing .zshrc to .zshrc.backup"
    cp "$HOME/.zshrc" "$HOME/.zshrc.backup"
fi

# Create new .zshrc with our configuration
cat > "$HOME/.zshrc" << 'EOL'
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

# AWS profile switcher function
function awsp() {
  eval "$(~/.local/bin/aws-profile-switcher)"
}

# Custom AWS helper aliases
alias awsw="aws --profile work"
alias awsd="aws --profile dev"
alias awsl="aws configure list-profiles"

# Git aliases
alias gs="git status"
alias gc="git commit"
alias gp="git push"
alias gl="git pull"

# Improved ls commands
alias ll="ls -alh"
alias la="ls -A"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOL

# Download p10k configuration file optimized for AWS (only if it doesn't exist)
section "Setting up Powerlevel10k configuration"

if [ ! -f "$HOME/.p10k.zsh" ]; then
  info "Creating new Powerlevel10k configuration file"
  cat > "$HOME/.p10k.zsh" << 'EOL'
# Generated by Powerlevel10k configuration wizard
# Optimized for AWS development
# Configuration adapted for AWS developers

'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob

  # AWS segment: Show current AWS profile
  function prompt_aws_profile() {
    local aws_profile="$AWS_PROFILE"
    if [[ -z "$aws_profile" ]]; then
      aws_profile="$(aws configure list-profiles 2>/dev/null | head -1)"
    fi
    if [[ -n "$aws_profile" ]]; then
      p10k segment -f yellow -i '☁️' -t "${aws_profile}"
    fi
  }

  typeset -g POWERLEVEL9K_MODE=powerline
  typeset -g POWERLEVEL9K_ICON_PADDING=moderate
  typeset -g POWERLEVEL9K_ICON_BEFORE_CONTENT=
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    os_icon                 # os identifier
    dir                     # current directory
    vcs                     # git status
    aws_profile             # aws profile
  )
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    status                  # exit code of the last command
    command_execution_time  # duration of the last command
    background_jobs         # presence of background jobs
    direnv                  # direnv status
    virtualenv              # python virtual environment
    nodeenv                 # node.js environment
    kubecontext             # current kubernetes context
    time                    # current time
  )
  typeset -g POWERLEVEL9K_BACKGROUND=
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_{LEFT,RIGHT}_WHITESPACE=
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SUBSEGMENT_SEPARATOR=' '
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SEGMENT_SEPARATOR=
  typeset -g POWERLEVEL9K_VISUAL_IDENTIFIER_EXPANSION='${P9K_VISUAL_IDENTIFIER}'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=76
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=196
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='❯'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION='❮'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIVIS_CONTENT_EXPANSION='V'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIOWR_CONTENT_EXPANSION='▶'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OVERWRITE_STATE=true
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=31
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
  typeset -g POWERLEVEL9K_SHORTEN_DELIMITER=
  typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=103
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=39
  typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true
  local anchor_files=(
    .git
    .terraform
    buildspec.yml
    serverless.yml
    template.yaml
    samconfig.toml
    cdk.json
  )
  typeset -g POWERLEVEL9K_SHORTEN_FOLDER_MARKER="(${(j:|:)anchor_files})"
  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=76
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=178
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=39
  typeset -g POWERLEVEL9K_VCS_CONFLICTED_FOREGROUND=226
  typeset -g POWERLEVEL9K_VCS_LOADING_FOREGROUND=244
  typeset -g POWERLEVEL9K_VCS_BRANCH_ICON='\uF126 '
  typeset -g POWERLEVEL9K_VCS_COMMIT_ICON='\uF417'
  typeset -g POWERLEVEL9K_VCS_GIT_HOOKS=(vcs-detect-changes git-untracked git-aheadbehind git-stash git-tagname)
  typeset -g POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_COLOR=76
  typeset -g POWERLEVEL9K_KUBECONTEXT_SHOW_ON_COMMAND='kubectl|helm|kubens|kubectx|oc|istioctl|kogito|k9s|helmfile|flux|fluxctl|stern'
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=0
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=101
  typeset -g POWERLEVEL9K_TIME_FOREGROUND=66
  typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M:%S}'
  typeset -g POWERLEVEL9K_TIME_UPDATE_ON_COMMAND=false
  typeset -g POWERLEVEL9K_STATUS_EXTENDED_STATES=true
  typeset -g POWERLEVEL9K_STATUS_OK=false
  typeset -g POWERLEVEL9K_STATUS_ERROR=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=196
  typeset -g POWERLEVEL9K_STATUS_ERROR_VISUAL_IDENTIFIER_EXPANSION='✘'
}

(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'
EOL
  info "Powerlevel10k configuration created at ~/.p10k.zsh"
else
  info "Existing Powerlevel10k configuration detected at ~/.p10k.zsh"
  info "Your existing configuration will be preserved"
  
  # Check if aws_profile function exists in the current p10k config
  if ! grep -q "prompt_aws_profile" "$HOME/.p10k.zsh"; then
    info "Adding AWS profile function to your Powerlevel10k configuration"
    # Add the AWS profile function before the closing parenthesis
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
    
    # Check if aws_profile is in the left prompt elements
    if ! grep -q "aws_profile" "$HOME/.p10k.zsh" | grep "LEFT_PROMPT_ELEMENTS"; then
      info "Adding aws_profile segment to left prompt elements"
      # This is more complex and might need manual adjustment
      info "Please consider adding 'aws_profile' to your POWERLEVEL9K_LEFT_PROMPT_ELEMENTS manually"
      info "Example line to add: typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS+=(aws_profile)"
    fi
  else
    info "AWS profile function already exists in your Powerlevel10k configuration"
  fi
fi

# Create a sample AWS config file if it doesn't exist
if [ ! -f "$HOME/.aws/config" ]; then
    section "Creating sample AWS config file"
    mkdir -p "$HOME/.aws"
    cat > "$HOME/.aws/config" << 'EOL'
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
EOL
    info "Created sample AWS config at ~/.aws/config"
    info "Please edit this file with your actual AWS account details"
fi

# Create AWS profile switcher script
section "Creating AWS profile switcher script"
mkdir -p "$HOME/.local/bin"
cat > "$HOME/.local/bin/aws-profile-switcher" << 'EOL'
#!/bin/bash
# AWS Profile Switcher

# List profiles and select with fzf
profiles=$(aws configure list-profiles 2>/dev/null)
if [ -z "$profiles" ]; then
  echo "No AWS profiles found. Check your AWS configuration."
  exit 1
fi

selected=$(echo "$profiles" | fzf --height 15 --reverse)
if [ -n "$selected" ]; then
  # Export the variable to parent shell
  echo "export AWS_PROFILE=\"$selected\""
else
  echo "echo \"No profile selected\""
fi
EOL
chmod +x "$HOME/.local/bin/aws-profile-switcher"

# Remove old _awsp script if it exists
if [ -f "$HOME/_awsp" ]; then
    rm "$HOME/_awsp"
fi

# Install Powerline fonts
section "Installing Powerline fonts"
info "Downloading and installing Powerline fonts"
git clone https://github.com/powerline/fonts.git --depth=1 "/tmp/powerline-fonts"
cd "/tmp/powerline-fonts"
./install.sh
cd "$HOME"
rm -rf "/tmp/powerline-fonts"

info "Powerline fonts installed"
info "Recommended fonts for your terminal:"
info "- DejaVu Sans Mono for Powerline"
info "- Ubuntu Mono derivative Powerline"
info "- Source Code Pro for Powerline"

# Git configuration helper
section "Setting up Git configuration"
if [ -z "$(git config --global user.email)" ]; then
    read -p "Enter your Git email address: " git_email
    git config --global user.email "$git_email"
else
    info "Git email is already configured as: $(git config --global user.email)"
fi

if [ -z "$(git config --global user.name)" ]; then
    read -p "Enter your Git name: " git_name
    git config --global user.name "$git_name"
else
    info "Git name is already configured as: $(git config --global user.name)"
fi

# Tell the user what to do next
section "Setting up AWS Session Manager Plugin"
if ! command_exists session-manager-plugin; then
  info "Installing AWS Session Manager Plugin"
  curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "/tmp/session-manager-plugin.deb"
  sudo dpkg -i "/tmp/session-manager-plugin.deb"
  rm "/tmp/session-manager-plugin.deb"
  
  # Add Session Manager helper function to .zshrc
  cat >> "$HOME/.zshrc" << 'EOL'

# AWS Session Manager helper for connecting to EC2 instances
function ssm-connect() {
  if [ -z "$1" ]; then
    echo "Usage: ssm-connect <instance-id>"
    return 1
  fi
  
  aws ssm start-session --target "$1"
}

# Function to list EC2 instances and connect via SSM
function ssm-list-connect() {
  instances=$(aws ec2 describe-instances \
    --filters "Name=instance-state-name,Values=running" \
    --query 'Reservations[*].Instances[*].{ID:InstanceId,Name:Tags[?Key==`Name`]|[0].Value}' \
    --output json)
  
  if [ -z "$instances" ] || [ "$instances" = "[]" ]; then
    echo "No running instances found"
    return 1
  fi
  
  # Format instances for display
  echo "$instances" | jq -r '.[][] | "\(.ID) - \(.Name // "unnamed")"' > /tmp/instances.txt
  
  # Select instance with fzf
  selected=$(cat /tmp/instances.txt | fzf --height 15 --reverse)
  rm /tmp/instances.txt
  
  if [ -n "$selected" ]; then
    instance_id=$(echo "$selected" | awk '{print $1}')
    echo "Connecting to instance $instance_id..."
    aws ssm start-session --target "$instance_id"
  else
    echo "No instance selected"
  fi
}
EOL
else
  info "AWS Session Manager Plugin already installed"
fi

section "Setting up 1Password CLI integration"
info "Checking for 1Password CLI on Windows side"

# Check if 1Password CLI is installed on Windows
if command -v /mnt/c/Program\ Files/1Password/app/8/op.exe &> /dev/null || command -v /mnt/c/Program\ Files/1Password\ CLI/op.exe &> /dev/null; then
  info "1Password CLI detected on Windows"
  
  # Create directory for 1Password CLI
  mkdir -p "$HOME/.1password"
  
  # Create wrapper script for 1Password CLI
  cat > "$HOME/.1password/op" << 'EOL'
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
EOL

  # Make the wrapper script executable
  chmod +x "$HOME/.1password/op"
  
  # Add 1Password CLI to PATH
  cat >> "$HOME/.zshrc" << 'EOL'

# 1Password CLI integration
export PATH="$HOME/.1password:$PATH"

# 1Password helper functions
function op-signin() {
  eval $(op signin)
  echo "1Password signin successful. Session token has been set."
}

# Function to get AWS credentials from 1Password
function op-aws() {
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
function op-ssh() {
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
EOL

  # Install jq for JSON parsing (needed for op-aws function)
  sudo apt install -y jq
  
  info "1Password CLI integration setup complete"
  info "You can use 'op' command to access 1Password CLI"
  info "Use 'op-signin' to sign in to 1Password"
  info "Use 'op-aws <item-name>' to load AWS credentials from 1Password"
  info "Use 'op-ssh <item-name>' to load SSH key from 1Password"
else
  info "1Password CLI not detected on Windows"
  info "If you install 1Password CLI later, run this script again to set up integration"
fi

section "Setting up Terraform"
if ! command_exists terraform; then
  info "Installing Terraform"
  # Add HashiCorp GPG key
  wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  
  # Add HashiCorp repository
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
  
  # Install Terraform
  sudo apt update
  sudo apt install -y terraform
  
  # Enable Terraform autocompletion
  terraform -install-autocomplete
  
  # Add Terraform aliases to .zshrc
  cat >> "$HOME/.zshrc" << 'EOL'

# Terraform shortcuts
alias tf="terraform"
alias tfi="terraform init"
alias tfp="terraform plan"
alias tfa="terraform apply"
alias tfd="terraform destroy"
alias tfo="terraform output"
alias tfs="terraform state"
alias tfv="terraform validate"
alias tfw="terraform workspace"

# Function to select Terraform workspace
function tfws() {
  if [ ! -d ".terraform" ]; then
    echo "Not a Terraform directory or Terraform not initialized"
    return 1
  fi
  
  workspaces=$(terraform workspace list | sed 's/^[ *]*//')
  if [ -z "$workspaces" ]; then
    echo "No workspaces found"
    return 1
  fi
  
  selected=$(echo "$workspaces" | fzf --height 15 --reverse)
  if [ -n "$selected" ]; then
    terraform workspace select "$selected"
  else
    echo "No workspace selected"
  fi
}
EOL
else
  info "Terraform already installed"
fi

info "\nTo complete the setup:"
info "1. Restart your terminal or run: exec zsh -l"
info "2. Edit your AWS config file at ~/.aws/config with your actual credentials"
info "3. To switch between AWS profiles, type 'awsp'"

# Setup success
echo -e "\n${GREEN}AWS Power User WSL Setup complete! 🚀${NC}"
echo -e "${YELLOW}Please restart your terminal to apply all changes.${NC}"
echo -e "${YELLOW}Note: If this is the first run, some paths might not be available until you restart your terminal.${NC}"
echo -e "${YELLOW}      The PATH environment will include ~/.local/bin for pipx-installed tools.${NC}"