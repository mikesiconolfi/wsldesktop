#!/bin/bash
# p10k-aws-fix.sh - Add AWS profile segment to Powerlevel10k configuration

# Set color codes for output
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

section "Fixing Powerlevel10k AWS Profile"

# Check if p10k config exists
if [ ! -f "$HOME/.p10k.zsh" ]; then
    error "Powerlevel10k configuration file not found at ~/.p10k.zsh"
    error "Please run 'p10k configure' first to create the initial configuration"
    exit 1
fi

# Create a backup
info "Creating backup of your p10k configuration"
cp "$HOME/.p10k.zsh" "$HOME/.p10k.zsh.backup.$(date +%s)"
info "Backup saved to ~/.p10k.zsh.backup.$(date +%s)"

# Check if AWS profile function exists
if grep -q "prompt_aws_profile" "$HOME/.p10k.zsh"; then
    info "AWS profile function already exists in your configuration"
else
    info "Adding AWS profile function to your Powerlevel10k configuration"
    # Add the AWS profile function before the closing parenthesis
    sed -i '/^}$/ i\
  # AWS segment: Show current AWS profile\
  function prompt_aws_profile() {
  local aws_profile="$AWS_PROFILE"
  if [[ -z "$aws_profile" ]]; then
    aws_profile="$(aws configure list-profiles 2>/dev/null | head -1)"
  fi
  if [[ -n "$aws_profile" ]]; then
    p10k segment -f yellow -i '☁️' -t "${aws_profile}"
  fi
}' "$HOME/.p10k.zsh"
    
    if [ $? -ne 0 ]; then
        error "Failed to add AWS profile function. Your configuration may need manual editing."
        exit 1
    else
        info "AWS profile function added successfully"
    fi
fi

# Check if aws_profile is in the left prompt elements
if grep -q "aws_profile" "$HOME/.p10k.zsh" && grep -q "POWERLEVEL9K_LEFT_PROMPT_ELEMENTS" "$HOME/.p10k.zsh"; then
    info "AWS profile is already in your prompt elements"
else
    info "Adding aws_profile to your left prompt elements"
    
    # First try to add it to existing LEFT_PROMPT_ELEMENTS
    if grep -q "POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=" "$HOME/.p10k.zsh"; then
        # Find the closing parenthesis of LEFT_PROMPT_ELEMENTS and add aws_profile before it
        sed -i '/POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=/ s/)/ aws_profile)/' "$HOME/.p10k.zsh"
        
        if [ $? -ne 0 ]; then
            error "Failed to add aws_profile to left prompt elements. Your configuration may need manual editing."
            exit 1
        else
            info "Added aws_profile to left prompt elements successfully"
        fi
    else
        error "Could not find POWERLEVEL9K_LEFT_PROMPT_ELEMENTS in your configuration"
        info "You may need to manually add aws_profile to your prompt elements"
        echo "Add the following line to your POWERLEVEL9K_LEFT_PROMPT_ELEMENTS array in ~/.p10k.zsh:"
        echo "    aws_profile"
    fi
fi

section "AWS Profile Fix Complete"
info "Your Powerlevel10k configuration should now show the AWS profile in your prompt"
info "You may need to restart your shell or run 'source ~/.p10k.zsh' to apply changes"
echo -e "\n${GREEN}Done! Enjoy your AWS-enabled Powerlevel10k theme!${NC}"