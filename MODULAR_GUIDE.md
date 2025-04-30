# Modular WSL Desktop Setup Guide

This document explains the modular architecture of the AWS Power User WSL Setup and provides guidance for developers who want to maintain or extend the codebase.

## Modular Architecture Overview

The setup script has been completely modularized for better maintainability and flexibility. Here's how it's structured:

```
/home/mike/github/wsldesktop/
├── modules/                      # Directory containing all module scripts
│   ├── 00_common.sh              # Common functions used across all modules
│   ├── 01_base_system.sh         # Base system setup (ZSH, Oh My Zsh)
│   ├── 02_theme_fonts.sh         # Theme and fonts (Powerlevel10k)
│   ├── 03_aws_cli.sh             # AWS CLI and related tools
│   ├── 04_docker.sh              # Docker and container tools
│   ├── 05_kubernetes.sh          # Kubernetes and EKS tools
│   ├── 06_terraform.sh           # Terraform setup
│   ├── 07_session_manager.sh     # AWS Session Manager
│   ├── 08_modern_cli.sh          # Modern CLI tools
│   ├── 09_1password.sh           # 1Password integration
│   ├── 10_aws_dev_tools.sh       # AWS development tools
│   └── 11_zsh_config.sh          # ZSH configuration
└── setup-aws-wsl.sh              # Main script that calls the modules
```

## How the Modular System Works

1. **Main Script (`setup-aws-wsl.sh`)**: 
   - Entry point for the setup process
   - Handles component selection via an interactive menu
   - Sources and executes the selected module scripts

2. **Common Module (`00_common.sh`)**:
   - Contains shared functions used across all modules
   - Includes utility functions for output formatting, dependency checking, and file backups
   - Sourced by the main script and available to all modules

3. **Component Modules (`01_*.sh` to `11_*.sh`)**:
   - Each module is responsible for one specific component
   - Self-contained with its own installation function
   - Can be run independently if needed

## Key Design Principles

1. **Modularity**: Each component is isolated in its own file
2. **Reusability**: Functions are designed to be reused across modules
3. **Error Handling**: Each module includes proper error handling
4. **Configuration Preservation**: Automatic backups of existing configurations
5. **User Feedback**: Clear messaging throughout the installation process

## Module Structure

Each module follows a consistent structure:

```bash
#!/bin/bash

# Module description

install_module_name() {
    section "Setting up module name"
    
    # Check if components are already installed
    if ! command_exists component; then
        info "Installing component..."
        # Installation commands
    else
        info "Component already installed"
    fi
    
    # Configuration
    info "Configuring component..."
    
    # Create helper functions or aliases
    info "Setting up helper functions..."
    
    info "Module setup complete"
}
```

## Adding a New Module

To add a new module to the system:

1. Create a new script in the `modules` directory:
   ```bash
   touch modules/12_my_custom_module.sh
   chmod +x modules/12_my_custom_module.sh
   ```

2. Implement your module following the standard structure:
   ```bash
   #!/bin/bash

   # My custom module

   install_my_custom_module() {
       section "Setting up my custom module"
       
       # Your installation code here
       
       info "My custom module setup complete"
   }
   ```

3. Update the main script to include your module in the selection menu:
   ```bash
   # In setup-aws-wsl.sh, update the options array:
   local options=(
       # Existing options...
       "My Custom Module"
       "All Components"
   )
   
   # And update the install_selected_components function:
   case $component in
       # Existing cases...
       11)
           source "$(dirname "$0")/modules/12_my_custom_module.sh"
           install_my_custom_module
           ;;
       12) # Update the "All Components" index
           selected=(0 1 2 3 4 5 6 7 8 9 10 11)
           ;;
   esac
   ```

## Modifying Existing Modules

To modify an existing module:

1. Open the module file in your editor
2. Make your changes, following the established patterns
3. Test your changes by running the module directly:
   ```bash
   ./modules/03_aws_cli.sh
   ```

## Best Practices for Module Development

1. **Check for Existing Installations**: Always check if a component is already installed before attempting to install it
2. **Backup Configurations**: Use the `backup_file` function to create backups of configuration files
3. **Provide User Feedback**: Use `section`, `info`, and `error` functions to keep the user informed
4. **Handle Errors**: Check for errors after critical operations and provide meaningful error messages
5. **Idempotence**: Ensure modules can be run multiple times without causing issues
6. **Dependencies**: Clearly document and check for dependencies

## Testing Modules

To test a module:

1. Run the module directly:
   ```bash
   source ./modules/00_common.sh
   source ./modules/03_aws_cli.sh
   install_aws_cli
   ```

2. Verify that the module:
   - Installs the component correctly
   - Creates appropriate configuration files
   - Handles existing installations gracefully
   - Creates backups of existing configurations
   - Provides clear feedback throughout the process

## Troubleshooting Module Issues

If a module is not working as expected:

1. Run the module with bash debugging:
   ```bash
   bash -x ./modules/03_aws_cli.sh
   ```

2. Check for common issues:
   - Missing dependencies
   - Permission issues
   - Path issues
   - Configuration file syntax errors

## Conclusion

The modular architecture makes the AWS Power User WSL Setup more maintainable, extensible, and user-friendly. By following the established patterns and best practices, you can easily add new components or modify existing ones to customize the setup for your specific needs.
