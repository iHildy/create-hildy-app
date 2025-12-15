#!/bin/bash

# ============================================================================
# create-hildy-app Setup Script
# ============================================================================
# This script automates the setup process after cloning the template.
# It creates Cloudflare resources (D1, R2), generates secrets, and
# configures all necessary files.
# ============================================================================

set -e

# Global status flags
D1_CREATED=false
R2_CREATED=false

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

# Global flags
GH_AVAILABLE=false
GITHUB_REPO=""

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
    
    # Check for GitHub CLI (optional but enables extra features)
    if ! command -v gh &> /dev/null; then
        print_warning "GitHub CLI (gh) is not installed. Some features will be skipped."
        echo -e "  Install it with: ${CYAN}brew install gh${NC}"
        GH_AVAILABLE=false
    else
        print_success "GitHub CLI is installed"
        GH_AVAILABLE=true
    fi
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
    
    # Extract all account IDs
    # We grab all 32-char hex strings
    ALL_IDS=$(echo "$WHOAMI_OUTPUT" | grep -oE '[a-f0-9]{32}')
    
    # Convert newline-separated string to array
    # usage of tr to ensure spaces for array conversion if needed, but default split on whitespace works
    ACCOUNT_IDS=($ALL_IDS)
    ACCOUNT_COUNT=${#ACCOUNT_IDS[@]}
    
    if [ "$ACCOUNT_COUNT" -gt 1 ]; then
        print_warning "Multiple Cloudflare accounts detected."
        echo "Please select which account you want to use for this project:"
        echo ""
        
        # Get the lines containing IDs to show names/details
        # We assume the order of IDs in grep -oE matches the order of lines in grep -E
        ACCOUNT_LINES=$(echo "$WHOAMI_OUTPUT" | grep -E '[a-f0-9]{32}')
        
        # Read lines into index-able format
        i=1
        while IFS= read -r line; do
            # strip leading whitespace
            CLEAN_LINE=$(echo "$line" | sed 's/^[ \t]*//')
            echo "  $i) $CLEAN_LINE"
            ((i++))
        done <<< "$ACCOUNT_LINES"
        
        echo ""
        read -p "Enter number (1-$ACCOUNT_COUNT): " SELECTION
        
        # Validate selection
        if [[ "$SELECTION" =~ ^[0-9]+$ ]] && [ "$SELECTION" -ge 1 ] && [ "$SELECTION" -le "$ACCOUNT_COUNT" ]; then
            INDEX=$((SELECTION-1))
            ACCOUNT_ID=${ACCOUNT_IDS[$INDEX]}
        else
            print_warning "Invalid selection. Defaulting to first account."
            ACCOUNT_ID=${ACCOUNT_IDS[0]}
        fi
        
    elif [ "$ACCOUNT_COUNT" -eq 1 ]; then
        ACCOUNT_ID=${ACCOUNT_IDS[0]}
    else
        print_warning "Could not auto-detect account ID."
        echo ""
        read -p "Please enter your Cloudflare Account ID: " ACCOUNT_ID
    fi
    
    print_success "Account ID: ${GREEN}${ACCOUNT_ID:0:8}...${NC}"
    export CLOUDFLARE_ACCOUNT_ID="$ACCOUNT_ID"
}

# ============================================================================
# GitHub Authentication & Setup
# ============================================================================

check_github_auth() {
    if [ "$GH_AVAILABLE" = false ]; then
        return
    fi
    
    print_header "GitHub Authentication"
    
    if ! gh auth status &> /dev/null; then
        print_warning "Not logged in to GitHub CLI."
        echo ""
        read -p "Would you like to login now? (Y/n): " GH_LOGIN
        GH_LOGIN=${GH_LOGIN:-Y}
        
        if [[ "$GH_LOGIN" =~ ^[Yy]$ ]]; then
            gh auth login
        else
            print_warning "Skipping GitHub features (repo creation, Slack webhook)."
            GH_AVAILABLE=false
            return
        fi
    fi
    
    print_success "Authenticated to GitHub"
    
    # Detect repo from git remote
    if git remote get-url origin &> /dev/null; then
        ORIGIN_URL=$(git remote get-url origin)
        GITHUB_REPO=$(echo "$ORIGIN_URL" | sed 's/.*github.com[:/]\(.*\)\.git/\1/' | sed 's/.*github.com[:/]\(.*\)/\1/')
        
        if [ -n "$GITHUB_REPO" ]; then
            print_success "Detected repo: $GITHUB_REPO"
        fi
    fi
}

