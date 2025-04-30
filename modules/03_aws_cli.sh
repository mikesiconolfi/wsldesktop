#!/bin/bash

# AWS CLI and related tools installation

install_aws_cli() {
    section "Setting up AWS CLI and tools"
    
    # Install AWS CLI v2 if not already installed
    if ! command_exists aws || [[ $(aws --version 2>&1) != *"aws-cli/2"* ]]; then
        info "Installing AWS CLI v2..."
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
        unzip -q -o "/tmp/awscliv2.zip" -d "/tmp"
        sudo /tmp/aws/install --update
        rm -rf /tmp/aws /tmp/awscliv2.zip
    else
        info "AWS CLI v2 already installed"
    fi
    
    # Install AWS SSO utils
    if ! command_exists aws-sso-util; then
        info "Installing AWS SSO utils..."
        if command_exists pip3; then
            # Create a virtual environment for Python packages
            info "Creating Python virtual environment for AWS tools..."
            mkdir -p "$HOME/.venvs"
            python3 -m venv "$HOME/.venvs/aws-tools"
            
            # Install AWS SSO utils in the virtual environment
            "$HOME/.venvs/aws-tools/bin/pip" install aws-sso-util >> "$LOG_FILE" 2>&1 || {
                error "Failed to install AWS SSO utils. Please install it manually."
            }
            
            # Create wrapper script
            mkdir -p "$HOME/.local/bin"
            cat > "$HOME/.local/bin/aws-sso-util" << 'EOF'
#!/bin/bash
$HOME/.venvs/aws-tools/bin/aws-sso-util "$@"
EOF
            chmod +x "$HOME/.local/bin/aws-sso-util"
            
            info "AWS SSO utils installed in virtual environment. Wrapper created at ~/.local/bin/aws-sso-util"
        else
            error "pip3 not found. Cannot install AWS SSO utils."
            info "Please install python3-pip and try again."
        fi
    else
        info "AWS SSO utils already installed"
    fi
    
    # Create AWS config directory if it doesn't exist
    mkdir -p "$HOME/.aws"
    
    # Backup existing AWS config files
    backup_file "$HOME/.aws/config"
    backup_file "$HOME/.aws/credentials"
    
    # Create sample AWS config if it doesn't exist
    if [[ ! -f "$HOME/.aws/config" ]]; then
        info "Creating sample AWS config..."
        cat > "$HOME/.aws/config" << 'EOF'
[default]
region = us-east-1
output = json

[profile work]
sso_start_url = https://your-company.awsapps.com/start
sso_region = us-east-1
sso_account_id = 123456789012
sso_role_name = PowerUserAccess
region = us-east-1
output = json

[profile dev]
role_arn = arn:aws:iam::123456789012:role/Developer
source_profile = default
region = us-east-1
output = json
EOF
    else
        info "AWS config already exists, preserving existing configuration"
    fi
    
    # Create AWS profile switcher function
    info "Setting up AWS profile switcher..."
    cat > "$HOME/.aws_profile_switcher" << 'EOF'
# AWS Profile Switcher
awsp() {
    local profile=$(grep -E '^\[profile |^\[' ~/.aws/config | sed -E 's/\[profile (.*)\]/\1/g' | sed -E 's/\[(.*)\]/\1/g' | sort | fzf)
    if [[ -n "$profile" ]]; then
        export AWS_PROFILE="$profile"
        echo "AWS Profile set to $profile"
        
        # Check if this is an SSO profile by looking for sso_start_url in the profile section
        if grep -A 10 "\[profile $profile\]" ~/.aws/config | grep -q "sso_"; then
            # Try to get caller identity, if it fails, trigger SSO login
            if ! aws sts get-caller-identity &>/dev/null; then
                echo "SSO credentials expired or missing. Starting SSO login process..."
                aws sso login --profile "$profile"
            fi
        fi
        
        # Display current identity
        aws sts get-caller-identity
    fi
}

# AWS SSO Login for all profiles
aws-sso-login-all() {
    echo "Starting SSO login for all SSO profiles..."
    local sso_profiles=$(grep -A 5 "sso_" ~/.aws/config | grep -B 5 "sso_" | grep "^\[profile" | sed -E 's/\[profile (.*)\]/\1/g')
    
    if [[ -z "$sso_profiles" ]]; then
        echo "No SSO profiles found in ~/.aws/config"
        return 1
    fi
    
    echo "Found the following SSO profiles:"
    echo "$sso_profiles"
    echo ""
    
    for profile in $sso_profiles; do
        echo "Logging in to profile: $profile"
        aws sso login --profile "$profile"
    done
    
    echo "SSO login completed for all profiles"
}

# AWS Region Switcher
awsregion() {
    local regions=(
        "us-east-1" "us-east-2" "us-west-1" "us-west-2" 
        "ca-central-1" "ca-west-1"
        "eu-west-1" "eu-west-2" "eu-central-1" 
        "ap-northeast-1" "ap-northeast-2" "ap-southeast-1" "ap-southeast-2" 
        "sa-east-1"
    )
    local region=$(printf "%s\n" "${regions[@]}" | fzf)
    if [[ -n "$region" ]]; then
        export AWS_REGION="$region"
        export AWS_DEFAULT_REGION="$region"
        echo "AWS Region set to $region"
    fi
}

# AWS Aliases
alias awsw='aws --profile work'
alias awsd='aws --profile dev'
alias awsl='cat ~/.aws/config | grep -E "^\[|^region" | sed "s/profile //g"'
alias awsid='aws sts get-caller-identity'
alias awsec2='aws ec2 describe-instances --query "Reservations[*].Instances[*].{Name:Tags[?Key==\`Name\`].Value|[0],InstanceId:InstanceId,State:State.Name,Type:InstanceType,IP:PrivateIpAddress}" --output table'
alias awss3='aws s3 ls'
alias awslambda='aws lambda list-functions --query "Functions[*].{Name:FunctionName,Runtime:Runtime,Memory:MemorySize,Timeout:Timeout}" --output table'

# AWS CloudWatch Logs Function
awslogs() {
    local log_group=$(aws logs describe-log-groups --query "logGroups[*].logGroupName" --output text | tr '\t' '\n' | fzf)
    if [[ -n "$log_group" ]]; then
        local log_stream=$(aws logs describe-log-streams --log-group-name "$log_group" --order-by LastEventTime --descending --query "logStreams[*].logStreamName" --output text | tr '\t' '\n' | fzf)
        if [[ -n "$log_stream" ]]; then
            aws logs get-log-events --log-group-name "$log_group" --log-stream-name "$log_stream" --query "events[*].message" --output text
        fi
    fi
}

# AWS EC2 List Function
awsec2list() {
    aws ec2 describe-instances --query "Reservations[*].Instances[*].{Name:Tags[?Key==\`Name\`].Value|[0],InstanceId:InstanceId,State:State.Name,Type:InstanceType,IP:PrivateIpAddress,PublicIP:PublicIpAddress,LaunchTime:LaunchTime}" --output table
}

# AWS CloudFormation Status Function
awscf() {
    aws cloudformation list-stacks --query "StackSummaries[*].{Name:StackName,Status:StackStatus,Created:CreationTime,Updated:LastUpdatedTime}" --output table
}
EOF
    
    info "AWS CLI and tools setup complete"
}
