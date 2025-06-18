# AI & MCP Setup Manager

## 🤖 Overview

This is a comprehensive, standalone setup system for AI tools and MCP (Model Context Protocol) servers that operates independently from your main WSL desktop installation. It provides a menu-driven interface for installing and managing AI development tools, language models, and MCP servers.

## 🚀 Quick Start

```bash
cd ~/github/wsldesktop
chmod +x setup-ai-mcp.sh
./setup-ai-mcp.sh
```

## 📋 Menu Options

### 🚀 Quick Setup Options

| Option | Description | What It Installs |
|--------|-------------|-------------------|
| **1. Complete AI Setup** | Full installation (Recommended) | Everything below |
| **2. Python Environment Only** | Basic Python setup | Virtual environment + pip |
| **3. OpenAI Tools Only** | Essential AI libraries | OpenAI, Anthropic, LangChain |

### 🔧 Individual Components

| Option | Description | Components |
|--------|-------------|------------|
| **4. Local AI Tools** | Self-hosted AI tools | Ollama, Transformers, ChromaDB |
| **5. AI Development Tools** | Development environment | Jupyter, Streamlit, FastAPI |
| **6. MCP Core Components** | MCP framework | MCP SDK, WebSockets, JSON-RPC |
| **7. AWS MCP Servers** | AWS-specific MCP servers | CDK, Documentation, Terraform |
| **8. Community MCP Servers** | Third-party MCP servers | Filesystem, Git, Database |

### ⚙️ Configuration & Management

| Option | Description | Purpose |
|--------|-------------|---------|
| **9. Create MCP Configuration** | Generate MCP config files | Server definitions |
| **10. Setup AI Aliases** | Create shortcuts | Command aliases |
| **11. Show Installation Status** | Check what's installed | Status overview |
| **12. Manage Services** | Start/stop services | Service management |

## 🏗️ Installation Structure

```
~/.config/ai-mcp/           # Configuration directory
├── mcp-config.json         # MCP server configuration
├── ai-aliases.sh           # AI tool aliases
└── servers/                # MCP server installations

~/.venvs/ai-tools/          # Python virtual environment
├── bin/                    # Python executables
├── lib/                    # Installed packages
└── include/                # Headers

~/ai_mcp_setup.log          # Installation log
```

## 🛠️ Installed Tools

### Core AI Libraries & Services
- **OpenAI**: Official OpenAI Python client with GPT-4 support
- **Anthropic (Claude)**: Claude API client with latest models
- **Amazon Q Developer CLI**: AWS's AI-powered developer assistant
- **LangChain**: AI application framework with multi-provider support
- **Tiktoken**: Token counting utilities

### Local AI Tools
- **Ollama**: Local language model runner
- **Transformers**: Hugging Face transformers
- **ChromaDB**: Vector database
- **FAISS**: Similarity search

### Development Tools
- **Jupyter Lab**: Interactive development environment
- **Streamlit**: Web app framework for AI demos
- **Gradio**: ML demo interface
- **FastAPI**: API development framework

### MCP Servers
- **AWS CDK MCP**: Infrastructure as code integration
- **AWS Documentation MCP**: AWS docs integration
- **Terraform MCP**: Infrastructure management
- **Cost Analysis MCP**: AWS cost analysis
- **Bedrock KB MCP**: Knowledge base integration
- **AWS Diagram MCP**: Architecture diagrams

## 🎯 Usage Examples

### Activating AI Environment
```bash
# Using alias (after setup)
ai-env

# Manual activation
source ~/.venvs/ai-tools/bin/activate
```

### Starting Development Tools
```bash
# Jupyter Lab
ai-jupyter

# Streamlit app
ai-streamlit run app.py

# Check status
ai-status
```

### Using Amazon Q Developer CLI
```bash
# Check installation and authentication
ai-mcp q-status

# Start interactive chat
q-chat

# Scan code for issues
q-scan

# Get code suggestions
q-suggest

# Review code changes
q-review
```

### Testing AI Service Connections
```bash
# Test all configured AI services
ai-test-connections

# Or use the quick launcher
ai-mcp test
```

### MCP Configuration
```bash
# View MCP config
mcp-config

# Edit MCP config
mcp-edit

# Test MCP installation
mcp-test
```

## 🔧 Configuration Files

