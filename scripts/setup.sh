#!/bin/bash

# ============================================================================
# create-hildy-app Setup Script
# ============================================================================
# This script automates the setup process after cloning the template.
# It creates Cloudflare resources (D1, R2), generates secrets, and
# configures all necessary files.
# ============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Print functions
print_header() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

print_step() {
    echo -e "${CYAN}▸${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# ============================================================================
# Dependency Checks
# ============================================================================

check_dependencies() {
    print_header "Checking Dependencies"
    
    # Check for jq
    if ! command -v jq &> /dev/null; then
        print_error "jq is required but not installed."
        echo -e "  Install it with: ${CYAN}brew install jq${NC}"
        exit 1
    fi
    print_success "jq is installed"
    
    # Check for openssl
    if ! command -v openssl &> /dev/null; then
        print_error "openssl is required but not installed."
        exit 1
    fi
    print_success "openssl is installed"
    
    # Check for pnpm
    if ! command -v pnpm &> /dev/null; then
        print_error "pnpm is required but not installed."
        echo -e "  Install it with: ${CYAN}npm install -g pnpm${NC}"
        exit 1
    fi
    print_success "pnpm is installed"
}

# ============================================================================
# App Name Detection
# ============================================================================

detect_app_name() {
    print_header "App Configuration"
    
    # Get the folder name as default app name
    FOLDER_NAME=$(basename "$(pwd)")
    
    # Convert to lowercase and replace spaces/underscores with hyphens
    DEFAULT_APP_NAME=$(echo "$FOLDER_NAME" | tr '[:upper:]' '[:lower:]' | tr ' _' '-')
    
    print_step "Detected folder name: ${CYAN}$FOLDER_NAME${NC}"
    echo ""
    read -p "Enter app name [$DEFAULT_APP_NAME]: " APP_NAME
    APP_NAME=${APP_NAME:-$DEFAULT_APP_NAME}
    
    # Sanitize app name (lowercase, hyphens only)
    APP_NAME=$(echo "$APP_NAME" | tr '[:upper:]' '[:lower:]' | tr ' _' '-' | sed 's/[^a-z0-9-]//g')
    
    print_success "Using app name: ${GREEN}$APP_NAME${NC}"
    
    # Derived names
    DB_NAME="${APP_NAME}-db"
    BUCKET_NAME="${APP_NAME}-bucket"
    
    echo ""
    print_step "D1 Database name: ${CYAN}$DB_NAME${NC}"
    print_step "R2 Bucket name: ${CYAN}$BUCKET_NAME${NC}"
}

# ============================================================================
# Wrangler Authentication
# ============================================================================

check_wrangler_auth() {
    print_header "Cloudflare Authentication"
    
    # Check if wrangler is available
    if ! command -v npx &> /dev/null; then
        print_error "npx is required but not installed."
        exit 1
    fi
    
    print_step "Checking Wrangler authentication..."
    
    # Try to get whoami info
    WHOAMI_OUTPUT=$(npx wrangler whoami 2>&1) || true
    
    if echo "$WHOAMI_OUTPUT" | grep -q "Not logged in"; then
        print_warning "You are not logged in to Cloudflare."
        echo ""
        read -p "Would you like to login now? (Y/n): " LOGIN_CHOICE
        LOGIN_CHOICE=${LOGIN_CHOICE:-Y}
        
        if [[ "$LOGIN_CHOICE" =~ ^[Yy]$ ]]; then
            npx wrangler login
            WHOAMI_OUTPUT=$(npx wrangler whoami 2>&1)
        else
            print_error "Wrangler login is required to continue."
            exit 1
        fi
    fi
    
    print_success "Logged in to Cloudflare"
    
    # Extract account ID
    # The whoami output contains account info, we need to parse it
    ACCOUNT_ID=$(echo "$WHOAMI_OUTPUT" | grep -oE '[a-f0-9]{32}' | head -1)
    
    if [ -z "$ACCOUNT_ID" ]; then
        print_warning "Could not auto-detect account ID."
        echo ""
        read -p "Please enter your Cloudflare Account ID: " ACCOUNT_ID
    fi
    
    print_success "Account ID: ${GREEN}${ACCOUNT_ID:0:8}...${NC}"
}

# ============================================================================
# Create D1 Database
# ============================================================================

create_d1_database() {
    print_header "Creating D1 Database"
    
    print_step "Creating database: ${CYAN}$DB_NAME${NC}"
    
    # Create D1 database with JSON output
    D1_OUTPUT=$(npx wrangler d1 create "$DB_NAME" --json 2>&1) || {
        if echo "$D1_OUTPUT" | grep -q "already exists"; then
            print_warning "Database '$DB_NAME' already exists."
            echo ""
            read -p "Enter the existing database ID (or press Enter to skip): " DATABASE_ID
            if [ -z "$DATABASE_ID" ]; then
                print_error "Database ID is required."
                exit 1
            fi
            return
        else
            print_error "Failed to create D1 database:"
            echo "$D1_OUTPUT"
            exit 1
        fi
    }
    
    # Parse the database ID from JSON output
    DATABASE_ID=$(echo "$D1_OUTPUT" | jq -r '.uuid // .id // empty')
    
    if [ -z "$DATABASE_ID" ]; then
        print_error "Failed to parse database ID from output:"
        echo "$D1_OUTPUT"
        exit 1
    fi
    
    print_success "Database created with ID: ${GREEN}${DATABASE_ID:0:8}...${NC}"
}

# ============================================================================
# Create R2 Bucket
# ============================================================================

create_r2_bucket() {
    print_header "Creating R2 Bucket"
    
    print_step "Creating bucket: ${CYAN}$BUCKET_NAME${NC}"
    
    R2_OUTPUT=$(npx wrangler r2 bucket create "$BUCKET_NAME" 2>&1) || {
        if echo "$R2_OUTPUT" | grep -q "already exists"; then
            print_warning "Bucket '$BUCKET_NAME' already exists. Continuing..."
            return
        else
            print_error "Failed to create R2 bucket:"
            echo "$R2_OUTPUT"
            exit 1
        fi
    }
    
    print_success "R2 bucket created successfully"
}

# ============================================================================
# Generate Secrets
# ============================================================================

generate_secrets() {
    print_header "Generating Secrets"
    
    print_step "Generating BetterAuth secret..."
    BETTER_AUTH_SECRET=$(openssl rand -base64 32)
    print_success "Generated 32-byte secret"
}

# ============================================================================
# Update Configuration Files
# ============================================================================

update_package_json() {
    print_header "Updating package.json"
    
    # Update root package.json
    print_step "Updating root package.json..."
    
    if [ -f "package.json" ]; then
        # Update the name field
        jq --arg name "$APP_NAME" '.name = $name' package.json > package.json.tmp
        mv package.json.tmp package.json
        print_success "Updated root package.json name to '$APP_NAME'"
    fi
    
    # Update D1 create script to use new name
    if [ -f "package.json" ]; then
        jq --arg db "$DB_NAME" '.scripts["d1:create"] = "wrangler d1 create " + $db' package.json > package.json.tmp
        mv package.json.tmp package.json
        
        jq --arg db "$DB_NAME" '.scripts["d1:migrations"] = "wrangler d1 migrations apply " + $db' package.json > package.json.tmp
        mv package.json.tmp package.json
        
        jq --arg bucket "$BUCKET_NAME" '.scripts["r2:create"] = "wrangler r2 bucket create " + $bucket' package.json > package.json.tmp
        mv package.json.tmp package.json
        
        print_success "Updated Cloudflare resource scripts"
    fi
}

update_wrangler_toml() {
    print_header "Updating wrangler.toml"
    
    if [ -f "wrangler.toml" ]; then
        print_step "Updating wrangler.toml with your configuration..."
        
        # Update app name
        sed -i.bak "s/^name = .*/name = \"$APP_NAME\"/" wrangler.toml
        
        # Update database name and ID
        sed -i.bak "s/database_name = .*/database_name = \"$DB_NAME\"/" wrangler.toml
        sed -i.bak "s/database_id = .*/database_id = \"$DATABASE_ID\"/" wrangler.toml
        
        # Update bucket name
        sed -i.bak "s/bucket_name = .*/bucket_name = \"$BUCKET_NAME\"/" wrangler.toml
        
        # Remove backup file
        rm -f wrangler.toml.bak
        
        print_success "Updated wrangler.toml"
    else
        print_error "wrangler.toml not found!"
        exit 1
    fi
}

create_env_file() {
    print_header "Creating Environment File"
    
    ENV_FILE="apps/website/.env"
    ENV_EXAMPLE="apps/website/.env.example"
    
    if [ -f "$ENV_FILE" ]; then
        print_warning ".env file already exists."
        read -p "Overwrite? (y/N): " OVERWRITE
        if [[ ! "$OVERWRITE" =~ ^[Yy]$ ]]; then
            print_step "Skipping .env creation"
            return
        fi
    fi
    
    print_step "Creating .env file..."
    
    cat > "$ENV_FILE" << EOF
# Environment variables for Cloudflare Workers deployment
# Generated by setup.sh on $(date)

# Cloudflare D1 Database (for Drizzle migrations)
CLOUDFLARE_ACCOUNT_ID="$ACCOUNT_ID"
CLOUDFLARE_D1_DATABASE_ID="$DATABASE_ID"
CLOUDFLARE_D1_TOKEN="YOUR_D1_API_TOKEN_HERE"

# BetterAuth
BETTER_AUTH_SECRET="$BETTER_AUTH_SECRET"
BETTER_AUTH_URL="http://localhost:3000"

# App Environment
NODE_ENV="development"
ENVIRONMENT="development"
EOF
    
    print_success "Created .env file"
    
    # Provide instructions for the API token
    echo ""
    print_warning "You still need to create a Cloudflare API token for D1 migrations."
    echo ""
    echo -e "  ${CYAN}Steps to create an API token:${NC}"
    echo "  1. Go to https://dash.cloudflare.com/profile/api-tokens"
    echo "  2. Click 'Create Token'"
    echo "  3. Use the 'Edit Cloudflare Workers' template OR create custom with:"
    echo "     - Account > D1 > Edit"
    echo "  4. Copy the token and update CLOUDFLARE_D1_TOKEN in apps/website/.env"
    echo ""
}

# ============================================================================
# Final Steps
# ============================================================================

run_final_steps() {
    print_header "Final Steps"
    
    # Ask if user wants to install dependencies
    read -p "Install dependencies with pnpm? (Y/n): " INSTALL_DEPS
    INSTALL_DEPS=${INSTALL_DEPS:-Y}
    
    if [[ "$INSTALL_DEPS" =~ ^[Yy]$ ]]; then
        print_step "Installing dependencies..."
        pnpm install
        print_success "Dependencies installed"
    fi
    
    # Ask if user wants to push schema
    echo ""
    print_warning "To push the database schema, you need to add the D1 API token first!"
    read -p "Push database schema now? (y/N): " PUSH_SCHEMA
    
    if [[ "$PUSH_SCHEMA" =~ ^[Yy]$ ]]; then
        print_step "Pushing schema to D1..."
        pnpm db:push
        print_success "Schema pushed to D1"
    else
        echo ""
        echo -e "  Run ${CYAN}pnpm db:push${NC} later after adding your D1 API token."
    fi
}

print_summary() {
    print_header "Setup Complete! 🎉"
    
    echo -e "Your app ${GREEN}$APP_NAME${NC} is ready to go!"
    echo ""
    echo -e "${CYAN}Resources created:${NC}"
    echo "  • D1 Database: $DB_NAME ($DATABASE_ID)"
    echo "  • R2 Bucket: $BUCKET_NAME"
    echo ""
    echo -e "${CYAN}Files updated:${NC}"
    echo "  • package.json"
    echo "  • wrangler.toml"
    echo "  • apps/website/.env"
    echo ""
    echo -e "${CYAN}Next steps:${NC}"
    echo "  1. Add your D1 API token to apps/website/.env"
    echo "  2. Run: pnpm db:push"
    echo "  3. Run: pnpm dev"
    echo ""
    echo -e "Happy coding! 🚀"
}

# ============================================================================
# Main
# ============================================================================

main() {
    print_header "🚀 create-hildy-app Setup"
    echo "This script will set up your Cloudflare resources and configure your app."
    echo ""
    
    check_dependencies
    detect_app_name
    check_wrangler_auth
    create_d1_database
    create_r2_bucket
    generate_secrets
    update_package_json
    update_wrangler_toml
    create_env_file
    run_final_steps
    print_summary
}

main "$@"
