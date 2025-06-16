#!/bin/bash

# File Name: p10k-aws-role-enhancement.sh
# Relative Path: ~/github/wsldesktop/p10k-aws-role-enhancement.sh
# Purpose: Enhances Powerlevel10k AWS segment to display role information and account details.
# Detailed Overview: This script modifies the P10K configuration to show AWS role names, account information,
# and provides different colors for different role types (admin, readonly, poweruser, etc.). It creates
# role-based classes and customizes the AWS segment display for better visibility of current permissions.

# =============================================================================
# POWERLEVEL10K AWS ROLE ENHANCEMENT SCRIPT
# =============================================================================

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m' # No Color

print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

print_header() {
    echo
    print_color "$CYAN" "═══════════════════════════════════════════════════════════════"
    print_color "$WHITE" "  $1"
    print_color "$CYAN" "═══════════════════════════════════════════════════════════════"
}

print_success() { print_color "$GREEN" "✓ $1"; }
print_error() { print_color "$RED" "✗ $1"; }
print_warning() { print_color "$YELLOW" "⚠ $1"; }
print_info() { print_color "$BLUE" "ℹ $1"; }

# Path to p10k.zsh configuration file
P10K_CONFIG="$HOME/.p10k.zsh"

print_header "Powerlevel10k AWS Role Enhancement"

if [[ ! -f "$P10K_CONFIG" ]]; then
    print_error "$P10K_CONFIG not found"
    exit 1
fi

# Create a backup
BACKUP_FILE="$P10K_CONFIG.bak.$(date +%Y%m%d_%H%M%S)"
cp "$P10K_CONFIG" "$BACKUP_FILE"
print_success "Backup created: $BACKUP_FILE"

# Remove the command restriction to always show AWS
print_info "Removing AWS command restriction..."
if grep -q "POWERLEVEL9K_AWS_SHOW_ON_COMMAND=" "$P10K_CONFIG"; then
    sed -i '/typeset -g POWERLEVEL9K_AWS_SHOW_ON_COMMAND=/d' "$P10K_CONFIG"
    print_success "AWS command restriction removed"
else
    print_info "AWS command restriction not found"
fi

# Update AWS classes for role-based styling
print_info "Adding role-based AWS classes..."

# Find the AWS_CLASSES section and replace it
if grep -q "typeset -g POWERLEVEL9K_AWS_CLASSES=" "$P10K_CONFIG"; then
    # Create a temporary file with the new AWS classes configuration
    cat > /tmp/aws_classes_config << 'EOF'
  # Enhanced AWS classes for role-based styling
  typeset -g POWERLEVEL9K_AWS_CLASSES=(
      '*admin*'         ADMIN
      '*administrator*' ADMIN
      '*poweruser*'     POWERUSER
      '*power*'         POWERUSER
      '*readonly*'      READONLY
      '*read*'          READONLY
      '*dev*'           DEV
      '*developer*'     DEV
      '*security*'      SECURITY
      '*audit*'         SECURITY
      '*billing*'       BILLING
      '*dba*'           DBA
      '*database*'      DBA
      '*network*'       NETWORK
      '*datascience*'   DATASCIENCE
      '*data*'          DATASCIENCE
      '*prod*'          PROD
      '*production*'    PROD
      '*staging*'       STAGING
      '*test*'          TEST
      '*'               DEFAULT)
EOF
    
    # Replace the existing AWS_CLASSES section
    sed -i '/typeset -g POWERLEVEL9K_AWS_CLASSES=/,/DEFAULT)/c\
  # Enhanced AWS classes for role-based styling\
  typeset -g POWERLEVEL9K_AWS_CLASSES=(\
      '\''*admin*'\''         ADMIN\
      '\''*administrator*'\'' ADMIN\
      '\''*poweruser*'\''     POWERUSER\
      '\''*power*'\''         POWERUSER\
      '\''*readonly*'\''      READONLY\
      '\''*read*'\''          READONLY\
      '\''*dev*'\''           DEV\
      '\''*developer*'\''     DEV\
      '\''*security*'\''      SECURITY\
      '\''*audit*'\''         SECURITY\
      '\''*billing*'\''       BILLING\
      '\''*dba*'\''           DBA\
      '\''*database*'\''      DBA\
      '\''*network*'\''       NETWORK\
      '\''*datascience*'\''   DATASCIENCE\
      '\''*data*'\''          DATASCIENCE\
      '\''*prod*'\''          PROD\
      '\''*production*'\''    PROD\
      '\''*staging*'\''       STAGING\
      '\''*test*'\''          TEST\
      '\''*'\''               DEFAULT)' "$P10K_CONFIG"
    
    print_success "AWS classes updated with role-based patterns"
