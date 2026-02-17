#!/bin/bash
# Keycloak Verifier setup script
set -e  # Exit on error

echo "🚀 Setting up Keycloak Verifier (VC Authentication)..."
echo "📦 Using code from included repository (keycloak-verifier/code/)"

# Load main .env file
MAIN_ENV_FILE="../.env"
if [ -f "$MAIN_ENV_FILE" ]; then
    # shellcheck source=/dev/null
    . "$MAIN_ENV_FILE"
fi

# Verify code directories exist
if [ ! -d "code/vc-authn-oidc-bridge" ]; then
    echo "❌ Error: code/vc-authn-oidc-bridge directory not found"
    echo "   The repository should include the OIDC bridge code."
    exit 1
fi

if [ ! -d "code/keycloak-config" ]; then
    echo "❌ Error: code/keycloak-config directory not found"
    echo "   The repository should include the Keycloak configuration."
    exit 1
fi

echo "✓ Code directories verified"

# Install Node.js dependencies for OIDC bridge
echo "📦 Installing OIDC Bridge dependencies..."
cd code/vc-authn-oidc-bridge || exit 1
if npm install; then
    echo "✅ OIDC Bridge dependencies installed successfully"
else
    echo "⚠️  Failed to install dependencies, but continuing..."
fi
cd ../.. || exit 1

# Install Node.js dependencies for Demo App
echo "📦 Installing Demo App dependencies..."
cd code/demo-app || exit 1
if npm install; then
    echo "✅ Demo App dependencies installed successfully"
else
    echo "⚠️  Failed to install dependencies, but continuing..."
fi
cd ../.. || exit 1

# Create keys directory if not exists
mkdir -p code/vc-authn-oidc-bridge/keys

echo ""
echo "✅ Keycloak Verifier setup completed!"
echo ""
echo "📝 Configuration Notes:"
echo "   - Keycloak Admin Console: http://localhost:8880"
echo "   - Default admin credentials: admin/admin"
echo "   - OIDC Bridge: http://localhost:5001"
echo "   - Demo App: http://localhost:9000"
echo "   - Realm: ayra-demo"
echo ""
echo "📱 To use with the mobile app:"
echo "   1. Configure a 'federatedlogin' client in the verifier-portal"
echo "   2. Update the VERIFIER_CLIENT_ID in .env if using a different client"
echo ""
