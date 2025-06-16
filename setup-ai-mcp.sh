#!/bin/bash

# File Name: setup-ai-mcp.sh
# Relative Path: ~/github/wsldesktop/setup-ai-mcp.sh
# Purpose: Interactive menu system for installing and managing AI tools and MCP servers.
# Detailed Overview: This script provides a comprehensive menu-driven interface for setting up
# AI development tools, MCP (Model Context Protocol) servers, and related utilities. It operates
# independently from the main WSL desktop setup and focuses specifically on AI/ML toolchain
# configuration with proper error handling and logging.

set -euo pipefail

# =============================================================================
# AI AND MCP SETUP MENU SYSTEM
# =============================================================================

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_FILE="$HOME/ai_mcp_setup.log"
readonly CONFIG_DIR="$HOME/.config/ai-mcp"
readonly VENV_DIR="$HOME/.venvs/ai-tools"

# Color definitions
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m' # No Color

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

print_header() {
    clear
    print_color "$CYAN" "═══════════════════════════════════════════════════════════════"
    print_color "$WHITE" "  🤖 AI & MCP Setup Manager"
    print_color "$CYAN" "═══════════════════════════════════════════════════════════════"
    echo
}

print_section() {
    echo
    print_color "$YELLOW" "▶ $1"
    print_color "$YELLOW" "$(printf '─%.0s' {1..50})"
}

print_success() { print_color "$GREEN" "✓ $1"; }
print_error() { print_color "$RED" "✗ $1"; }
print_warning() { print_color "$YELLOW" "⚠ $1"; }
print_info() { print_color "$BLUE" "ℹ $1"; }

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Create directories
setup_directories() {
    mkdir -p "$CONFIG_DIR"
    mkdir -p "$(dirname "$LOG_FILE")"
    log "Setup directories created"
}

# =============================================================================
# PYTHON ENVIRONMENT SETUP
# =============================================================================

setup_python_environment() {
    print_section "Setting up Python Environment for AI Tools"
    
    if ! command_exists python3; then
        print_error "Python3 not found. Please install Python3 first."
        return 1
    fi
    
    # Create virtual environment if it doesn't exist
    if [[ ! -d "$VENV_DIR" ]]; then
        print_info "Creating Python virtual environment..."
        python3 -m venv "$VENV_DIR"
        print_success "Virtual environment created at $VENV_DIR"
    else
        print_info "Virtual environment already exists"
    fi
    
    # Activate and upgrade pip
    source "$VENV_DIR/bin/activate"
    pip install --upgrade pip setuptools wheel
    
    print_success "Python environment ready"
    log "Python environment setup completed"
}

# =============================================================================
# AI TOOLS INSTALLATION
# =============================================================================

install_openai_tools() {
    print_section "Installing OpenAI & Claude Tools"
    
    source "$VENV_DIR/bin/activate"
    
    local tools=(
        "openai>=1.0.0"
        "anthropic>=0.7.0"
        "langchain"
        "langchain-community"
        "langchain-openai"
        "langchain-anthropic"
        "tiktoken"
        "python-dotenv"
        "requests"
        "httpx"
        "aiohttp"
    )
    
    for tool in "${tools[@]}"; do
        print_info "Installing $tool..."
        pip install "$tool" || print_warning "Failed to install $tool"
    done
    
    print_success "OpenAI & Claude tools installation completed"
    log "OpenAI & Claude tools installed"
}

install_amazon_q_cli() {
    print_section "Installing Amazon Q Developer CLI"
    
    # Check if Amazon Q CLI is already installed
    if command_exists q; then
        print_info "Amazon Q CLI already installed"
        q --version
        return 0
    fi
    
    print_info "Installing Amazon Q Developer CLI..."
    
    # Download and install Amazon Q CLI
    local temp_dir="/tmp/amazon-q-install"
    mkdir -p "$temp_dir"
    
    # Detect architecture
    local arch
    case "$(uname -m)" in
        x86_64) arch="x64" ;;
        aarch64|arm64) arch="arm64" ;;
        *) 
            print_error "Unsupported architecture: $(uname -m)"
            return 1
            ;;
    esac
    
    # Download Amazon Q CLI
    local download_url="https://d2bzbbjmhzjhqz.cloudfront.net/q/latest/q-linux-${arch}.tar.gz"
    
    print_info "Downloading Amazon Q CLI from $download_url..."
    if curl -fsSL "$download_url" -o "$temp_dir/q-linux.tar.gz"; then
        print_success "Download completed"
    else
        print_error "Failed to download Amazon Q CLI"
        return 1
    fi
    
    # Extract and install
    cd "$temp_dir"
    tar -xzf q-linux.tar.gz
    
    # Create installation directory
    mkdir -p "$HOME/.local/bin"
    
    # Install the binary
    if [[ -f "q" ]]; then
        cp q "$HOME/.local/bin/q"
        chmod +x "$HOME/.local/bin/q"
        print_success "Amazon Q CLI installed to ~/.local/bin/q"
    else
        print_error "Amazon Q CLI binary not found in archive"
        return 1
    fi
    
    # Clean up
    rm -rf "$temp_dir"
    
    # Verify installation
    if "$HOME/.local/bin/q" --version >/dev/null 2>&1; then
        print_success "Amazon Q CLI installation verified"
        "$HOME/.local/bin/q" --version
    else
        print_warning "Amazon Q CLI installed but verification failed"
    fi
    
    log "Amazon Q CLI installed"
}

