#!/bin/bash

# AWS development tools installation

install_aws_dev_tools() {
    section "Setting up AWS development tools"
    
    # Install AWS SAM CLI if not already installed
    if ! command_exists sam; then
        info "Installing AWS SAM CLI..."
        if command_exists pip3; then
            # Create a virtual environment for Python packages if it doesn't exist
            if [[ ! -d "$HOME/.venvs/aws-tools" ]]; then
                info "Creating Python virtual environment for AWS tools..."
                mkdir -p "$HOME/.venvs"
                python3 -m venv "$HOME/.venvs/aws-tools"
            fi
            
            # Install AWS SAM CLI in the virtual environment
            "$HOME/.venvs/aws-tools/bin/pip" install aws-sam-cli >> "$LOG_FILE" 2>&1 || {
                error "Failed to install AWS SAM CLI. Please install it manually."
            }
            
            # Create wrapper script
            mkdir -p "$HOME/.local/bin"
            cat > "$HOME/.local/bin/sam" << 'EOF'
#!/bin/bash
$HOME/.venvs/aws-tools/bin/sam "$@"
EOF
            chmod +x "$HOME/.local/bin/sam"
            
            info "AWS SAM CLI installed in virtual environment. Wrapper created at ~/.local/bin/sam"
        else
            error "pip3 not found. Cannot install AWS SAM CLI."
            info "Please install python3-pip and try again."
        fi
    else
        info "AWS SAM CLI already installed"
    fi
    
    # Install AWS CDK if not already installed
    if ! command_exists cdk; then
        info "Installing AWS CDK..."
        sudo npm install -g aws-cdk
    else
        info "AWS CDK already installed"
    fi
    
    # Install Serverless Framework if not already installed
    if ! command_exists serverless; then
        info "Installing Serverless Framework..."
        sudo npm install -g serverless
    else
        info "Serverless Framework already installed"
    fi
    
    # Install AWS Amplify CLI if not already installed
    if ! command_exists amplify; then
        info "Installing AWS Amplify CLI..."
        sudo npm install -g @aws-amplify/cli
    else
        info "AWS Amplify CLI already installed"
    fi
    
    # Install AWS Copilot CLI if not already installed
    if ! command_exists copilot; then
        info "Installing AWS Copilot CLI..."
        curl -Lo copilot https://github.com/aws/copilot-cli/releases/latest/download/copilot-linux
        chmod +x copilot
        sudo mv copilot /usr/local/bin/copilot
    else
        info "AWS Copilot CLI already installed"
    fi
    
    # Install AWS CloudFormation Linter if not already installed
    if ! command_exists cfn-lint; then
        info "Installing AWS CloudFormation Linter..."
        if command_exists pip3; then
            # Create a virtual environment for Python packages if it doesn't exist
            if [[ ! -d "$HOME/.venvs/aws-tools" ]]; then
                info "Creating Python virtual environment for AWS tools..."
                mkdir -p "$HOME/.venvs"
                python3 -m venv "$HOME/.venvs/aws-tools"
            fi
            
            # Install AWS CloudFormation Linter in the virtual environment
            "$HOME/.venvs/aws-tools/bin/pip" install cfn-lint >> "$LOG_FILE" 2>&1 || {
                error "Failed to install AWS CloudFormation Linter. Please install it manually."
            }
            
            # Create wrapper script
            mkdir -p "$HOME/.local/bin"
            cat > "$HOME/.local/bin/cfn-lint" << 'EOF'
#!/bin/bash
$HOME/.venvs/aws-tools/bin/cfn-lint "$@"
EOF
            chmod +x "$HOME/.local/bin/cfn-lint"
            
            info "AWS CloudFormation Linter installed in virtual environment. Wrapper created at ~/.local/bin/cfn-lint"
        else
            error "pip3 not found. Cannot install AWS CloudFormation Linter."
            info "Please install python3-pip and try again."
        fi
    else
        info "AWS CloudFormation Linter already installed"
    fi
    
    # Create AWS development tool aliases
    info "Setting up AWS development tool aliases..."
    cat > "$HOME/.aws_dev_tools_aliases" << 'EOF'
# AWS Development Tool Aliases

# AWS SAM aliases
alias saml='sam local'
alias sami='sam init'
alias samd='sam deploy'
alias samb='sam build'
alias samp='sam package'

# AWS CDK aliases
alias cdki='cdk init'
alias cdkd='cdk deploy'
alias cdks='cdk synth'
alias cdkb='cdk bootstrap'
alias cdkdiff='cdk diff'

# Serverless Framework aliases
alias sls='serverless'
alias slsd='serverless deploy'
alias slsr='serverless remove'
alias slsi='serverless invoke'
alias slsl='serverless logs'

# AWS Amplify aliases
alias ampi='amplify init'
alias ampd='amplify deploy'
alias ampp='amplify publish'
alias ampa='amplify add'
alias ampr='amplify remove'

# AWS Copilot aliases
alias cpi='copilot init'
alias cpd='copilot deploy'
alias cps='copilot svc'
alias cpe='copilot env'
alias cpa='copilot app'

# CloudFormation aliases
alias cfn-validate='cfn-lint'
EOF
    
    info "AWS development tools setup complete"
}
