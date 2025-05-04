#!/bin/bash

# This script fixes the AWS segment in Powerlevel10k to always show the AWS profile
# by removing the command restriction entirely

echo "Applying AWS fix for Powerlevel10k..."

# Path to p10k.zsh configuration file
P10K_CONFIG="$HOME/.p10k.zsh"

if [[ ! -f "$P10K_CONFIG" ]]; then
    echo "Error: $P10K_CONFIG not found"
    exit 1
fi

# Create a backup
cp "$P10K_CONFIG" "$P10K_CONFIG.bak.$(date +%Y%m%d%H%M%S)"

# Remove the line that restricts AWS segment to specific commands
if grep -q "POWERLEVEL9K_AWS_SHOW_ON_COMMAND=" "$P10K_CONFIG"; then
    # Remove the line completely instead of setting it to empty string
    sed -i '/typeset -g POWERLEVEL9K_AWS_SHOW_ON_COMMAND=/d' "$P10K_CONFIG"
    echo "AWS command restriction removed - using default behavior"
else
    echo "AWS command restriction not found in $P10K_CONFIG"
fi

# Make sure AWS is in the right prompt elements
if grep -q "POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=" "$P10K_CONFIG"; then
    # Check if aws is already in the right prompt elements
    if ! grep -q "aws" <<< "$(grep "POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=" "$P10K_CONFIG")"; then
        # Add aws to the right prompt elements
        sed -i '/POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(/a \    aws' "$P10K_CONFIG"
        echo "Added AWS to right prompt elements"
    else
        echo "AWS already in right prompt elements"
    fi
else
    echo "Right prompt elements configuration not found in $P10K_CONFIG"
fi

echo "AWS fix applied. Please restart your shell or run 'source ~/.p10k.zsh' to apply changes."
