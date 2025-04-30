#!/bin/bash

# Terraform installation and configuration

install_terraform() {
    section "Setting up Terraform"
    
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
        curl -Lo ./terraform-docs.tar.gz https://github.com/terraform-docs/terraform-docs/releases/latest/download/terraform-docs-v0.16.0-$(uname)-amd64.tar.gz
        tar -xzf terraform-docs.tar.gz
        chmod +x terraform-docs
        sudo mv terraform-docs /usr/local/bin/
        rm terraform-docs.tar.gz
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
