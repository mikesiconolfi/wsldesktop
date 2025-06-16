# Enhanced AWS Profile Switcher with Role-Based Selection

## Overview

Your AWS profile switcher has been enhanced with role-based selection capabilities, allowing you to easily switch between different AWS roles (Administrator, ReadOnly, PowerUser, etc.) within the same account or across multiple accounts.

## 🚀 New Features

### Role-Based Profile Switching
- **Interactive role selection** when switching profiles
- **Quick role switching** with predefined shortcuts
- **Role validation** and permission testing
- **Visual role indicators** in your terminal prompt

### Enhanced Commands

| Command | Description |
|---------|-------------|
| `awsp` | Interactive profile switcher with role selection |
| `awsrole` | Switch roles within current account |
| `awsquick <role>` | Quick switch to common roles (admin, readonly, poweruser, dev) |
| `awsperms` | Display current permissions and role information |
| `awsaccounts` | List all accounts and available roles |
| `awshelp` | Show detailed help |

### Quick Role Aliases

| Alias | Description |
|-------|-------------|
| `awsp-admin` | Switch to administrator role |
| `awsp-readonly` | Switch to read-only role |
| `awsp-poweruser` | Switch to power user role |
| `awsp-dev` | Switch to developer role |

## 🎨 Visual Enhancements

### Powerlevel10k Integration
Your terminal prompt now shows:
- **Current AWS profile name**
- **Role type with color coding**
- **Role-specific icons**
- **Account information**

### Role Color Coding
- 🔴 **Administrator**: Red (high privilege warning)
- 🟠 **PowerUser**: Orange (elevated privileges)
- 🟢 **ReadOnly**: Green (safe)
- 🔵 **Developer**: Blue (development)
- 🟣 **Security**: Purple (security focus)
- 🚨 **Production**: Red background (critical environment)
- 🟡 **Staging**: Yellow (caution)
- 🔵 **Test**: Cyan (testing)

## 📋 Setup Instructions

### 1. Run the Setup Script
```bash
cd ~/github/wsldesktop
./setup-enhanced-aws-switcher.sh
```

### 2. Configure AWS Profiles
Edit your `~/.aws/config` file with role-based profiles:

```ini
# Administrator Access
[profile company-admin]
sso_start_url = https://your-company.awsapps.com/start
sso_region = us-east-1
sso_account_id = 123456789012
sso_role_name = AdministratorAccess
region = us-east-1
output = json

# Read Only Access
[profile company-readonly]
sso_start_url = https://your-company.awsapps.com/start
sso_region = us-east-1
sso_account_id = 123456789012
sso_role_name = ReadOnlyAccess
region = us-east-1
output = json
```

### 3. Restart Your Shell
```bash
source ~/.zshrc
# or
exec zsh
```

## 🔧 Usage Examples

### Basic Profile Switching
```bash
# Interactive profile selection with role information
awsp

# Quick switch to admin role
awsquick admin

# Switch roles within current account
awsrole
```

### Permission Management
```bash
# Check current permissions
awsperms

# List all accounts and roles
awsaccounts

# Show current identity
awsid
```

### Service Shortcuts
```bash
# List EC2 instances
awsec2

# View CloudWatch logs interactively
awslogs

# List S3 buckets
awss3
```

## 🔒 Security Features

### Permission Validation
- **Automatic credential checking** before operations
- **Role permission testing** for common services
- **Session expiration handling** with automatic re-authentication

### Audit Trail
- **Role switch logging** for security compliance
- **Session validation** to ensure credentials are current
- **Permission level indicators** to prevent accidental high-privilege operations

## 📁 File Structure

```
~/
├── .aws_profile_switcher          # Main switcher functions
├── .aws/
│   ├── config                     # AWS profiles configuration
│   └── config.template            # Template for new setups
└── github/wsldesktop/
    ├── setup-enhanced-aws-switcher.sh      # Main setup script
    ├── p10k-aws-role-enhancement.sh        # P10K visual enhancements
    └── AWS_ROLE_SWITCHER_README.md         # This file
```

## 🛠️ Customization

### Adding New Roles
Edit `~/.aws_profile_switcher` and add your custom roles to the `AWS_ROLES` array:

```bash
declare -A AWS_ROLES=(
    ["YourCustomRole"]="Description of your custom role"
    # ... existing roles
)
```

### Custom Colors
Modify the P10K configuration in `~/.p10k.zsh` to change role colors:

```bash
typeset -g POWERLEVEL9K_AWS_YOURCUSTOMROLE_FOREGROUND=123
typeset -g POWERLEVEL9K_AWS_YOURCUSTOMROLE_BACKGROUND=456
```

## 🐛 Troubleshooting

### Common Issues

1. **Functions not available after setup**
   ```bash
   source ~/.aws_profile_switcher
   ```

2. **AWS profiles not showing**
   ```bash
   aws configure list-profiles
   ```

3. **SSO login issues**
   ```bash
   aws sso login --profile <profile-name>
   ```

4. **P10K not showing AWS info**
   ```bash
   source ~/.p10k.zsh
   ```

### Debug Commands
```bash
# Check if functions are loaded
type awsp

# Verify AWS CLI
aws --version

# Test profile switching
AWS_PROFILE=test-profile aws sts get-caller-identity
```

## 📚 Additional Resources

- [AWS CLI Configuration Guide](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html)
- [AWS SSO Setup](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html)
- [Powerlevel10k Configuration](https://github.com/romkatv/powerlevel10k)

## 🤝 Support

If you encounter issues:
1. Check the troubleshooting section above
2. Review the backup files in `~/.aws_switcher_backups/`
3. Run `awshelp` for command reference
4. Check AWS CLI and profile configuration

---

**Note**: Your original configurations have been backed up to `~/.aws_switcher_backups/` with timestamps.