install_local_ai_tools() {
    print_section "Installing Local AI Tools"
    
    source "$VENV_DIR/bin/activate"
    
    # Ollama (if not already installed)
    if ! command_exists ollama; then
        print_info "Installing Ollama..."
        curl -fsSL https://ollama.ai/install.sh | sh
        print_success "Ollama installed"
    else
        print_info "Ollama already installed"
    fi
    
    # Local AI Python tools
    local tools=(
        "transformers"
        "torch"
        "sentence-transformers"
        "chromadb"
        "faiss-cpu"
        "numpy"
        "pandas"
    )
    
    for tool in "${tools[@]}"; do
        print_info "Installing $tool..."
        pip install "$tool" || print_warning "Failed to install $tool"
    done
    
    print_success "Local AI tools installation completed"
    log "Local AI tools installed"
}

install_ai_development_tools() {
    print_section "Installing AI Development Tools"
    
    source "$VENV_DIR/bin/activate"
    
    local tools=(
        "jupyter"
        "jupyterlab"
        "notebook"
        "ipykernel"
        "matplotlib"
        "seaborn"
        "plotly"
        "streamlit"
        "gradio"
        "fastapi"
        "uvicorn"
    )
    
    for tool in "${tools[@]}"; do
        print_info "Installing $tool..."
        pip install "$tool" || print_warning "Failed to install $tool"
    done
    
    # Setup Jupyter kernel
    python -m ipykernel install --user --name=ai-tools --display-name="AI Tools"
    
    print_success "AI development tools installation completed"
    log "AI development tools installed"
}

