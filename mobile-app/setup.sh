#!/bin/bash
# Mobile App script
set -e  # Exit on error

echo "🚀 Setting up Mobile App..."
echo "📦 Using code from included repository (mobile-app/code/)"

# Load main .env file
MAIN_ENV_FILE="../.env"
if [ -f "$MAIN_ENV_FILE" ]; then
    source "$MAIN_ENV_FILE"
fi

# Verify code directory exists
if [ ! -d "code" ]; then
    echo "❌ Error: code directory not found at mobile-app/code/"
    echo "   The repository should include the mobile app code."
    exit 1
fi

# Verify template file exists
if [ ! -f "code/templates/.example.env" ]; then
    echo "❌ Error: Template file not found at code/templates/.example.env"
    echo "   The code directory may be incomplete."
    exit 1
fi

echo "✓ Code directory verified"

if [ ! -f "$MAIN_ENV_FILE" ]; then
    echo "❌ Error: Main .env file not found at $MAIN_ENV_FILE"
    exit 1
fi

echo "📝 Loading environment variables from main .env file..."
source "$MAIN_ENV_FILE"

# Create .env file from template
TEMPLATE_FILE="./code/templates/.example.env"
CONFIG_DIR="./code/configurations"
TARGET_ENV_FILE="$CONFIG_DIR/.env"

if [ ! -f "$TEMPLATE_FILE" ]; then
    echo "❌ Error: Template file not found at $TEMPLATE_FILE"
    exit 1
fi

echo "📄 Creating .env file from template..."
mkdir -p "$CONFIG_DIR"
cp "$TEMPLATE_FILE" "$TARGET_ENV_FILE"

# Update .env file with values from main .env
echo "🔧 Updating .env file with configuration values..."

# Update APP_VERSION_NAME
if [ ! -z "$APP_VERSION_NAME" ]; then
    sed -i '' "s|^APP_VERSION_NAME=.*|APP_VERSION_NAME=\"$APP_VERSION_NAME\"|g" "$TARGET_ENV_FILE"
fi

# Update SERVICE_DID
if [ ! -z "$SERVICE_DID" ]; then
    sed -i '' "s|^SERVICE_DID=.*|SERVICE_DID=\"$SERVICE_DID\"|g" "$TARGET_ENV_FILE"
fi

# Update MEDIATOR_DID (DEFAULT_MEDIATOR_DID in template)
if [ ! -z "$MEDIATOR_DID" ]; then
    sed -i '' "s|^DEFAULT_MEDIATOR_DID=.*|DEFAULT_MEDIATOR_DID=\"$MEDIATOR_DID\"|g" "$TARGET_ENV_FILE"
    # Also update the duplicate MEDIATOR_DID field at the bottom if it exists
    sed -i '' "s|^MEDIATOR_DID=.*|MEDIATOR_DID=\"$MEDIATOR_DID\"|g" "$TARGET_ENV_FILE"
fi

echo "✅ Mobile App environment configuration completed!"
echo "📍 Configuration file created at: $TARGET_ENV_FILE"

# Replace localhost%3A8080 with the issuer domain from .env in organizations.dart
if [ ! -z "$ISSUER_DIDWEB_DOMAIN" ]; then
    echo "🔧 Updating organizations.dart with issuer domains..."

    # Extract just the domain part (e.g., "abc123.ngrok-free.app" from "abc123.ngrok-free.app/sweetlane-bank")
    ISSUER_DOMAIN_BASE=$(echo "$ISSUER_DIDWEB_DOMAIN" | cut -d'/' -f1)
    # URL encode the colon (: becomes %3A)
    ISSUER_DOMAIN_ENCODED=$(echo "$ISSUER_DOMAIN_BASE" | sed 's/:/%3A/g')

    # Replace the default domain
    sed -i '' "s|issuers.sa.affinidi.io|$ISSUER_DOMAIN_ENCODED|g" ./code/lib/infrastructure/repositories/organizations_repository/organizations.dart
    # Replace any existing ngrok domains
    sed -i '' "s|[a-zA-Z0-9-]*\.ngrok-free\.app|$ISSUER_DOMAIN_ENCODED|g" ./code/lib/infrastructure/repositories/organizations_repository/organizations.dart
    echo "✅ Updated organizations.dart with domain: $ISSUER_DOMAIN_ENCODED"
fi

# Copy Firebase config files if they exist
if [ -f "configs/google-services.json" ]; then
    cp configs/google-services.json ./code/android/app/google-services.json
    echo "✅ Copied google-services.json"
else
    echo "⚠️  google-services.json not found, skipping..."
fi

if [ -f "configs/GoogleService-Info.plist" ]; then
    cp configs/GoogleService-Info.plist ./code/ios/Runner/GoogleService-Info.plist
    echo "✅ Copied GoogleService-Info.plist"
else
    echo "⚠️  GoogleService-Info.plist not found, skipping..."
fi

# Install Flutter dependencies
echo "📦 Installing Flutter dependencies..."
cd code
if flutter pub get; then
    echo "✅ Dependencies installed successfully"
else
    echo "⚠️  Failed to install dependencies, but continuing..."
fi
cd ..

echo "✅ Mobile App setup completed successfully!"