### MCP Configuration (`~/.config/ai-mcp/mcp-config.json`)
```json
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
    }
  }
}
```

### AI Aliases (`~/.config/ai-mcp/ai-aliases.sh`)
Automatically sourced in your shell, provides:
- `ai-env` - Activate AI environment
- `ai-jupyter` - Start Jupyter Lab
- `ai-status` - Show AI tools status
- `ai-check` - Verify installation
- `ollama-*` - Ollama shortcuts

## 🔍 Status Checking

### Quick Status Check
```bash
ai-status
```

### Detailed Installation Check
```bash
ai-check
```

### View Installation Log
```bash
tail -f ~/ai_mcp_setup.log
```

## 🚀 Getting Started Workflow

1. **Run the setup script:**
   ```bash
   ./setup-ai-mcp.sh
   ```

2. **Choose option 1 for complete setup** (recommended for first-time users)

3. **Restart your shell** to load aliases:
   ```bash
   exec zsh  # or exec bash
   ```

4. **Test the installation:**
   ```bash
   ai-status
   ai-check
   ```

5. **Start developing:**
   ```bash
   ai-env                    # Activate environment
   ai-jupyter               # Start Jupyter Lab
   ```

## 🔧 Advanced Usage

### Custom MCP Server Installation
```bash
# Activate AI environment
ai-env

# Install custom MCP server
pip install your-custom-mcp-server

# Update MCP configuration
mcp-edit
```

### Adding New AI Tools
```bash
# Activate environment
ai-env

# Install additional tools
pip install your-ai-tool

# Update aliases if needed
nano ~/.config/ai-mcp/ai-aliases.sh
```

## 🛡️ Security Considerations

### API Keys Management
- Store API keys in environment variables
- Use `.env` files for local development
- Never commit API keys to version control

### Virtual Environment Isolation
- All AI tools are installed in isolated environment
- No conflicts with system Python packages
- Easy to remove or recreate

## 🐛 Troubleshooting

### Common Issues

1. **Python environment not found:**
   ```bash
   # Recreate environment
   rm -rf ~/.venvs/ai-tools
   ./setup-ai-mcp.sh  # Choose option 2
   ```

2. **MCP servers not working:**
   ```bash
   # Check MCP configuration
   mcp-config
   
   # Test MCP installation
   mcp-test
   ```

3. **Ollama not responding:**
   ```bash
   # Start Ollama service
   ollama serve
   
   # Check if running
   ps aux | grep ollama
   ```

4. **Jupyter not starting:**
   ```bash
   # Activate environment first
   ai-env
   
   # Then start Jupyter
   jupyter lab
   ```

### Log Analysis
```bash
# View recent setup activities
tail -20 ~/ai_mcp_setup.log

# Search for errors
grep -i error ~/ai_mcp_setup.log
```

## 🔄 Updates and Maintenance

### Updating AI Tools
```bash
# Activate environment
ai-env

# Update all packages
pip list --outdated
pip install --upgrade package-name
```

### Updating MCP Servers
```bash
# Activate environment
ai-env

# Update AWS MCP servers
pip install --upgrade awslabs.cdk-mcp-server
pip install --upgrade awslabs.aws-documentation-mcp-server
```

### Cleaning Up
```bash
# Remove AI environment
rm -rf ~/.venvs/ai-tools

# Remove configuration
rm -rf ~/.config/ai-mcp

# Remove log
rm ~/ai_mcp_setup.log
```

## 📚 Integration with Other Tools

### VS Code Integration
- Install Python extension
- Select AI tools interpreter: `~/.venvs/ai-tools/bin/python`
- Configure Jupyter extension to use AI environment

### Shell Integration
- Aliases automatically loaded in new shells
- Environment activation shortcuts available
- Status checking commands ready to use

## 🤝 Support

### Getting Help
1. Check the installation status: `ai-status`
2. Review the setup log: `tail ~/ai_mcp_setup.log`
3. Verify configuration: `ai-check`
4. Re-run specific setup components as needed

### Reporting Issues
Include the following information:
- Output of `ai-status`
- Relevant log entries from `~/ai_mcp_setup.log`
- Your operating system and Python version
- Steps to reproduce the issue

---

**Note**: This AI & MCP setup system is completely independent of your main WSL desktop installation and can be safely installed, updated, or removed without affecting your core development environment.
