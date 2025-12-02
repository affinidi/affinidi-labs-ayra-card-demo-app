#!/bin/bash
# Ngrok setup script
set -e  # Exit on error

echo "🌐 Setting up domains using ngrok..."

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CODE_DIR="$SCRIPT_DIR/code"

# Install dependencies if needed
if [ ! -d "$CODE_DIR/node_modules" ]; then
    echo "📦 Installing ngrok dependencies..."
    cd "$CODE_DIR"
    npm install
    echo "✅ Dependencies installed"
else
    echo "✅ Dependencies already installed"
fi

# Generate domains.json file by running tunnels
DOMAINS_FILE="$CODE_DIR/domains.json"

# Check if domains.json already exists
if [ -f "$DOMAINS_FILE" ]; then
    echo "✅ domains.json already exists, skipping tunnel generation..."
else
    echo ""
    echo "🚀 Generating ngrok tunnels and domains.json..."
    echo "   This will open a new terminal window to keep tunnels running..."
    echo ""

    # Open new terminal with npm start
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        osascript <<EOF
tell application "Terminal"
    do script "cd '$CODE_DIR' && npm start"
    activate
end tell
EOF
    else
        # Linux (try common terminal emulators)
        if command -v gnome-terminal &> /dev/null; then
            gnome-terminal -- bash -c "cd '$CODE_DIR' && npm start; exec bash"
        elif command -v xterm &> /dev/null; then
            xterm -e "cd '$CODE_DIR' && npm start" &
        else
            echo "⚠️  Could not detect terminal. Please run manually:"
            echo "   cd domain-setup/code && npm start"
        fi
    fi

    # Wait for domains.json to be created
    echo "⏳ Waiting for domains.json to be created..."
    TIMEOUT=30
    ELAPSED=0
    while [ ! -f "$DOMAINS_FILE" ] && [ $ELAPSED -lt $TIMEOUT ]; do
        sleep 1
        ELAPSED=$((ELAPSED + 1))
        echo -n "."
    done
    echo ""

    if [ ! -f "$DOMAINS_FILE" ]; then
        echo ""
        echo "❌ Error: domains.json was not created within $TIMEOUT seconds."
        echo "   Please check the ngrok terminal for errors."
        echo ""
        exit 1
    fi

    echo "✅ domains.json created successfully!"
fi

# Update main .env file with ngrok domains
echo ""
echo "🔧 Updating main .env file with ngrok domains..."

MAIN_ENV_FILE="$SCRIPT_DIR/../.env"
if [ ! -f "$MAIN_ENV_FILE" ]; then
    echo "❌ Error: Main .env file not found at $MAIN_ENV_FILE"
    exit 1
fi

# Extract domains from JSON using Node.js (use absolute path)
ISSUER_DOMAIN=$(node -e "const data = require('$DOMAINS_FILE'); console.log(data.issuer.domain);")
VERIFIER_DOMAIN=$(node -e "const data = require('$DOMAINS_FILE'); console.log(data.verifier.domain);")
TR_DOMAIN=$(node -e "const data = require('$DOMAINS_FILE'); console.log(data.trustRegistry.domain);")
TR_URL=$(node -e "const data = require('$DOMAINS_FILE'); console.log(data.trustRegistry.url);")

SWEETLANE_BANK=$(node -e "const data = require('$DOMAINS_FILE'); console.log(data.issuer.didweb.sweetlane_bank);")
SWEETLANE_GROUP=$(node -e "const data = require('$DOMAINS_FILE'); console.log(data.issuer.didweb.sweetlane_group);")
AYRA_FORUM=$(node -e "const data = require('$DOMAINS_FILE'); console.log(data.issuer.didweb.ayra_forum);")

# Update .env file
sed -i '' "s|^ISSUER_DIDWEB_DOMAIN=.*|ISSUER_DIDWEB_DOMAIN=$SWEETLANE_BANK|g" "$MAIN_ENV_FILE"
sed -i '' "s|^ECOSYSTEM_DIDWEB_DOMAIN=.*|ECOSYSTEM_DIDWEB_DOMAIN=$SWEETLANE_GROUP|g" "$MAIN_ENV_FILE"
sed -i '' "s|^AYRA_DIDWEB_DOMAIN=.*|AYRA_DIDWEB_DOMAIN=$AYRA_FORUM|g" "$MAIN_ENV_FILE"
sed -i '' "s|^TR_API_ENDPOINT=.*|TR_API_ENDPOINT=$TR_URL|g" "$MAIN_ENV_FILE"

# Update CORS allowed origins for Trust Registry
sed -i '' "s|^TR_CORS_ALLOWED_ORIGINS=.*|TR_CORS_ALLOWED_ORIGINS=\"http://localhost:3000,http://localhost:3001,https://$TR_DOMAIN\"|g" "$MAIN_ENV_FILE"

echo "✅ Updated main .env with ngrok domains:"
echo "   Issuer Domain: $ISSUER_DOMAIN"
echo "   Verifier Domain: $VERIFIER_DOMAIN"
echo "   Trust Registry: $TR_DOMAIN"
echo ""
echo "✅ Domain setup completed!"
echo ""
echo "📌 Note: Keep the ngrok terminal window open to maintain tunnels."
echo "   Close it when you're done with development."
