#!/bin/bash
# Main setup script for Ayra
set -e  # Exit on error

echo "🚀 Setting up Ayra components..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check if USE_NGROK is enabled
USE_NGROK=$(grep "^USE_NGROK=" .env | cut -d '=' -f2)
if [ "$USE_NGROK" = "true" ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Setting up public domains with ngrok..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    cd domain-setup
    ./setup.sh
    cd ..
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Setting up Trust Registry API..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cd trust-registry-api
./setup.sh
cd ..

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Setting up Trust Registry UI..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cd trust-registry-ui
./setup.sh
cd ..

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Setting up Verifier Portal..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cd verifier-portal
./setup.sh
cd ..

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Setting up Issuer Portal..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cd issuer-portal
./setup.sh
cd ..

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Setting up Mobile App..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cd mobile-app
./setup.sh
cd ..