else
    print_warning "AWS_CLASSES section not found, adding new section"
    # Add the AWS classes section before the DEFAULT foreground setting
    sed -i '/typeset -g POWERLEVEL9K_AWS_DEFAULT_FOREGROUND=/i\
  # Enhanced AWS classes for role-based styling\
  typeset -g POWERLEVEL9K_AWS_CLASSES=(\
      '\''*admin*'\''         ADMIN\
      '\''*administrator*'\'' ADMIN\
      '\''*poweruser*'\''     POWERUSER\
      '\''*power*'\''         POWERUSER\
      '\''*readonly*'\''      READONLY\
      '\''*read*'\''          READONLY\
      '\''*dev*'\''           DEV\
      '\''*developer*'\''     DEV\
      '\''*security*'\''      SECURITY\
      '\''*audit*'\''         SECURITY\
      '\''*billing*'\''       BILLING\
      '\''*dba*'\''           DBA\
      '\''*database*'\''      DBA\
      '\''*network*'\''       NETWORK\
      '\''*datascience*'\''   DATASCIENCE\
      '\''*data*'\''          DATASCIENCE\
      '\''*prod*'\''          PROD\
      '\''*production*'\''    PROD\
      '\''*staging*'\''       STAGING\
      '\''*test*'\''          TEST\
      '\''*'\''               DEFAULT)\
' "$P10K_CONFIG"
fi

# Add role-specific color configurations
print_info "Adding role-specific colors and icons..."

# Add the role-specific configurations after the AWS_CLASSES section
cat >> /tmp/aws_role_config << 'EOF'

  # Role-specific AWS styling
  # Administrator - Red (high privilege warning)
  typeset -g POWERLEVEL9K_AWS_ADMIN_FOREGROUND=196
  typeset -g POWERLEVEL9K_AWS_ADMIN_BACKGROUND=52
  typeset -g POWERLEVEL9K_AWS_ADMIN_VISUAL_IDENTIFIER_EXPANSION='👑'
  
  # PowerUser - Orange (elevated privileges)
  typeset -g POWERLEVEL9K_AWS_POWERUSER_FOREGROUND=214
  typeset -g POWERLEVEL9K_AWS_POWERUSER_BACKGROUND=94
  typeset -g POWERLEVEL9K_AWS_POWERUSER_VISUAL_IDENTIFIER_EXPANSION='⚡'
  
  # ReadOnly - Green (safe)
  typeset -g POWERLEVEL9K_AWS_READONLY_FOREGROUND=46
  typeset -g POWERLEVEL9K_AWS_READONLY_BACKGROUND=22
  typeset -g POWERLEVEL9K_AWS_READONLY_VISUAL_IDENTIFIER_EXPANSION='👁'
  
  # Developer - Blue (development)
  typeset -g POWERLEVEL9K_AWS_DEV_FOREGROUND=39
  typeset -g POWERLEVEL9K_AWS_DEV_BACKGROUND=24
  typeset -g POWERLEVEL9K_AWS_DEV_VISUAL_IDENTIFIER_EXPANSION='🔧'
  
  # Security - Purple (security focus)
  typeset -g POWERLEVEL9K_AWS_SECURITY_FOREGROUND=129
  typeset -g POWERLEVEL9K_AWS_SECURITY_BACKGROUND=53
  typeset -g POWERLEVEL9K_AWS_SECURITY_VISUAL_IDENTIFIER_EXPANSION='🔒'
  
  # Production - Red background (critical environment)
  typeset -g POWERLEVEL9K_AWS_PROD_FOREGROUND=15
  typeset -g POWERLEVEL9K_AWS_PROD_BACKGROUND=124
  typeset -g POWERLEVEL9K_AWS_PROD_VISUAL_IDENTIFIER_EXPANSION='🚨'
  
  # Staging - Yellow (caution)
  typeset -g POWERLEVEL9K_AWS_STAGING_FOREGROUND=0
  typeset -g POWERLEVEL9K_AWS_STAGING_BACKGROUND=220
  typeset -g POWERLEVEL9K_AWS_STAGING_VISUAL_IDENTIFIER_EXPANSION='⚠️'
  
  # Test - Cyan (testing)
  typeset -g POWERLEVEL9K_AWS_TEST_FOREGROUND=0
  typeset -g POWERLEVEL9K_AWS_TEST_BACKGROUND=51
  typeset -g POWERLEVEL9K_AWS_TEST_VISUAL_IDENTIFIER_EXPANSION='🧪'
  
  # Billing - Gold (money-related)
  typeset -g POWERLEVEL9K_AWS_BILLING_FOREGROUND=0
  typeset -g POWERLEVEL9K_AWS_BILLING_BACKGROUND=178
  typeset -g POWERLEVEL9K_AWS_BILLING_VISUAL_IDENTIFIER_EXPANSION='💰'
  
  # DBA - Magenta (database)
  typeset -g POWERLEVEL9K_AWS_DBA_FOREGROUND=15
  typeset -g POWERLEVEL9K_AWS_DBA_BACKGROUND=90
  typeset -g POWERLEVEL9K_AWS_DBA_VISUAL_IDENTIFIER_EXPANSION='🗄️'
  
  # Network - Light Blue (networking)
  typeset -g POWERLEVEL9K_AWS_NETWORK_FOREGROUND=0
  typeset -g POWERLEVEL9K_AWS_NETWORK_BACKGROUND=117
  typeset -g POWERLEVEL9K_AWS_NETWORK_VISUAL_IDENTIFIER_EXPANSION='🌐'
  
  # Data Science - Pink (analytics)
  typeset -g POWERLEVEL9K_AWS_DATASCIENCE_FOREGROUND=15
  typeset -g POWERLEVEL9K_AWS_DATASCIENCE_BACKGROUND=162
  typeset -g POWERLEVEL9K_AWS_DATASCIENCE_VISUAL_IDENTIFIER_EXPANSION='📊'
