#!/bin/bash
# Verifier Service setup script
set -e  # Exit on error

echo "🚀 Setting up Verifier Service..."
echo "📦 Using code from included repository (verifier-portal/code/)"

# Load main .env file
MAIN_ENV_FILE="../.env"
if [ -f "$MAIN_ENV_FILE" ]; then
    source "$MAIN_ENV_FILE"
fi

# Verify code directory exists
if [ ! -d "code" ]; then
    echo "❌ Error: code directory not found at verifier-portal/code/"
    echo "   The repository should include the verifier portal code."
    exit 1
fi

echo "✓ Code directory verified"

# Install Dart dependencies
echo "📦 Installing Dart dependencies..."
cd code
if dart pub get; then
    echo "✅ Dependencies installed successfully"
else
    echo "⚠️  Failed to install dependencies, but continuing..."
fi
cd ..