setup_git_repo() {
    print_header "Git Repository Setup"
    
    if [ -d ".git" ]; then
        # Check if origin points to the template repo
        ORIGIN_URL=$(git remote get-url origin 2>/dev/null || echo "")
        
        if [[ "$ORIGIN_URL" == *"create-hildy-app"* ]] || [[ "$ORIGIN_URL" == *"iHildy/create-hildy-app"* ]]; then
            print_warning "Git origin still points to the template repo."
            echo ""
            read -p "Remove template origin? (Y/n): " REMOVE_ORIGIN
            REMOVE_ORIGIN=${REMOVE_ORIGIN:-Y}
            
            if [[ "$REMOVE_ORIGIN" =~ ^[Yy]$ ]]; then
                git remote remove origin
                print_success "Removed template origin"
                GITHUB_REPO=""
            fi
        else
            print_success "Git repository already configured"
        fi
    else
        read -p "Initialize a new git repository? (Y/n): " INIT_GIT
        INIT_GIT=${INIT_GIT:-Y}
        
        if [[ "$INIT_GIT" =~ ^[Yy]$ ]]; then
            git init
            print_success "Initialized git repository"
        fi
    fi
}

create_github_repo() {
    if [ "$GH_AVAILABLE" = false ]; then
        return
    fi
    
    # Check if we already have a remote
    if git remote get-url origin &> /dev/null; then
        return
    fi
    
    print_header "GitHub Repository Creation"
    
    echo "You don't have a GitHub remote configured."
    read -p "Create a new GitHub repository for this project? (Y/n): " CREATE_REPO
    CREATE_REPO=${CREATE_REPO:-Y}
    
    if [[ ! "$CREATE_REPO" =~ ^[Yy]$ ]]; then
        print_step "Skipping GitHub repo creation"
        return
    fi
    
    echo ""
    read -p "Repository visibility (public/private) [private]: " VISIBILITY
    VISIBILITY=${VISIBILITY:-private}
    
    print_step "Creating GitHub repository..."
    
    if gh repo create "$APP_NAME" --"$VISIBILITY" --source=. --remote=origin; then
        print_success "Created GitHub repo: $APP_NAME"
        GITHUB_REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
        print_success "Remote set to: $GITHUB_REPO"
    else
        print_warning "Failed to create GitHub repo. You can do this manually later."
    fi
}

