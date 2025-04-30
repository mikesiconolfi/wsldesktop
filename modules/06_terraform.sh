#!/bin/bash

# Terraform installation and configuration

install_terraform() {
    section "Setting up Terraform"
    
    # Check for package manager lock
    if [[ "$IGNORE_LOCKS" != "1" ]] && pgrep -f "apt-get|dpkg" > /dev/null; then
        error "Another package manager process is running. Terraform installation will be skipped."
        info "You can install Terraform manually later or re-run this module."
        info "To bypass this check, use: IGNORE_LOCKS=1 ./setup-aws-wsl.sh"
        return 1
    fi
    
    # Install Terraform if not already installed
    if ! command_exists terraform; then
        info "Installing Terraform..."
        
        # Add HashiCorp GPG key
        wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
        
        # Add HashiCorp repository
        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
        
        # Install Terraform
        sudo apt-get update
        sudo apt-get install -y terraform
    else
        info "Terraform already installed"
    fi
    
    # Install Terraform-docs if not already installed
    if ! command_exists terraform-docs; then
        info "Installing terraform-docs..."
        TERRAFORM_DOCS_VERSION="v0.16.0"
        TERRAFORM_DOCS_URL="https://github.com/terraform-docs/terraform-docs/releases/download/${TERRAFORM_DOCS_VERSION}/terraform-docs-${TERRAFORM_DOCS_VERSION}-$(uname | tr '[:upper:]' '[:lower:]')-amd64.tar.gz"
        
        # Download terraform-docs
        curl -sSLo /tmp/terraform-docs.tar.gz "$TERRAFORM_DOCS_URL"
        if [ $? -ne 0 ]; then
            error "Failed to download terraform-docs. Please install it manually."
            return 1
        fi
        
        # Check if the download was successful
        if [ ! -s /tmp/terraform-docs.tar.gz ]; then
            error "Downloaded terraform-docs file is empty. Please install it manually."
            return 1
        fi
        
        # Extract the file
        tar -xzf /tmp/terraform-docs.tar.gz -C /tmp
        if [ $? -ne 0 ]; then
            error "Failed to extract terraform-docs. Please install it manually."
            return 1
        fi
        
        # Check if the binary was extracted
        if [ ! -f /tmp/terraform-docs ]; then
            error "terraform-docs binary not found after extraction. Please install it manually."
            return 1
        fi
        
        chmod +x /tmp/terraform-docs
        sudo mv /tmp/terraform-docs /usr/local/bin/
        rm -f /tmp/terraform-docs.tar.gz
    else
        info "terraform-docs already installed"
    fi
    
    # Install tflint if not already installed
    if ! command_exists tflint; then
        info "Installing tflint..."
        curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
    else
        info "tflint already installed"
    fi
    
    # Create Terraform aliases and functions
    info "Setting up Terraform aliases and functions..."
    cat > "$HOME/.terraform_functions" << 'EOF'
# Terraform aliases
alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfd='terraform destroy'
alias tfo='terraform output'
alias tfs='terraform state'
alias tfv='terraform validate'
alias tff='terraform fmt'

# Terraform workspace selector
tfws() {
    if [[ ! -d .terraform ]]; then
        echo "Not in a Terraform directory. Run 'terraform init' first."
        return 1
    fi
    
    local workspaces=$(terraform workspace list | sed 's/^[ *]*//')
    local selected=$(echo "$workspaces" | fzf)
    
    if [[ -n "$selected" ]]; then
        terraform workspace select "$selected"
    fi
}

# Terraform plan with output to file
tfpo() {
    terraform plan -out=tfplan
}

# Terraform apply with plan file
tfao() {
    terraform apply tfplan
}

# Terraform documentation generator
tfdoc() {
    terraform-docs markdown table . > README.md
}
EOF
    
    info "Terraform setup complete"
}
