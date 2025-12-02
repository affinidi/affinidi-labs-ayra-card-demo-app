#!/bin/bash
# Trust Registry API setup script
set -e  # Exit on error

echo "🚀 Setting up Affinidi Trust Registry API..."

# Load main .env file
MAIN_ENV_FILE="../.env"
if [ -f "$MAIN_ENV_FILE" ]; then
    source "$MAIN_ENV_FILE"
fi

# Set default repo URL if not in .env
TRUST_REGISTRY_API_REPO_URL="${TRUST_REGISTRY_API_REPO_URL:-https://github.com/affinidi/affinidi-trust-registry-rs}"

# Clone the repository if it doesn't exist
if [ ! -d "code" ]; then
    echo "📦 Cloning Affinidi Trust Registry API from repository..."
    git clone "$TRUST_REGISTRY_API_REPO_URL" ./code
else
    echo "✓ Repository already cloned"
fi

# Update tr-data.csv with issuer domains
if [ -f "$MAIN_ENV_FILE" ]; then
    echo "🔧 Updating tr-data.csv with issuer domains..."
    source "$MAIN_ENV_FILE"
    
    # Create data directory if it doesn't exist
    mkdir -p ./data
    
    # Copy the template tr-data.csv to the data directory
    cp ./data-template.csv ./data/tr-data.csv
    
    if [ ! -z "$ISSUER_DIDWEB_DOMAIN" ]; then
        # Extract just the domain part
        ISSUER_DOMAIN_BASE=$(echo "$ISSUER_DIDWEB_DOMAIN" | cut -d'/' -f1)
        # URL encode the colon
        ISSUER_DOMAIN_ENCODED=$(echo "$ISSUER_DOMAIN_BASE" | sed 's/:/%3A/g')
        
        # Replace localhost%3A8080 with the issuer domain
        sed -i '' "s|localhost%3A8080|$ISSUER_DOMAIN_ENCODED|g" ./data/tr-data.csv
        echo "✅ Updated tr-data.csv with domain: $ISSUER_DOMAIN_ENCODED"
    fi
fi



