#!/bin/bash

# Kubernetes and EKS tools installation

install_kubernetes() {
    section "Setting up Kubernetes and EKS tools"
    
    # Install kubectl if not already installed
    if ! command_exists kubectl; then
        info "Installing kubectl..."
        sudo curl -L "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" -o /usr/local/bin/kubectl
        sudo chmod +x /usr/local/bin/kubectl
    else
        info "kubectl already installed"
    fi
    
    # Install eksctl if not already installed
    if ! command_exists eksctl; then
        info "Installing eksctl..."
        curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
        sudo mv /tmp/eksctl /usr/local/bin
        sudo chmod +x /usr/local/bin/eksctl
    else
        info "eksctl already installed"
    fi
    
    # Install Helm if not already installed
    if ! command_exists helm; then
        info "Installing Helm..."
        curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    else
        info "Helm already installed"
    fi
    
    # Install k9s if not already installed
    if ! command_exists k9s; then
        info "Installing k9s..."
        K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep tag_name | cut -d '"' -f 4)
        curl -L "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz" | tar xz -C /tmp
        sudo mv /tmp/k9s /usr/local/bin
        sudo chmod +x /usr/local/bin/k9s
    else
        info "k9s already installed"
    fi
    
    # Install kubectx and kubens if not already installed
    if ! command_exists kubectx; then
        info "Installing kubectx and kubens..."
        sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
        sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
        sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens
    else
        info "kubectx already installed"
    fi
    
    # Create Kubernetes config directory if it doesn't exist
    mkdir -p "$HOME/.kube"
    
    # Backup existing Kubernetes config
    backup_file "$HOME/.kube/config"
    
    # Create EKS helper functions
    info "Setting up EKS helper functions..."
    cat > "$HOME/.eks_functions" << 'EOF'
# EKS Helper Functions

# List all EKS clusters
eks-list() {
    aws eks list-clusters --query "clusters" --output table
}

# Switch between EKS clusters
eks-switch() {
    local cluster=$(aws eks list-clusters --query "clusters[]" --output text | tr '\t' '\n' | fzf)
    if [[ -n "$cluster" ]]; then
        eks-kubeconfig "$cluster"
    fi
}

# Update kubeconfig for a specific cluster
eks-kubeconfig() {
    local cluster="$1"
    if [[ -z "$cluster" ]]; then
        echo "Usage: eks-kubeconfig <cluster-name>"
        return 1
    fi
    
    # Backup existing kubeconfig
    backup_file "$HOME/.kube/config"
    
    # Update kubeconfig
    aws eks update-kubeconfig --name "$cluster"
    echo "Switched to EKS cluster: $cluster"
}

# Launch k9s for EKS management
eks-manage() {
    k9s
}

# List all pods across namespaces
eks-pods() {
    kubectl get pods --all-namespaces
}

# List all nodes with status
eks-nodes() {
    kubectl get nodes -o wide
}

# Get a shell on a pod
eks-shell() {
    local pod=$(kubectl get pods --all-namespaces -o wide | tail -n +2 | fzf | awk '{print $2 " -n " $1}')
    if [[ -n "$pod" ]]; then
        kubectl exec -it $pod -- /bin/bash || kubectl exec -it $pod -- /bin/sh
    fi
}

# Install AWS Load Balancer Controller
eks-install-alb() {
    local cluster="$1"
    if [[ -z "$cluster" ]]; then
        echo "Usage: eks-install-alb <cluster-name>"
        return 1
    fi
    
    # Get cluster VPC ID
    local vpc_id=$(aws eks describe-cluster --name "$cluster" --query "cluster.resourcesVpcConfig.vpcId" --output text)
    
    # Install AWS Load Balancer Controller using Helm
    helm repo add eks https://aws.github.io/eks-charts
    helm repo update
    
    helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
        -n kube-system \
        --set clusterName="$cluster" \
        --set serviceAccount.create=true \
        --set serviceAccount.name=aws-load-balancer-controller \
        --set region=$(aws configure get region) \
        --set vpcId="$vpc_id"
    
    echo "AWS Load Balancer Controller installed for cluster: $cluster"
}

# Backup function for kubeconfig
backup_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        local backup="${file}.bak.$(date +%Y%m%d%H%M%S)"
        echo "Creating backup of $file to $backup"
        cp "$file" "$backup"
        return 0
    fi
    return 1
}
EOF
    
    # Kubernetes aliases
    info "Setting up Kubernetes aliases..."
    cat > "$HOME/.kubernetes_aliases" << 'EOF'
# Kubernetes aliases
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'
alias kgn='kubectl get nodes'
alias kgc='kubectl get configmaps'
alias kgs='kubectl get secrets'
alias kgall='kubectl get all'
alias kdesc='kubectl describe'
alias klogs='kubectl logs'
alias kexec='kubectl exec -it'
alias kns='kubens'
alias kctx='kubectx'
EOF
    
    info "Kubernetes and EKS tools setup complete"
}
