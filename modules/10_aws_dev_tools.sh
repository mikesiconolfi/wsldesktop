#!/bin/bash

# AWS development tools installation

install_aws_dev_tools() {
    section "Setting up AWS development tools"
    
    # Install AWS SAM CLI if not already installed
    if ! command_exists sam; then
        info "Installing AWS SAM CLI..."
        pip3 install --user aws-sam-cli
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
        pip3 install --user cfn-lint
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
