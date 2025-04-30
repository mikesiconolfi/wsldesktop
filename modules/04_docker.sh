#!/bin/bash

# Docker and container tools installation

install_docker() {
    section "Setting up Docker and container tools"
    
    # Check for package manager lock
    if [[ "$IGNORE_LOCKS" != "1" ]] && pgrep -f "apt-get|dpkg" > /dev/null; then
        error "Another package manager process is running. Docker installation will be skipped."
        info "You can install Docker manually later or re-run this module."
        info "To bypass this check, use: IGNORE_LOCKS=1 ./setup-aws-wsl.sh"
        return 1
    fi
    
    # Install Docker if not already installed
    if ! command_exists docker; then
        info "Installing Docker..."
        # Add Docker's official GPG key
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        
        # Add Docker repository
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        
        # Install Docker
        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io
        
        # Add user to docker group
        sudo usermod -aG docker $USER
        
        info "Docker installed. You may need to log out and back in for group changes to take effect."
    else
        info "Docker already installed"
    fi
    
    # Install Docker Compose if not already installed
    if ! command_exists docker-compose; then
        info "Installing Docker Compose..."
        sudo curl -L "https://github.com/docker/compose/releases/download/v2.18.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    else
        info "Docker Compose already installed"
    fi
    
    # Install Amazon ECR Credential Helper
    if ! command_exists docker-credential-ecr-login; then
        info "Installing Amazon ECR Credential Helper..."
        sudo apt-get install -y amazon-ecr-credential-helper
        
        # Configure Docker to use ECR helper
        mkdir -p "$HOME/.docker"
        if [[ ! -f "$HOME/.docker/config.json" ]]; then
            cat > "$HOME/.docker/config.json" << 'EOF'
{
  "credHelpers": {
    "public.ecr.aws": "ecr-login",
    "*.dkr.ecr.*.amazonaws.com": "ecr-login"
  }
}
EOF
        else
            info "Docker config already exists, you may need to manually configure ECR credential helper"
        fi
    else
        info "Amazon ECR Credential Helper already installed"
    fi
    
    # Create ECR login function
    info "Setting up ECR login function..."
    cat > "$HOME/.ecr_functions" << 'EOF'
# ECR Login Function
ecr-login() {
    local region=${1:-$AWS_REGION}
    if [[ -z "$region" ]]; then
        region=${AWS_DEFAULT_REGION:-us-east-1}
    fi
    
    echo "Logging in to ECR in region $region..."
    aws ecr get-login-password --region "$region" | docker login --username AWS --password-stdin "$(aws sts get-caller-identity --query Account --output text).dkr.ecr.$region.amazonaws.com"
}
EOF
    
    # Docker aliases
    info "Setting up Docker aliases..."
    cat > "$HOME/.docker_aliases" << 'EOF'
# Docker aliases
alias dps='docker ps'
alias dpsa='docker ps -a'
alias dimg='docker images'
alias dcup='docker-compose up -d'
alias dcdown='docker-compose down'
alias dclogs='docker-compose logs -f'
alias dexec='docker exec -it'
alias dprune='docker system prune -a'
EOF
    
    info "Docker and container tools setup complete"
}