create_ai_config_templates() {
    print_section "Creating AI Service Configuration Templates"
    
    local config_dir="$CONFIG_DIR"
    mkdir -p "$config_dir"
    
    # Create .env template for API keys
    local env_template="$config_dir/.env.template"
    cat > "$env_template" << 'EOF'
# AI Service API Keys Configuration Template
# Copy this file to .env and add your actual API keys

# OpenAI Configuration
OPENAI_API_KEY=your_openai_api_key_here
OPENAI_ORG_ID=your_openai_org_id_here  # Optional

# Anthropic (Claude) Configuration
ANTHROPIC_API_KEY=your_anthropic_api_key_here

# AWS Configuration for Bedrock/Q Developer
AWS_REGION=ca-central-1
AWS_PROFILE=your_aws_profile_here

# Amazon Q Developer CLI Configuration
# Q CLI uses AWS credentials automatically, but you can specify:
# AWS_PROFILE=your_preferred_profile_for_q

# LangChain Configuration
LANGCHAIN_TRACING_V2=true
LANGCHAIN_API_KEY=your_langsmith_api_key_here  # Optional for LangSmith

# Additional AI Service Keys (if needed)
# HUGGINGFACE_API_KEY=your_huggingface_key_here
# COHERE_API_KEY=your_cohere_key_here
# REPLICATE_API_TOKEN=your_replicate_token_here
EOF
    
    print_success "Environment template created at $env_template"
    
    # Create Python configuration example
    local python_config="$config_dir/ai_config_example.py"
    cat > "$python_config" << 'EOF'
"""
AI Services Configuration Example
Copy and modify this file for your AI projects
"""

import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# OpenAI Configuration
OPENAI_CONFIG = {
    "api_key": os.getenv("OPENAI_API_KEY"),
    "organization": os.getenv("OPENAI_ORG_ID"),
    "model": "gpt-4",  # Default model
    "temperature": 0.7,
    "max_tokens": 2000
}

# Anthropic (Claude) Configuration
ANTHROPIC_CONFIG = {
    "api_key": os.getenv("ANTHROPIC_API_KEY"),
    "model": "claude-3-sonnet-20240229",  # Default model
    "max_tokens": 4000,
    "temperature": 0.7
}

# AWS Bedrock Configuration
AWS_BEDROCK_CONFIG = {
    "region": os.getenv("AWS_REGION", "ca-central-1"),
    "profile": os.getenv("AWS_PROFILE"),
    "model_id": "anthropic.claude-3-sonnet-20240229-v1:0"
}

# LangChain Configuration
LANGCHAIN_CONFIG = {
    "tracing": os.getenv("LANGCHAIN_TRACING_V2", "false").lower() == "true",
    "api_key": os.getenv("LANGCHAIN_API_KEY")
}

def get_openai_client():
    """Get configured OpenAI client"""
    from openai import OpenAI
    return OpenAI(
        api_key=OPENAI_CONFIG["api_key"],
        organization=OPENAI_CONFIG.get("organization")
    )

def get_anthropic_client():
    """Get configured Anthropic client"""
    from anthropic import Anthropic
    return Anthropic(api_key=ANTHROPIC_CONFIG["api_key"])

def get_bedrock_client():
    """Get configured AWS Bedrock client"""
    import boto3
    session = boto3.Session(
        profile_name=AWS_BEDROCK_CONFIG["profile"],
        region_name=AWS_BEDROCK_CONFIG["region"]
    )
    return session.client("bedrock-runtime")

# Example usage functions
def test_openai():
    """Test OpenAI connection"""
    try:
        client = get_openai_client()
        response = client.chat.completions.create(
            model=OPENAI_CONFIG["model"],
            messages=[{"role": "user", "content": "Hello, this is a test."}],
            max_tokens=50
        )
        print("✓ OpenAI connection successful")
        return True
    except Exception as e:
        print(f"✗ OpenAI connection failed: {e}")
        return False

def test_anthropic():
    """Test Anthropic (Claude) connection"""
    try:
        client = get_anthropic_client()
        response = client.messages.create(
            model=ANTHROPIC_CONFIG["model"],
            max_tokens=50,
            messages=[{"role": "user", "content": "Hello, this is a test."}]
        )
        print("✓ Anthropic (Claude) connection successful")
        return True
    except Exception as e:
        print(f"✗ Anthropic (Claude) connection failed: {e}")
        return False

def test_all_connections():
    """Test all AI service connections"""
    print("Testing AI service connections...")
    print("=" * 40)
    
    results = {
        "OpenAI": test_openai(),
        "Anthropic": test_anthropic()
    }
    
    print("\nConnection Summary:")
    for service, status in results.items():
        status_icon = "✓" if status else "✗"
        print(f"{status_icon} {service}: {'Connected' if status else 'Failed'}")
    
    return all(results.values())

if __name__ == "__main__":
    test_all_connections()
EOF
    
    print_success "Python configuration example created at $python_config"
    
    # Create Amazon Q CLI configuration
    local q_config="$config_dir/q_cli_setup.md"
    cat > "$q_config" << 'EOF'
# Amazon Q Developer CLI Setup Guide

## Installation Verification

After installation, verify Amazon Q CLI is working:

```bash
q --version
q auth status
```

## Authentication Setup

Amazon Q CLI uses your AWS credentials. Make sure you have:

1. **AWS CLI configured** with valid credentials
2. **AWS SSO setup** (if using SSO)
3. **Appropriate permissions** for Amazon Q Developer

### Using AWS Profiles

```bash
# Set AWS profile for Q CLI
export AWS_PROFILE=your-profile-name

# Or specify profile directly
q --profile your-profile-name chat
```

### Authentication Commands

```bash
# Check authentication status
q auth status

# Login (if using SSO)
aws sso login --profile your-profile

# Test Q CLI
q chat "Hello, can you help me with AWS?"
```

## Common Q CLI Commands

### Chat Interface
```bash
# Start interactive chat
q chat

# Single question
q chat "How do I create an S3 bucket?"

# Chat with specific context
q chat --context aws-cli "Show me S3 commands"
```

### Code Analysis
```bash
# Analyze current directory
q scan

# Get code suggestions
q suggest

# Review code changes
q review
```

### AWS Integration
```bash
# Get AWS resource help
q aws s3

# Explain AWS errors
q explain "AccessDenied error in S3"

# Generate AWS CLI commands
q generate "Create VPC with public subnet"
```

## Configuration

Q CLI configuration is stored in:
- `~/.aws/config` (uses AWS configuration)
- `~/.q/` (Q-specific settings)

## Troubleshooting

### Common Issues

1. **Authentication errors:**
   ```bash
   aws sts get-caller-identity  # Verify AWS auth
   q auth status               # Check Q auth
   ```

2. **Permission errors:**
   - Ensure your AWS role has Amazon Q Developer permissions
   - Check AWS IAM policies

3. **Network issues:**
   - Verify internet connectivity
   - Check corporate firewall settings

### Getting Help

```bash
q help                    # General help
q chat --help            # Chat command help
q auth --help            # Authentication help
```
EOF
    
    print_success "Amazon Q CLI setup guide created at $q_config"
    
    # Create Jupyter notebook template
    local notebook_template="$config_dir/ai_services_demo.ipynb"
    cat > "$notebook_template" << 'EOF'
{
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# AI Services Demo Notebook\n",
    "\n",
    "This notebook demonstrates how to use OpenAI, Anthropic (Claude), and AWS Bedrock services.\n",
    "\n",
    "## Setup\n",
    "\n",
    "1. Copy `.env.template` to `.env` and add your API keys\n",
    "2. Run the cells below to test connections"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "source": [
    "# Import required libraries\n",
    "import os\n",
    "from dotenv import load_dotenv\n",
    "import openai\n",
    "import anthropic\n",
    "\n",
    "# Load environment variables\n",
    "load_dotenv()\n",
    "\n",
    "print(\"Environment loaded successfully!\")"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "source": [
    "# Test OpenAI\n",
    "from openai import OpenAI\n",
    "\n",
    "client = OpenAI(api_key=os.getenv(\"OPENAI_API_KEY\"))\n",
    "\n",
    "response = client.chat.completions.create(\n",
    "    model=\"gpt-3.5-turbo\",\n",
    "    messages=[\n",
    "        {\"role\": \"user\", \"content\": \"Hello! Can you help me with AWS development?\"}\n",
    "    ],\n",
    "    max_tokens=100\n",
    ")\n",
    "\n",
    "print(\"OpenAI Response:\")\n",
    "print(response.choices[0].message.content)"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "source": [
    "# Test Anthropic (Claude)\n",
    "from anthropic import Anthropic\n",
    "\n",
    "client = Anthropic(api_key=os.getenv(\"ANTHROPIC_API_KEY\"))\n",
    "\n",
    "response = client.messages.create(\n",
    "    model=\"claude-3-sonnet-20240229\",\n",
    "    max_tokens=100,\n",
    "    messages=[\n",
    "        {\"role\": \"user\", \"content\": \"Hello! Can you help me with AWS development?\"}\n",
    "    ]\n",
    ")\n",
    "\n",
    "print(\"Claude Response:\")\n",
    "print(response.content[0].text)"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "source": [
    "# Test AWS Bedrock (if configured)\n",
    "import boto3\n",
    "import json\n",
    "\n",
    "try:\n",
    "    # Create Bedrock client\n",
    "    bedrock = boto3.client(\n",
    "        'bedrock-runtime',\n",
    "        region_name=os.getenv('AWS_REGION', 'ca-central-1')\n",
    "    )\n",
    "    \n",
    "    # Test with Claude on Bedrock\n",
    "    prompt = \"Hello! Can you help me with AWS development?\"\n",
    "    \n",
    "    body = json.dumps({\n",
    "        \"messages\": [{\"role\": \"user\", \"content\": prompt}],\n",
    "        \"max_tokens\": 100,\n",
    "        \"anthropic_version\": \"bedrock-2023-05-31\"\n",
    "    })\n",
    "    \n",
    "    response = bedrock.invoke_model(\n",
    "        modelId=\"anthropic.claude-3-sonnet-20240229-v1:0\",\n",
    "        body=body\n",
    "    )\n",
    "    \n",
    "    result = json.loads(response['body'].read())\n",
    "    print(\"AWS Bedrock (Claude) Response:\")\n",
    "    print(result['content'][0]['text'])\n",
    "    \n",
    "except Exception as e:\n",
    "    print(f\"AWS Bedrock not available or not configured: {e}\")"
   ]
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "AI Tools",
   "language": "python",
   "name": "ai-tools"
  },
  "language_info": {
   "codemirror_mode": {
    "name": "ipython",
    "version": 3
   },
   "file_extension": ".py",
   "mimetype": "text/x-python",
   "name": "python",
   "nbconvert_exporter": "python",
   "pygments_lexer": "ipython3",
   "version": "3.8.0"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 4
}
EOF
    
    print_success "Jupyter notebook template created at $notebook_template"
    
    log "AI configuration templates created"
}

install_local_ai_tools() {
    print_section "Installing Local AI Tools"
    
    source "$VENV_DIR/bin/activate"
    
    # Ollama (if not already installed)
    if ! command_exists ollama; then
        print_info "Installing Ollama..."
        curl -fsSL https://ollama.ai/install.sh | sh
        print_success "Ollama installed"
    else
        print_info "Ollama already installed"
    fi
    
    # Local AI Python tools
    local tools=(
        "transformers"
        "torch"
        "sentence-transformers"
        "chromadb"
        "faiss-cpu"
        "numpy"
        "pandas"
    )
    
    for tool in "${tools[@]}"; do
        print_info "Installing $tool..."
        pip install "$tool" || print_warning "Failed to install $tool"
    done
    
    print_success "Local AI tools installation completed"
    log "Local AI tools installed"
}

# =============================================================================
# MCP SERVER INSTALLATION
# =============================================================================

install_mcp_core() {
    print_section "Installing MCP Core Components"
    
    source "$VENV_DIR/bin/activate"
    
    # Install MCP SDK and related tools
    local mcp_tools=(
        "mcp"
        "pydantic"
        "httpx"
        "websockets"
        "asyncio"
        "json-rpc"
    )
    
    for tool in "${mcp_tools[@]}"; do
        print_info "Installing $tool..."
        pip install "$tool" || print_warning "Failed to install $tool"
    done
    
    print_success "MCP core components installed"
    log "MCP core components installed"
}

install_aws_mcp_servers() {
    print_section "Installing AWS MCP Servers"
    
    # Create MCP servers directory
    local mcp_servers_dir="$CONFIG_DIR/servers"
    mkdir -p "$mcp_servers_dir"
    
    # List of AWS MCP servers to install
    local aws_servers=(
        "awslabs.cdk-mcp-server"
        "awslabs.aws-documentation-mcp-server"
        "awslabs.terraform-mcp-server"
        "awslabs.cost-analysis-mcp-server"
        "awslabs.bedrock-kb-retrieval-mcp-server"
        "awslabs.aws-diagram-mcp-server"
    )
    
    print_info "Available AWS MCP Servers:"
    for i in "${!aws_servers[@]}"; do
        echo "$((i+1)). ${aws_servers[i]}"
    done
    
    echo
    echo -n "Select servers to install (comma-separated numbers, or 'all'): "
    read -r selection
    
    if [[ "$selection" == "all" ]]; then
        selected_servers=("${aws_servers[@]}")
    else
        IFS=',' read -ra indices <<< "$selection"
        selected_servers=()
        for index in "${indices[@]}"; do
            index=$((index - 1))
            if [[ $index -ge 0 && $index -lt ${#aws_servers[@]} ]]; then
                selected_servers+=("${aws_servers[index]}")
            fi
        done
    fi
    
    # Install selected servers
    source "$VENV_DIR/bin/activate"
    for server in "${selected_servers[@]}"; do
        print_info "Installing $server..."
        pip install "$server" || print_warning "Failed to install $server"
    done
    
    print_success "AWS MCP servers installation completed"
    log "AWS MCP servers installed: ${selected_servers[*]}"
}

install_community_mcp_servers() {
    print_section "Installing Community MCP Servers"
    
    source "$VENV_DIR/bin/activate"
    
    # Community MCP servers
    local community_servers=(
        "filesystem-mcp-server"
        "git-mcp-server"
        "database-mcp-server"
        "web-search-mcp-server"
        "calendar-mcp-server"
    )
    
    print_info "Available Community MCP Servers:"
    for i in "${!community_servers[@]}"; do
        echo "$((i+1)). ${community_servers[i]}"
    done
    
    echo
    echo -n "Select servers to install (comma-separated numbers, or 'all'): "
    read -r selection
    
    if [[ "$selection" == "all" ]]; then
        selected_servers=("${community_servers[@]}")
    else
        IFS=',' read -ra indices <<< "$selection"
        selected_servers=()
        for index in "${indices[@]}"; do
            index=$((index - 1))
            if [[ $index -ge 0 && $index -lt ${#community_servers[@]} ]]; then
                selected_servers+=("${community_servers[index]}")
            fi
        done
    fi
    
    # Install selected servers
    for server in "${selected_servers[@]}"; do
        print_info "Installing $server..."
        pip install "$server" || print_warning "Failed to install $server (may not exist yet)"
    done
    
    print_success "Community MCP servers installation completed"
    log "Community MCP servers installed: ${selected_servers[*]}"
}

# =============================================================================
# CONFIGURATION MANAGEMENT
# =============================================================================

create_mcp_config() {
    print_section "Creating MCP Configuration"
    
    local config_file="$CONFIG_DIR/mcp-config.json"
    
    cat > "$config_file" << 'EOF'
{
  "mcpServers": {
    "aws-cdk": {
      "command": "python",
      "args": ["-m", "awslabs.cdk_mcp_server"],
      "env": {}
    },
    "aws-docs": {
      "command": "python",
      "args": ["-m", "awslabs.aws_documentation_mcp_server"],
      "env": {}
    },
    "terraform": {
      "command": "python",
      "args": ["-m", "awslabs.terraform_mcp_server"],
      "env": {}
    },
    "cost-analysis": {
      "command": "python",
      "args": ["-m", "awslabs.cost_analysis_mcp_server"],
      "env": {}
    },
    "bedrock-kb": {
      "command": "python",
      "args": ["-m", "awslabs.bedrock_kb_retrieval_mcp_server"],
      "env": {
        "AWS_REGION": "ca-central-1"
      }
    },
    "aws-diagram": {
      "command": "python",
      "args": ["-m", "awslabs.aws_diagram_mcp_server"],
      "env": {}
    }
  }
}
EOF
    
    print_success "MCP configuration created at $config_file"
    log "MCP configuration created"
}

create_ai_aliases() {
    print_section "Creating AI Tool Aliases"
    
    local aliases_file="$CONFIG_DIR/ai-aliases.sh"
    
    cat > "$aliases_file" << EOF
#!/bin/bash

# File Name: ai-aliases.sh
# Relative Path: ~/.config/ai-mcp/ai-aliases.sh
# Purpose: Aliases and shortcuts for AI tools and MCP servers including OpenAI, Claude, and Amazon Q.
# Detailed Overview: This file provides convenient aliases for activating AI environments,
# running common AI tools, managing MCP servers, and working with OpenAI, Anthropic Claude,
# and Amazon Q Developer CLI with simplified commands and configuration management.

# AI Environment Activation
alias ai-env='source $VENV_DIR/bin/activate'
alias ai-deactivate='deactivate'

# Jupyter Lab & Notebooks
alias ai-jupyter='source $VENV_DIR/bin/activate && jupyter lab'
alias ai-notebook='source $VENV_DIR/bin/activate && jupyter notebook'

# AI Development Tools
alias ai-streamlit='source $VENV_DIR/bin/activate && streamlit'
alias ai-gradio='source $VENV_DIR/bin/activate && python -c "import gradio; print(gradio.__version__)"'

# Ollama shortcuts
alias ollama-list='ollama list'
alias ollama-pull='ollama pull'
alias ollama-run='ollama run'
alias ollama-serve='ollama serve'

# Amazon Q Developer CLI shortcuts
alias q-chat='q chat'
alias q-scan='q scan'
alias q-suggest='q suggest'
alias q-review='q review'
alias q-auth='q auth status'
alias q-help='q help'

# AI Service Testing
alias test-openai='source $VENV_DIR/bin/activate && python $CONFIG_DIR/ai_config_example.py'
alias test-claude='source $VENV_DIR/bin/activate && python -c "from ai_config_example import test_anthropic; test_anthropic()"'
alias test-ai-all='source $VENV_DIR/bin/activate && python $CONFIG_DIR/ai_config_example.py'

# Configuration Management
alias ai-config='cat $CONFIG_DIR/.env 2>/dev/null || echo "No .env file found. Copy from .env.template"'
alias ai-config-edit='nano $CONFIG_DIR/.env'
alias ai-config-template='cat $CONFIG_DIR/.env.template'

# MCP Management
alias mcp-config='cat $CONFIG_DIR/mcp-config.json'
alias mcp-edit='nano $CONFIG_DIR/mcp-config.json'
alias mcp-test='source $VENV_DIR/bin/activate && python -c "import mcp; print(\"MCP available\")"'

# AI Tools Status
ai-status() {
    echo "🤖 AI Tools Status"
    echo "=================="
    echo "Python Environment: \$VIRTUAL_ENV"
    echo "Ollama: \$(command -v ollama >/dev/null && echo "✓ Installed" || echo "✗ Not installed")"
    echo "Amazon Q CLI: \$(command -v q >/dev/null && echo "✓ Installed (\$(q --version 2>/dev/null | head -1))" || echo "✗ Not installed")"
    echo "Jupyter: \$(source $VENV_DIR/bin/activate 2>/dev/null && python -c "import jupyter" 2>/dev/null && echo "✓ Available" || echo "✗ Not available")"
    echo "OpenAI: \$(source $VENV_DIR/bin/activate 2>/dev/null && python -c "import openai" 2>/dev/null && echo "✓ Available" || echo "✗ Not available")"
    echo "Anthropic: \$(source $VENV_DIR/bin/activate 2>/dev/null && python -c "import anthropic" 2>/dev/null && echo "✓ Available" || echo "✗ Not available")"
    echo "MCP Config: \$(test -f $CONFIG_DIR/mcp-config.json && echo "✓ Configured" || echo "✗ Not configured")"
    echo "API Keys: \$(test -f $CONFIG_DIR/.env && echo "✓ Configured" || echo "⚠ Not configured (copy from .env.template)")"
}

# AI Environment Info
ai-info() {
    if [[ "\$VIRTUAL_ENV" == "$VENV_DIR" ]]; then
        echo "🟢 AI environment is active"
        echo "Python: \$(python --version)"
        echo "Pip packages: \$(pip list | wc -l) installed"
        echo ""
        echo "Available AI Services:"
        python -c "
try:
    import openai; print('✓ OpenAI SDK available')
except: print('✗ OpenAI SDK not available')
try:
    import anthropic; print('✓ Anthropic SDK available')
except: print('✗ Anthropic SDK not available')
try:
    import boto3; print('✓ AWS SDK (Bedrock) available')
except: print('✗ AWS SDK not available')
"
    else
        echo "🔴 AI environment is not active"
        echo "Run 'ai-env' to activate"
    fi
}

# Quick AI setup check
ai-check() {
    echo "🔍 AI Setup Check"
    echo "================="
    
    # Check Python environment
    if [[ -d "$VENV_DIR" ]]; then
        echo "✓ Python environment: $VENV_DIR"
    else
        echo "✗ Python environment not found"
    fi
    
    # Check key packages
    source $VENV_DIR/bin/activate 2>/dev/null || true
    local packages=("openai" "anthropic" "langchain" "jupyter" "streamlit")
    for pkg in "\${packages[@]}"; do
        if python -c "import \$pkg" 2>/dev/null; then
            echo "✓ \$pkg installed"
        else
            echo "✗ \$pkg not installed"
        fi
    done
    
    # Check CLI tools
    if command -v q >/dev/null; then
        echo "✓ Amazon Q CLI installed"
    else
        echo "✗ Amazon Q CLI not installed"
    fi
    
    if command -v ollama >/dev/null; then
        echo "✓ Ollama installed"
    else
        echo "✗ Ollama not installed"
    fi
    
    # Check configuration files
    if [[ -f "$CONFIG_DIR/mcp-config.json" ]]; then
        echo "✓ MCP configuration found"
    else
        echo "✗ MCP configuration not found"
    fi
    
    if [[ -f "$CONFIG_DIR/.env" ]]; then
        echo "✓ API keys configuration found"
    else
        echo "⚠ API keys not configured (copy from .env.template)"
    fi
}

# AI Service Connection Tests
ai-test-connections() {
    echo "🔗 Testing AI Service Connections"
    echo "================================="
    
    if [[ ! -f "$CONFIG_DIR/.env" ]]; then
        echo "⚠ No .env file found. Please copy from .env.template and configure API keys."
        return 1
    fi
    
    source $VENV_DIR/bin/activate
    cd $CONFIG_DIR
    python ai_config_example.py
}

# Amazon Q CLI helpers
q-setup-check() {
    echo "🔍 Amazon Q CLI Setup Check"
    echo "==========================="
    
    if command -v q >/dev/null; then
        echo "✓ Amazon Q CLI installed"
        q --version
        echo ""
        echo "Authentication status:"
        q auth status || echo "⚠ Authentication may be required"
        echo ""
        echo "AWS Profile: \${AWS_PROFILE:-default}"
        echo "AWS Region: \${AWS_REGION:-\$(aws configure get region 2>/dev/null || echo 'not set')}"
    else
        echo "✗ Amazon Q CLI not installed"
        echo "Run the AI setup script to install it."
    fi
}

# Quick AI project setup
ai-new-project() {
    local project_name="\${1:-ai-project}"
    local project_dir="\$HOME/ai-projects/\$project_name"
    
    echo "🚀 Creating new AI project: \$project_name"
    
    mkdir -p "\$project_dir"
    cd "\$project_dir"
    
    # Copy configuration templates
    cp "$CONFIG_DIR/.env.template" ".env"
    cp "$CONFIG_DIR/ai_config_example.py" "ai_config.py"
    cp "$CONFIG_DIR/ai_services_demo.ipynb" "demo.ipynb"
    
    # Create basic project structure
    mkdir -p {data,notebooks,scripts,models}
    
    # Create README
    cat > README.md << 'PROJ_EOF'
# AI Project

## Setup

1. Configure API keys in `.env` file
2. Activate AI environment: \`ai-env\`
3. Start Jupyter: \`jupyter lab\`

## Files

- \`ai_config.py\` - AI service configuration
- \`demo.ipynb\` - Demo notebook
- \`data/\` - Data files
- \`notebooks/\` - Jupyter notebooks
- \`scripts/\` - Python scripts
- \`models/\` - Model files
PROJ_EOF
    
    echo "✓ Project created at \$project_dir"
    echo "✓ Configuration templates copied"
    echo "✓ Basic structure created"
    echo ""
    echo "Next steps:"
    echo "1. cd \$project_dir"
    echo "2. Edit .env file with your API keys"
    echo "3. ai-env (activate environment)"
    echo "4. jupyter lab (start development)"
}

# Environment management
ai-reset-env() {
    echo "🔄 Resetting AI environment..."
    echo "This will remove and recreate the Python virtual environment."
    echo -n "Are you sure? (y/N): "
    read -r confirm
    
    if [[ "\$confirm" =~ ^[Yy]\$ ]]; then
        rm -rf "$VENV_DIR"
        echo "✓ Environment removed"
        echo "Run the AI setup script to recreate it."
    else
        echo "Operation cancelled."
    fi
}

EOF
    
    print_success "AI aliases created at $aliases_file"
    
    # Add to shell configuration
    local shell_config=""
    if [[ -f "$HOME/.zshrc" ]]; then
        shell_config="$HOME/.zshrc"
    elif [[ -f "$HOME/.bashrc" ]]; then
        shell_config="$HOME/.bashrc"
    fi
    
    if [[ -n "$shell_config" ]]; then
        if ! grep -q "ai-aliases.sh" "$shell_config"; then
            echo "" >> "$shell_config"
            echo "# AI Tools Aliases" >> "$shell_config"
            echo "if [[ -f $aliases_file ]]; then" >> "$shell_config"
            echo "    source $aliases_file" >> "$shell_config"
            echo "fi" >> "$shell_config"
            print_success "AI aliases added to $shell_config"
        fi
    fi
    
    log "AI aliases created and configured"
}

# =============================================================================
# STATUS AND MANAGEMENT
# =============================================================================

show_installation_status() {
    print_section "Installation Status"
    
    # Python environment
    if [[ -d "$VENV_DIR" ]]; then
        print_success "Python environment: $VENV_DIR"
        source "$VENV_DIR/bin/activate"
        print_info "Python version: $(python --version)"
        print_info "Installed packages: $(pip list | wc -l)"
    else
        print_error "Python environment not found"
    fi
    
    # Key AI packages
    local key_packages=("openai" "anthropic" "langchain" "jupyter" "streamlit" "ollama")
    print_info "Key AI Tools Status:"
    for pkg in "${key_packages[@]}"; do
        if [[ "$pkg" == "ollama" ]]; then
            if command_exists ollama; then
                print_success "  ✓ $pkg (system)"
            else
                print_error "  ✗ $pkg (not installed)"
            fi
        else
            if source "$VENV_DIR/bin/activate" 2>/dev/null && python -c "import $pkg" 2>/dev/null; then
                print_success "  ✓ $pkg"
            else
                print_error "  ✗ $pkg"
            fi
        fi
    done
    
    # MCP configuration
    if [[ -f "$CONFIG_DIR/mcp-config.json" ]]; then
        print_success "MCP configuration: $CONFIG_DIR/mcp-config.json"
    else
        print_error "MCP configuration not found"
    fi
    
    # Log file
    if [[ -f "$LOG_FILE" ]]; then
        print_info "Setup log: $LOG_FILE ($(wc -l < "$LOG_FILE") entries)"
    fi
}

manage_services() {
    print_section "Service Management"
    
    echo "1. Start Jupyter Lab"
    echo "2. Start Ollama Service"
    echo "3. Test MCP Servers"
    echo "4. View Logs"
    echo "5. Back to main menu"
    echo
    echo -n "Select option: "
    read -r choice
    
    case $choice in
        1)
            print_info "Starting Jupyter Lab..."
            source "$VENV_DIR/bin/activate"
            jupyter lab --ip=0.0.0.0 --port=8888 --no-browser
            ;;
        2)
            print_info "Starting Ollama service..."
            ollama serve &
            print_success "Ollama service started in background"
            ;;
        3)
            print_info "Testing MCP servers..."
            source "$VENV_DIR/bin/activate"
            python -c "import mcp; print('MCP core available')" || print_error "MCP core not available"
            ;;
        4)
            print_info "Recent log entries:"
            tail -20 "$LOG_FILE" 2>/dev/null || print_warning "No log file found"
            ;;
        5)
            return
            ;;
        *)
            print_error "Invalid option"
            ;;
    esac
    
    echo
    echo "Press Enter to continue..."
    read -r
}

# =============================================================================
# MAIN MENU SYSTEM
# =============================================================================

show_main_menu() {
    print_header
    
    echo "🚀 Quick Setup Options:"
    echo "  1. Complete AI Setup (OpenAI, Claude, Amazon Q + MCP)"
    echo "  2. Python Environment Only"
    echo "  3. OpenAI & Claude Tools Only"
    echo "  4. Amazon Q Developer CLI Only"
    echo
    echo "🔧 Individual Components:"
    echo "  5. Install Local AI Tools (Ollama, Transformers)"
    echo "  6. Install AI Development Tools (Jupyter, Streamlit)"
    echo "  7. Install MCP Core Components"
    echo "  8. Install AWS MCP Servers"
    echo "  9. Install Community MCP Servers"
    echo
    echo "⚙️  Configuration & Management:"
    echo " 10. Create AI Service Configuration Templates"
    echo " 11. Create MCP Configuration"
    echo " 12. Setup AI Aliases & Shortcuts"
    echo " 13. Show Installation Status"
    echo " 14. Manage Services"
    echo " 15. Test AI Service Connections"
    echo
    echo " 16. Exit"
    echo
    echo -n "Select option (1-16): "
}

complete_ai_setup() {
    print_section "Complete AI Setup (OpenAI, Claude, Amazon Q + MCP)"
    print_info "This will install all AI tools, CLI tools, and MCP servers"
    
    setup_python_environment
    install_openai_tools
    install_amazon_q_cli
    install_local_ai_tools
    install_ai_development_tools
    install_mcp_core
    install_aws_mcp_servers
    create_ai_config_templates
    create_mcp_config
    create_ai_aliases
    
    print_success "Complete AI setup finished!"
    print_info "Next steps:"
    print_info "1. Copy ~/.config/ai-mcp/.env.template to ~/.config/ai-mcp/.env"
    print_info "2. Add your API keys to the .env file"
    print_info "3. Restart your shell: exec zsh (or exec bash)"
    print_info "4. Test connections: ai-test-connections"
    print_info "5. Start developing: ai-env && ai-jupyter"
    
    log "Complete AI setup completed"
}

test_ai_connections() {
    print_section "Testing AI Service Connections"
    
    if [[ ! -d "$VENV_DIR" ]]; then
        print_error "AI environment not found. Please run setup first."
        return 1
    fi
    
    source "$VENV_DIR/bin/activate"
    
    # Test Amazon Q CLI
    print_info "Testing Amazon Q Developer CLI..."
    if command_exists q; then
        print_success "Amazon Q CLI installed"
        q --version
        print_info "Authentication status:"
        q auth status || print_warning "Amazon Q CLI authentication may be required"
    else
        print_error "Amazon Q CLI not found"
    fi
    
    echo
    
    # Test Python AI libraries
    print_info "Testing Python AI libraries..."
    
    local test_script="$CONFIG_DIR/connection_test.py"
    cat > "$test_script" << 'EOF'
import os
import sys

def test_imports():
    """Test if AI libraries can be imported"""
    results = {}
    
    # Test OpenAI
    try:
        import openai
        results['OpenAI'] = f"✓ Available (version: {openai.__version__})"
    except ImportError as e:
        results['OpenAI'] = f"✗ Not available: {e}"
    
    # Test Anthropic
    try:
        import anthropic
        results['Anthropic'] = f"✓ Available (version: {anthropic.__version__})"
    except ImportError as e:
        results['Anthropic'] = f"✗ Not available: {e}"
    
    # Test LangChain
    try:
        import langchain
        results['LangChain'] = f"✓ Available (version: {langchain.__version__})"
    except ImportError as e:
        results['LangChain'] = f"✗ Not available: {e}"
    
    # Test AWS SDK
    try:
        import boto3
        results['AWS SDK'] = f"✓ Available (version: {boto3.__version__})"
    except ImportError as e:
        results['AWS SDK'] = f"✗ Not available: {e}"
    
    return results

def test_api_connections():
    """Test actual API connections if keys are available"""
    from dotenv import load_dotenv
    load_dotenv()
    
    results = {}
    
    # Test OpenAI connection
    if os.getenv('OPENAI_API_KEY'):
        try:
            from openai import OpenAI
            client = OpenAI(api_key=os.getenv('OPENAI_API_KEY'))
            # Simple test - just try to create client and make a minimal request
            models = client.models.list()
            results['OpenAI API'] = "✓ Connection successful"
        except Exception as e:
            results['OpenAI API'] = f"✗ Connection failed: {str(e)[:50]}..."
    else:
        results['OpenAI API'] = "⚠ No API key configured"
    
    # Test Anthropic connection
    if os.getenv('ANTHROPIC_API_KEY'):
        try:
            from anthropic import Anthropic
            client = Anthropic(api_key=os.getenv('ANTHROPIC_API_KEY'))
            # Test with a minimal request
            response = client.messages.create(
                model="claude-3-haiku-20240307",
                max_tokens=10,
                messages=[{"role": "user", "content": "Hi"}]
            )
            results['Anthropic API'] = "✓ Connection successful"
        except Exception as e:
            results['Anthropic API'] = f"✗ Connection failed: {str(e)[:50]}..."
    else:
        results['Anthropic API'] = "⚠ No API key configured"
    
    return results

if __name__ == "__main__":
    print("🔍 AI Libraries Import Test")
    print("=" * 30)
    
    import_results = test_imports()
    for service, status in import_results.items():
        print(f"{service}: {status}")
    
    print("\n🔗 API Connection Test")
    print("=" * 30)
    
    connection_results = test_api_connections()
    for service, status in connection_results.items():
        print(f"{service}: {status}")
    
    print("\n📋 Summary")
    print("=" * 30)
    
    # Check if .env file exists
    env_file = os.path.join(os.path.dirname(__file__), '.env')
    if os.path.exists(env_file):
        print("✓ Configuration file (.env) found")
    else:
        print("⚠ Configuration file (.env) not found")
        print("  Copy .env.template to .env and add your API keys")
EOF
    
    python "$test_script"
    
    # Clean up test script
    rm -f "$test_script"
    
    echo
    print_info "Connection test completed"
    print_info "If you see connection failures, check your API keys in ~/.config/ai-mcp/.env"
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

main() {
    setup_directories
    log "AI & MCP Setup Manager started"
    
    while true; do
        show_main_menu
        read -r choice
        
        case $choice in
            1)
                complete_ai_setup
                ;;
            2)
                setup_python_environment
                ;;
            3)
                setup_python_environment
                install_openai_tools
                ;;
            4)
                setup_python_environment
                install_amazon_q_cli
                ;;
            5)
                setup_python_environment
                install_local_ai_tools
                ;;
            6)
                setup_python_environment
                install_ai_development_tools
                ;;
            7)
                setup_python_environment
                install_mcp_core
                ;;
            8)
                setup_python_environment
                install_mcp_core
                install_aws_mcp_servers
                ;;
            9)
                setup_python_environment
                install_mcp_core
                install_community_mcp_servers
                ;;
            10)
                create_ai_config_templates
                ;;
            11)
                create_mcp_config
                ;;
            12)
                create_ai_aliases
                ;;
            13)
                show_installation_status
                echo
                echo "Press Enter to continue..."
                read -r
                ;;
            14)
                manage_services
                ;;
            15)
                test_ai_connections
                echo
                echo "Press Enter to continue..."
                read -r
                ;;
            16)
                print_success "Goodbye!"
                log "AI & MCP Setup Manager exited"
                exit 0
                ;;
            *)
                print_error "Invalid option. Please select 1-16."
                sleep 2
                ;;
        esac
    done
}

# Run main function
main "$@"
