#!/bin/bash
# Issuer Service setup script
set -e  # Exit on error

echo "🚀 Setting up Issuer Service..."

# Load main .env file
MAIN_ENV_FILE="../.env"
if [ -f "$MAIN_ENV_FILE" ]; then
    source "$MAIN_ENV_FILE"
fi

# Set default repo URL if not in .env
ISSUER_REPO_URL="${ISSUER_REPO_URL:-https://gitlab.com/affinidi/prototypes/ayra/vdip-issuer-server}"

# Clone the repository if it doesn't exist
if [ ! -d "code" ]; then
    echo "📦 Cloning Issuer Service from repository..."
    git clone "$ISSUER_REPO_URL" ./code
else
    echo "✓ Code already cloned"
fi

