#!/bin/bash
# Verifier Service setup script
set -e  # Exit on error

echo "🚀 Setting up Verifier Service..."

# Load main .env file
MAIN_ENV_FILE="../.env"
if [ -f "$MAIN_ENV_FILE" ]; then
    source "$MAIN_ENV_FILE"
fi

# Set default repo URL if not in .env
VERIFIER_REPO_URL="${VERIFIER_REPO_URL:-https://gitlab.com/affinidi/prototypes/ayra/vdsp-verifier-server}"

# Clone or copy the code
if [ ! -d "code" ]; then
    echo "📦 Cloning Verifier Service from repository..."
    git clone "$VERIFIER_REPO_URL" ./code
else
    echo "✓ Code already cloned"
fi

