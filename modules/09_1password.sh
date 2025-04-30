#!/bin/bash

# 1Password integration setup

install_1password() {
    section "Setting up 1Password integration"
    
    # Check if 1Password CLI is available in Windows
    if [[ -f "/mnt/c/Program Files/1Password CLI/op.exe" ]]; then
        info "1Password CLI detected in Windows, setting up integration..."
        
        # Create wrapper script for 1Password CLI
        mkdir -p "$HOME/.local/bin"
        cat > "$HOME/.local/bin/op" << 'EOF'
#!/bin/bash
# Wrapper for Windows 1Password CLI
/mnt/c/Program\ Files/1Password\ CLI/op.exe "$@"
EOF
        chmod +x "$HOME/.local/bin/op"
        
        # Create 1Password helper functions
        info "Setting up 1Password helper functions..."
        cat > "$HOME/.1password_functions" << 'EOF'
# 1Password Helper Functions

# Sign in to 1Password
op-signin() {
    eval $(op signin)
}

# Get AWS credentials from 1Password
op-aws() {
    local item="$1"
    if [[ -z "$item" ]]; then
        echo "Usage: op-aws <item-name>"
        return 1
    fi
    
    # Get AWS credentials from 1Password
    local access_key=$(op item get "$item" --fields "AWS_ACCESS_KEY_ID")
    local secret_key=$(op item get "$item" --fields "AWS_SECRET_ACCESS_KEY")
    
    if [[ -n "$access_key" && -n "$secret_key" ]]; then
        export AWS_ACCESS_KEY_ID="$access_key"
        export AWS_SECRET_ACCESS_KEY="$secret_key"
        echo "AWS credentials loaded from 1Password item: $item"
    else
        echo "Failed to load AWS credentials from 1Password item: $item"
        return 1
    fi
}

# Get SSH key from 1Password
op-ssh() {
    local item="$1"
    if [[ -z "$item" ]]; then
        echo "Usage: op-ssh <item-name>"
        return 1
    fi
    
    # Create SSH directory if it doesn't exist
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    
    # Get SSH key from 1Password
    op item get "$item" --fields "private key" > "$HOME/.ssh/id_rsa"
    chmod 600 "$HOME/.ssh/id_rsa"
    
    # Get public key if available
    op item get "$item" --fields "public key" > "$HOME/.ssh/id_rsa.pub" 2>/dev/null
    if [[ -f "$HOME/.ssh/id_rsa.pub" ]]; then
        chmod 644 "$HOME/.ssh/id_rsa.pub"
    fi
    
    echo "SSH key loaded from 1Password item: $item"
}

# Get environment variables from 1Password
op-env() {
    local item="$1"
    if [[ -z "$item" ]]; then
        echo "Usage: op-env <item-name>"
        return 1
    fi
    
    # Get all fields from the item
    local fields=$(op item get "$item" --format json | jq -r '.fields[] | select(.type == "CONCEALED") | "\(.label)=\(.value)"')
    
    # Export each field as an environment variable
    while IFS= read -r line; do
        if [[ -n "$line" ]]; then
            export "$line"
            echo "Exported: ${line%%=*}"
        fi
    done <<< "$fields"
    
    echo "Environment variables loaded from 1Password item: $item"
}
EOF
        
        # Add 1Password CLI to PATH
        echo 'export PATH="$HOME/.local/bin:$PATH"' > "$HOME/.1password_path"
        
        info "1Password integration setup complete"
    else
        info "1Password CLI not detected in Windows, skipping integration"
    fi
}
