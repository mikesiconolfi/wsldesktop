#!/bin/bash

# AWS Session Manager installation and configuration

install_session_manager() {
    section "Setting up AWS Session Manager"
    
    # Check for package manager lock
    if [[ "$IGNORE_LOCKS" != "1" ]] && pgrep -f "apt-get|dpkg" > /dev/null; then
        error "Another package manager process is running. Session Manager installation will be skipped."
        info "You can install Session Manager manually later or re-run this module."
        info "To bypass this check, use: IGNORE_LOCKS=1 ./setup-aws-wsl.sh"
        return 1
    fi
    
    # Install Session Manager plugin if not already installed
    if ! command_exists session-manager-plugin; then
        info "Installing AWS Session Manager plugin..."
        curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "/tmp/session-manager-plugin.deb"
        sudo dpkg -i /tmp/session-manager-plugin.deb
        rm /tmp/session-manager-plugin.deb
    else
        info "AWS Session Manager plugin already installed"
    fi
    
    # Create Session Manager helper functions
    info "Setting up Session Manager helper functions..."
    cat > "$HOME/.session_manager_functions" << 'EOF'
# AWS Session Manager Functions

# Connect to an EC2 instance via Session Manager
ssm-connect() {
    local instance_id="$1"
    if [[ -z "$instance_id" ]]; then
        echo "Usage: ssm-connect <instance-id>"
        return 1
    fi
    
    aws ssm start-session --target "$instance_id"
}

# List and connect to EC2 instances via Session Manager
ssm-list-connect() {
    local instance=$(aws ec2 describe-instances \
        --filters "Name=instance-state-name,Values=running" \
        --query "Reservations[*].Instances[*].{Name:Tags[?Key=='Name']|[0].Value,InstanceId:InstanceId,IP:PrivateIpAddress,Type:InstanceType}" \
        --output json | jq -r '.[][] | "\(.Name) - \(.InstanceId) - \(.IP) - \(.Type)"' | fzf | awk -F' - ' '{print $2}')
    
    if [[ -n "$instance" ]]; then
        echo "Connecting to instance $instance..."
        ssm-connect "$instance"
    fi
}

# Run a command on an EC2 instance via Session Manager
ssm-run-command() {
    local instance_id="$1"
    local command="$2"
    
    if [[ -z "$instance_id" || -z "$command" ]]; then
        echo "Usage: ssm-run-command <instance-id> <command>"
        return 1
    fi
    
    aws ssm send-command \
        --instance-ids "$instance_id" \
        --document-name "AWS-RunShellScript" \
        --parameters "commands=[\"$command\"]" \
        --output text --query "Command.CommandId"
}

# Get the output of a command run via Session Manager
ssm-get-command-output() {
    local command_id="$1"
    local instance_id="$2"
    
    if [[ -z "$command_id" || -z "$instance_id" ]]; then
        echo "Usage: ssm-get-command-output <command-id> <instance-id>"
        return 1
    fi
    
    aws ssm get-command-invocation \
        --command-id "$command_id" \
        --instance-id "$instance_id" \
        --query "StandardOutputContent" \
        --output text
}
EOF
    
    info "AWS Session Manager setup complete"
}
