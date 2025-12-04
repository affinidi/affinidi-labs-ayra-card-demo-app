#!/bin/bash
# Trust Registry UI setup script
set -e  # Exit on error

echo "🚀 Setting up Affinidi Trust Registry UI..."
echo "📦 Using code from included repository (trust-registry-ui/code/)"

# Load main .env file
MAIN_ENV_FILE="../.env"
if [ -f "$MAIN_ENV_FILE" ]; then
    source "$MAIN_ENV_FILE"
fi

# Verify code directory exists
if [ ! -d "code" ]; then
    echo "❌ Error: code directory not found at trust-registry-ui/code/"
    echo "   The repository should include the trust registry UI code."
    exit 1
fi

echo "✓ Code directory verified"


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

# Install Node.js dependencies
echo "📦 Installing Node.js dependencies..."
cd code
if npm install; then
    echo "✅ Dependencies installed successfully"
else
    echo "⚠️  Failed to install dependencies, but continuing..."
fi
cd ..

echo "✅ Trust Registry UI setup completed successfully!"