setup_slack_webhook() {
    if [ "$GH_AVAILABLE" = false ] || [ -z "$GITHUB_REPO" ]; then
        if [ -z "$GITHUB_REPO" ]; then
            print_step "Skipping Slack setup (no GitHub remote configured)"
        fi
        return
    fi
    
    print_header "Slack Deploy Notifications"
    
    echo "This template includes GitHub Actions for Slack deploy notifications."
    echo "When enabled, you'll get Slack messages on every deploy success/failure."
    echo ""
    read -p "Set up Slack notifications now? (y/N): " SETUP_SLACK
    
    if [[ ! "$SETUP_SLACK" =~ ^[Yy]$ ]]; then
        print_step "Skipping Slack setup (you can add the secret later in GitHub settings)"
        return
    fi
    
    echo ""
    echo -e "${CYAN}To get a Slack webhook URL:${NC}"
    echo "  1. Go to https://api.slack.com/apps"
    echo "  2. Create New App → From scratch"
    echo "  3. Enable 'Incoming Webhooks' under Features"
    echo "  4. Click 'Add New Webhook to Workspace'"
    echo "  5. Choose a channel and copy the webhook URL"
    echo ""
    read -p "Paste your Slack webhook URL (or press Enter to skip): " SLACK_WEBHOOK_URL
    
    if [ -z "$SLACK_WEBHOOK_URL" ]; then
        print_step "Skipping (you can add SLACK_WEBHOOK_URL secret in GitHub settings later)"
        return
    fi
    
    # Validate URL format
    if [[ ! "$SLACK_WEBHOOK_URL" =~ ^https://hooks\.slack\.com/ ]]; then
        print_warning "URL doesn't look like a Slack webhook. Skipping."
        return
    fi
    
    print_step "Setting SLACK_WEBHOOK_URL secret in GitHub..."
    
    if echo "$SLACK_WEBHOOK_URL" | gh secret set SLACK_WEBHOOK_URL --repo "$GITHUB_REPO"; then
        print_success "Slack webhook configured! You'll get notifications on deploys."
    else
        print_error "Failed to set secret. You can add it manually in GitHub repo settings."
    fi
}

# ============================================================================
# Create D1 Database
# ============================================================================

create_d1_database() {
    print_header "Creating D1 Database"
    
    read -p "Setup D1 database? (Y/n): " SETUP_D1
    SETUP_D1=${SETUP_D1:-Y}

    if [[ ! "$SETUP_D1" =~ ^[Yy]$ ]]; then
        print_step "Skipping D1 database setup."
        return
    fi
    
    print_step "Creating database: ${CYAN}$DB_NAME${NC}"
    
    # Create D1 database
    D1_OUTPUT=$(npx wrangler d1 create "$DB_NAME" 2>&1) || {
        if echo "$D1_OUTPUT" | grep -q "already exists"; then
            print_warning "Database '$DB_NAME' already exists."
            echo ""
            read -p "Enter the existing database ID (or press Enter to skip): " DATABASE_ID
            if [ -z "$DATABASE_ID" ]; then
                print_warning "Skipping D1 database setup. You will need to configure it manually."
                return
            fi
            return
        else
            print_error "Failed to create D1 database:"
            echo "$D1_OUTPUT"
            exit 1
        fi
    }
    
    # Parse the database ID from output (looking for UUID pattern)
    DATABASE_ID=$(echo "$D1_OUTPUT" | grep -oE '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}' | head -1)
    
    if [ -z "$DATABASE_ID" ]; then
        print_error "Failed to parse database ID from output:"
        echo "$D1_OUTPUT"
        exit 1
    fi
    
    print_success "Database created with ID: ${GREEN}${DATABASE_ID:0:8}...${NC}"
    D1_CREATED=true
}

# ============================================================================
# Create R2 Bucket
# ============================================================================

create_r2_bucket() {
    print_header "Creating R2 Bucket"
    
    read -p "Setup R2 bucket? (Y/n): " SETUP_R2
    SETUP_R2=${SETUP_R2:-Y}

    if [[ ! "$SETUP_R2" =~ ^[Yy]$ ]]; then
        print_step "Skipping R2 bucket setup."
        return
    fi
    
    print_step "Creating bucket: ${CYAN}$BUCKET_NAME${NC}"
    
    while true; do
        if R2_OUTPUT=$(npx wrangler r2 bucket create "$BUCKET_NAME" 2>&1); then
            print_success "R2 bucket created successfully"
            R2_CREATED=true
            break
        else
            # Errors occurred
            if echo "$R2_OUTPUT" | grep -q "already exists"; then
                print_warning "Bucket '$BUCKET_NAME' already exists. Continuing..."
                R2_CREATED=true
                break
            fi
            
            # Check for R2 not enabled (code 10042)
            if echo "$R2_OUTPUT" | grep -q "10042"; then
                print_warning "R2 is not enabled on this account."
                DASH_URL="https://dash.cloudflare.com/$ACCOUNT_ID/r2/overview"
                echo -e "  Enable it here: ${CYAN}$DASH_URL${NC}"
                
                if command -v open &> /dev/null; then
                    open "$DASH_URL"
                elif command -v xdg-open &> /dev/null; then
                    xdg-open "$DASH_URL"
                fi
                
                echo ""
                read -p "Press Enter to retry after enabling R2 (or type 'n' to skip): " REPLY
                if [[ "$REPLY" =~ ^[Nn]$ ]]; then
                    print_warning "Skipping R2 setup."
                    break
                fi
                print_step "Retrying..."
                continue
            fi
            
            # Fallback for other errors
            print_error "Failed to create R2 bucket:"
            echo "$R2_OUTPUT"
            exit 1
        fi
    done
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
        
        if [ "$D1_CREATED" = true ]; then
            # Update database name and ID
            sed -i.bak "s/database_name = .*/database_name = \"$DB_NAME\"/" wrangler.toml
            sed -i.bak "s/database_id = .*/database_id = \"$DATABASE_ID\"/" wrangler.toml
        fi
        
        if [ "$R2_CREATED" = true ]; then
            # Update bucket name
            sed -i.bak "s/bucket_name = .*/bucket_name = \"$BUCKET_NAME\"/" wrangler.toml
        fi
        
        # Remove backup file
        rm -f wrangler.toml.bak
        
        print_success "Updated wrangler.toml"
    else
        print_error "wrangler.toml not found!"
        exit 1
    fi
}

update_slack_workflow() {
    SLACK_WORKFLOW=".github/workflows/slack-deploy-notify.yml"
    
    if [ -f "$SLACK_WORKFLOW" ]; then
        print_step "Updating Slack deploy workflow..."
        
        # Update CLOUDFLARE_PROJECT
        sed -i.bak "s/CLOUDFLARE_PROJECT: .*/CLOUDFLARE_PROJECT: $APP_NAME/" "$SLACK_WORKFLOW"
        
        # Update CLOUDFLARE_SUBDOMAIN
        sed -i.bak "s/CLOUDFLARE_SUBDOMAIN: .*/CLOUDFLARE_SUBDOMAIN: $APP_NAME.workers.dev/" "$SLACK_WORKFLOW"
        
        # Remove backup file
        rm -f "$SLACK_WORKFLOW.bak"
        
        print_success "Updated Slack deploy workflow"
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
# Open Setup URLs
# ============================================================================

open_setup_urls() {
    print_header "Quick Links"
    
    # Open Cloudflare Pages dashboard
    echo "To connect this repo to Cloudflare Pages for automatic deploys:"
    echo ""
    read -p "Open Cloudflare Pages dashboard in browser? (Y/n): " OPEN_CF
    OPEN_CF=${OPEN_CF:-Y}
    
    if [[ "$OPEN_CF" =~ ^[Yy]$ ]]; then
        CF_PAGES_URL="https://dash.cloudflare.com/$ACCOUNT_ID/pages/new/provider/github"
        if command -v open &> /dev/null; then
            open "$CF_PAGES_URL"
            print_success "Opened Cloudflare Pages dashboard"
        elif command -v xdg-open &> /dev/null; then
            xdg-open "$CF_PAGES_URL"
            print_success "Opened Cloudflare Pages dashboard"
        else
            echo -e "  ${CYAN}$CF_PAGES_URL${NC}"
        fi
    fi
    
    echo ""
    
    # Open API tokens page
    echo "To create a D1 API token for database migrations:"
    echo ""
    read -p "Open Cloudflare API tokens page in browser? (Y/n): " OPEN_TOKEN
    OPEN_TOKEN=${OPEN_TOKEN:-Y}
    
    if [[ "$OPEN_TOKEN" =~ ^[Yy]$ ]]; then
        if command -v open &> /dev/null; then
            open "https://dash.cloudflare.com/profile/api-tokens"
            print_success "Opened API tokens page"
        elif command -v xdg-open &> /dev/null; then
            xdg-open "https://dash.cloudflare.com/profile/api-tokens"
            print_success "Opened API tokens page"
        else
            echo -e "  ${CYAN}https://dash.cloudflare.com/profile/api-tokens${NC}"
        fi
        
        # Ask for the token if D1 was created
        if [ "$D1_CREATED" = true ]; then
            echo ""
            echo "Once you have created the token, paste it below:"
            read -p "Cloudflare API Token (press Enter to skip): " CF_TOKEN
            
            if [ -n "$CF_TOKEN" ]; then
                # Update the .env file
                if [ -f "apps/website/.env" ]; then
                    # Escape special characters in token if necessary (though usually safe)
                    sed -i.bak "s|CLOUDFLARE_D1_TOKEN=\"YOUR_D1_API_TOKEN_HERE\"|CLOUDFLARE_D1_TOKEN=\"$CF_TOKEN\"|" apps/website/.env
                    rm -f apps/website/.env.bak
                    print_success "Updated apps/website/.env with your API token"
                else
                    print_warning "apps/website/.env not found. Could not save token."
                fi
            else
                print_warning "Skipping token configuration."
            fi
        fi
    fi
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
    if [ "$D1_CREATED" = true ]; then
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
    fi
}

print_summary() {
    print_header "Setup Complete! 🎉"
    
    echo -e "Your app ${GREEN}$APP_NAME${NC} is ready to go!"
    echo ""
    echo -e "${CYAN}Resources created:${NC}"
    if [ "$D1_CREATED" = true ]; then
        echo "  • D1 Database: $DB_NAME ($DATABASE_ID)"
    fi
    if [ "$R2_CREATED" = true ]; then
        echo "  • R2 Bucket: $BUCKET_NAME"
    fi
    if [ -n "$GITHUB_REPO" ]; then
        echo "  • GitHub Repo: $GITHUB_REPO"
    fi
    echo ""
    echo -e "${CYAN}Files updated:${NC}"
    echo "  • package.json"
    echo "  • wrangler.toml"
    echo "  • apps/website/.env"
    echo ""
    echo -e "${CYAN}Next steps:${NC}"
    if [ "$D1_CREATED" = true ]; then
        echo "  1. Add your D1 API token to apps/website/.env"
        echo "  2. Connect your repo to Cloudflare Pages (if not done)"
        echo "  3. Run: pnpm db:push"
    else
        echo "  1. Connect your repo to Cloudflare Pages (if not done)"
    fi
    echo "  4. Run: pnpm dev"
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
    
    # Check dependencies and detect app info
    check_dependencies
    detect_app_name
    
    # Git and GitHub setup
    setup_git_repo
    check_github_auth
    
    # Cloudflare setup
    check_wrangler_auth
    create_d1_database
    create_r2_bucket
    generate_secrets
    
    # Update configuration files
    update_package_json
    update_wrangler_toml
    update_slack_workflow
    create_env_file
    
    # GitHub repo and integrations
    create_github_repo
    setup_slack_webhook
    
    # Open helpful URLs
    open_setup_urls
    
    # Final steps
    run_final_steps
    print_summary
}

main "$@"
