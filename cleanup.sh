#!/bin/bash
# Cleanup script for Ayra
set -e  # Exit on error

echo "🧹 Cleaning up Ayra components..."

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
cleanup_directory "trust-registry-api/code" "Trust Registry API code"
cleanup_directory "trust-registry-api/data" "Trust Registry API data"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Cleaning Trust Registry UI..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cleanup_directory "trust-registry-ui/code" "Trust Registry UI code"
cleanup_directory "trust-registry-ui/data" "Trust Registry UI data"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Cleaning Verifier Portal..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cleanup_directory "verifier-portal/code" "Verifier Portal code"
cleanup_directory "verifier-portal/data" "Verifier Portal data"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Cleaning Issuer Portal..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cleanup_directory "issuer-portal/code" "Issuer Portal code"
cleanup_directory "issuer-portal/data" "Issuer Portal data"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Cleaning Mobile App..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cleanup_directory "mobile-app/code" "Mobile App code"

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

echo ""
echo "✅ Cleanup completed!"
echo ""
echo "To set up again, run:"
echo "  ./setup-ayra.sh"