EOF

# Insert the role-specific configurations after the AWS_CLASSES section
sed -i '/typeset -g POWERLEVEL9K_AWS_DEFAULT_FOREGROUND=/r /tmp/aws_role_config' "$P10K_CONFIG"

# Update the AWS content expansion to show more information
print_info "Updating AWS content expansion to show role information..."

# Create a function to extract role information
cat > /tmp/aws_content_function << 'EOF'

  # Enhanced AWS content expansion with role extraction
  # This function extracts role information from the profile name
  function _p9k_aws_role_info() {
    local profile="${P9K_AWS_PROFILE}"
    local role=""
    
    # Extract role from profile name
    case "$profile" in
      *admin*|*administrator*) role="[ADMIN]" ;;
      *poweruser*|*power*) role="[POWER]" ;;
      *readonly*|*read*) role="[READ]" ;;
      *dev*|*developer*) role="[DEV]" ;;
      *security*|*audit*) role="[SEC]" ;;
      *billing*) role="[BILL]" ;;
      *dba*|*database*) role="[DBA]" ;;
      *network*) role="[NET]" ;;
      *datascience*|*data*) role="[DATA]" ;;
      *prod*|*production*) role="[PROD]" ;;
      *staging*) role="[STAGE]" ;;
      *test*) role="[TEST]" ;;
      *) role="" ;;
    esac
    
    echo "$role"
  }
EOF

# Add the function before the content expansion
sed -i '/typeset -g POWERLEVEL9K_AWS_CONTENT_EXPANSION=/i\
  # Enhanced AWS content expansion with role extraction\
  # This function extracts role information from the profile name\
  function _p9k_aws_role_info() {\
    local profile="${P9K_AWS_PROFILE}"\
    local role=""\
    \
    # Extract role from profile name\
    case "$profile" in\
      *admin*|*administrator*) role="[ADMIN]" ;;\
      *poweruser*|*power*) role="[POWER]" ;;\
      *readonly*|*read*) role="[READ]" ;;\
      *dev*|*developer*) role="[DEV]" ;;\
      *security*|*audit*) role="[SEC]" ;;\
      *billing*) role="[BILL]" ;;\
      *dba*|*database*) role="[DBA]" ;;\
      *network*) role="[NET]" ;;\
      *datascience*|*data*) role="[DATA]" ;;\
      *prod*|*production*) role="[PROD]" ;;\
      *staging*) role="[STAGE]" ;;\
      *test*) role="[TEST]" ;;\
      *) role="" ;;\
    esac\
    \
    echo "$role"\
  }' "$P10K_CONFIG"

# Update the content expansion to use the role information
sed -i 's/typeset -g POWERLEVEL9K_AWS_CONTENT_EXPANSION=.*/typeset -g POWERLEVEL9K_AWS_CONTENT_EXPANSION='\''${P9K_AWS_PROFILE\/\/\\%\/%%}$(_p9k_aws_role_info)${P9K_AWS_REGION:+ ${P9K_AWS_REGION\/\/\\%\/%%}}'\''/' "$P10K_CONFIG"

# Clean up temporary files
rm -f /tmp/aws_classes_config /tmp/aws_role_config /tmp/aws_content_function

print_success "P10K AWS enhancement completed!"

print_header "Summary of Changes"
print_info "✓ Removed AWS command restriction (always show AWS segment)"
print_info "✓ Added role-based AWS profile classes"
print_info "✓ Added role-specific colors and icons:"
print_info "  - Administrator: Red with crown icon 👑"
print_info "  - PowerUser: Orange with lightning icon ⚡"
print_info "  - ReadOnly: Green with eye icon 👁"
print_info "  - Developer: Blue with wrench icon 🔧"
print_info "  - Security: Purple with lock icon 🔒"
print_info "  - Production: Red background with alert icon 🚨"
print_info "  - Staging: Yellow with warning icon ⚠️"
print_info "  - Test: Cyan with test tube icon 🧪"
print_info "✓ Enhanced content expansion to show role information"

echo
print_warning "To apply changes, restart your shell or run:"
print_info "source ~/.p10k.zsh"

echo
print_info "Your original configuration has been backed up to:"
print_info "$BACKUP_FILE"

echo
print_header "Testing Your Setup"
print_info "After restarting your shell, try these commands:"
print_info "1. awsp                    # Select a profile"
print_info "2. awsrole                 # Switch roles"
print_info "3. awsquick admin          # Quick switch to admin role"
print_info "4. awsperms                # Check current permissions"

echo
print_success "Enhancement complete! Your AWS segment will now show role information with color coding."
