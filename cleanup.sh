#!/bin/bash
# Cleanup script for Ayra
set -e  # Exit on error

echo "🧹 Cleaning up Ayra components..."
echo ""
echo "📦 Note: Component code folders (issuer-portal, verifier-portal, trust-registry-ui, mobile-app)"
echo "   are part of the repository and will NOT be removed"
echo "   Only Trust Registry API (cloned from GitHub) and generated data will be cleaned"
echo ""

# Function to clean a directory
cleanup_directory() {
    local dir=$1
    local name=$2

    if [ -d "$dir" ]; then
        echo "  🗑️  Removing $name..."
        rm -rf "$dir"
        echo "  ✅ $name removed"
    else
        echo "  ⏭️  $name not found, skipping..."
    fi
}

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Cleaning Trust Registry API..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cleanup_directory "trust-registry-api/code" "Trust Registry API code (cloned from GitHub)"
cleanup_directory "trust-registry-api/data" "Trust Registry API data"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Cleaning generated data directories..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cleanup_directory "trust-registry-ui/data" "Trust Registry UI data"
cp "trust-registry-ui/registries.ts" "trust-registry-ui/code/src/data/registries.ts"

cleanup_directory "verifier-portal/data" "Verifier Portal data"
cleanup_directory "issuer-portal/data" "Issuer Portal data"
cleanup_directory "keycloak-verifier/code/vc-authn-oidc-bridge/keys" "OIDC Bridge RSA keys"
cleanup_directory "keycloak-verifier/code/vc-authn-oidc-bridge/node_modules" "OIDC Bridge node_modules"
cleanup_directory "keycloak-verifier/code/demo-app/node_modules" "Demo App node_modules"


cp "mobile-app/configs/organizations.dart" "mobile-app/code/lib/infrastructure/repositories/organizations_repository/organizations.dart"

# echo ""
# echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
# echo "Cleaning ngrok domains..."
# echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
# if [ -f "ngrok/domains.json" ]; then
#     echo "  🗑️  Removing domains.json..."
#     rm -f "ngrok/domains.json"
#     echo "  ✅ domains.json removed"
# else
#     echo "  ⏭️  domains.json not found, skipping..."
# fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Cleaning Docker containers and volumes..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Stop and remove containers
if docker compose ps -q 2>/dev/null | grep -q .; then
    echo "  🛑 Stopping Docker containers..."
    docker compose down
    echo "  ✅ Docker containers stopped"
else
    echo "  ⏭️  No running containers found"
fi

# Remove Docker images from this project
echo "  🗑️  Removing Docker images..."
IMAGES=$(docker compose config --images 2>/dev/null)
if [ ! -z "$IMAGES" ]; then
    echo "$IMAGES" | while read image; do
        if [ ! -z "$image" ]; then
            echo "    Removing image: $image"
            docker rmi "$image" 2>/dev/null || echo "    ⚠️  Could not remove $image (may be in use)"
        fi
    done
    echo "  ✅ Docker images cleaned"
else
    echo "  ⏭️  No images to remove"
fi

# Clean Docker build cache
echo "  🧹 Cleaning Docker build cache..."
docker builder prune -f 2>/dev/null || echo "    ⚠️  Could not prune build cache"
echo "  ✅ Build cache cleaned"

# Clean dangling images
echo "  🧹 Cleaning dangling images..."
docker image prune -f 2>/dev/null || echo "    ⚠️  Could not prune dangling images"
echo "  ✅ Dangling images cleaned"

echo ""
echo "✅ Cleanup completed!"
echo ""
echo "To set up again, run:"
echo "  ./setup-ayra.sh"