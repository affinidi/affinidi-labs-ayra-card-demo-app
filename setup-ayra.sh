#!/bin/bash
# Main setup script for Ayra
set -e  # Exit on error

echo "🚀 Setting up Ayra components..."

# Check if .env file exists, if not copy from .env.example
if [ ! -f .env ]; then
    echo "📝 .env file not found. Creating from .env.example..."
    if [ -f .env.example ]; then
        cp .env.example .env
        echo "✅ .env file created successfully"
    else
        echo "❌ .env.example file not found. Cannot proceed."
        exit 1
    fi
fi

# Check and prompt for SERVICE_DID if not set
SERVICE_DID=$(grep "^SERVICE_DID=" .env | cut -d '=' -f2)
if [ -z "$SERVICE_DID" ]; then
    echo ""
    echo "⚠️  SERVICE_DID is not set in .env file"
    read -p "Please enter SERVICE_DID: " SERVICE_DID
    if [ -z "$SERVICE_DID" ]; then
        echo "❌ SERVICE_DID is required. Exiting."
        exit 1
    fi
    # Update .env file with SERVICE_DID
    sed -i.bak "s|^SERVICE_DID=.*|SERVICE_DID=$SERVICE_DID|" .env
    rm -f .env.bak
    echo "✅ SERVICE_DID updated in .env file"
fi

# Check and prompt for MEDIATOR_DID if not set
MEDIATOR_DID=$(grep "^MEDIATOR_DID=" .env | cut -d '=' -f2)
if [ -z "$MEDIATOR_DID" ]; then
    echo ""
    echo "⚠️  MEDIATOR_DID is not set in .env file"
    read -p "Please enter MEDIATOR_DID: " MEDIATOR_DID
    if [ -z "$MEDIATOR_DID" ]; then
        echo "❌ MEDIATOR_DID is required. Exiting."
        exit 1
    fi
    # Update .env file with MEDIATOR_DID
    sed -i.bak "s|^MEDIATOR_DID=.*|MEDIATOR_DID=$MEDIATOR_DID|" .env
    rm -f .env.bak
    echo "✅ MEDIATOR_DID updated in .env file"
fi

# Automatically extract and set MEDIATOR_DOMAIN from MEDIATOR_DID
if [ -n "$MEDIATOR_DID" ]; then
    # Extract domain from did:web:DOMAIN format
    MEDIATOR_DOMAIN=$(echo "$MEDIATOR_DID" | sed 's|^did:web:||')
    # Update .env file with MEDIATOR_DOMAIN
    sed -i.bak "s|^MEDIATOR_DOMAIN=.*|MEDIATOR_DOMAIN=$MEDIATOR_DOMAIN|" .env
    rm -f .env.bak
    echo "✅ MEDIATOR_DOMAIN automatically set to: $MEDIATOR_DOMAIN"
fi

# Check if USE_NGROK is enabled and prompt for token if needed
USE_NGROK=$(grep "^USE_NGROK=" .env | cut -d '=' -f2)
if [ "$USE_NGROK" = "true" ]; then
    NGROK_AUTH_TOKEN=$(grep "^NGROK_AUTH_TOKEN=" .env | cut -d '=' -f2)
    if [ -z "$NGROK_AUTH_TOKEN" ]; then
        echo ""
        echo "⚠️  NGROK_AUTH_TOKEN is not set in .env file"
        echo "Get your auth token from: https://dashboard.ngrok.com/get-started/your-authtoken"
        read -p "Please enter NGROK_AUTH_TOKEN: " NGROK_AUTH_TOKEN
        if [ -z "$NGROK_AUTH_TOKEN" ]; then
            echo "❌ NGROK_AUTH_TOKEN is required when USE_NGROK=true. Exiting."
            exit 1
        fi
        # Update .env file with NGROK_AUTH_TOKEN
        sed -i.bak "s|^NGROK_AUTH_TOKEN=.*|NGROK_AUTH_TOKEN=$NGROK_AUTH_TOKEN|" .env
        rm -f .env.bak
        echo "✅ NGROK_AUTH_TOKEN updated in .env file"
    fi
fi

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check if USE_NGROK is enabled
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