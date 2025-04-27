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

# Download p10k configuration file optimized for AWS
section "Setting up Powerlevel10k configuration"

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

  typeset -g POWERLEVEL9K_MODE=nerdfont-complete
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

# Install font if running in Windows Terminal
section "Installing Nerd Font"
info "Downloading JetBrainsMono Nerd Font"
mkdir -p "$HOME/.local/share/fonts"
wget -q --show-progress "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip" -O /tmp/JetBrainsMono.zip
unzip -q -o /tmp/JetBrainsMono.zip -d "$HOME/.local/share/fonts"
rm /tmp/JetBrainsMono.zip
fc-cache -f

info "Nerd Font installed to ~/.local/share/fonts"
info "To use this font in Windows Terminal:"
info "1. Install the font on Windows (copy from WSL to Windows or download manually)"
info "2. Open Windows Terminal settings and set the font to 'JetBrainsMono Nerd Font'"

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
section "Setup complete!"
info "Your WSL environment has been configured with:"
info "✓ ZSH with Oh My Zsh"
info "✓ Powerlevel10k theme optimized for AWS"
info "✓ AWS CLI v2 and utilities (installed with pipx)"
info "✓ GitHub CLI"
info "✓ AWS development tools (installed with pipx and npm)"
info "✓ JetBrainsMono Nerd Font"

info "\nTo complete the setup:"
info "1. Restart your terminal or run: exec zsh -l"
info "2. Edit your AWS config file at ~/.aws/config with your actual credentials"
info "3. To switch between AWS profiles, type 'awsp'"

# Setup success
echo -e "\n${GREEN}AWS Power User WSL Setup complete! 🚀${NC}"
echo -e "${YELLOW}Please restart your terminal to apply all changes.${NC}"
echo -e "${YELLOW}Note: If this is the first run, some paths might not be available until you restart your terminal.${NC}"
echo -e "${YELLOW}      The PATH environment will include ~/.local/bin for pipx-installed tools.${NC}"
