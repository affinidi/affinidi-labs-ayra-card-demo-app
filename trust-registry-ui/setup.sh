#!/bin/bash
# Trust Registry UI setup script
set -e  # Exit on error

echo "🚀 Setting up Affinidi Trust Registry UI..."

# Load main .env file
MAIN_ENV_FILE="../.env"
if [ -f "$MAIN_ENV_FILE" ]; then
    source "$MAIN_ENV_FILE"
fi

# Set default repo URL if not in .env
TRUST_REGISTRY_UI_REPO_URL="${TRUST_REGISTRY_UI_REPO_URL:-https://gitlab.com/affinidi/prototypes/ayra/trust-registry-server}"

# Clone the repository if it doesn't exist
if [ ! -d "code" ]; then
    echo "📦 Cloning Trust Registry UI from repository..."
    git clone "$TRUST_REGISTRY_UI_REPO_URL" ./code
else
    echo "✓ Code already cloned"
fi


# Update tr-data.csv with issuer domains
if [ -f "$MAIN_ENV_FILE" ]; then
    echo "🔧 Updating tr-data.csv with issuer domains..."
    source "$MAIN_ENV_FILE"
    
    # Create data directory if it doesn't exist
    mkdir -p ./data
    
    # Copy the template tr-data.csv to the data directory
    cp ./registries.ts ./code/src/data/registries.ts
    
    if [ ! -z "$ISSUER_DIDWEB_DOMAIN" ]; then
        # Extract just the domain part
        ISSUER_DOMAIN_BASE=$(echo "$ISSUER_DIDWEB_DOMAIN" | cut -d'/' -f1)
        # URL encode the colon
        ISSUER_DOMAIN_ENCODED=$(echo "$ISSUER_DOMAIN_BASE" | sed 's/:/%3A/g')
        
        # Replace localhost%3A8080 with the issuer domain
        sed -i '' "s|localhost%3A8080|$ISSUER_DOMAIN_ENCODED|g" ./code/src/data/registries.ts
        echo "✅ Updated tr-data.csv with domain: $ISSUER_DOMAIN_ENCODED"
    fi
fi
