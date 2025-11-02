#!/bin/bash

# Fix Nuxt build cache issues
# This script clears corrupted build artifacts and regenerates them

echo "🧹 Cleaning Nuxt build cache..."

# Remove all build artifacts
rm -rf .nuxt .output node_modules/.cache .nitro node_modules/.vite

echo "✅ Cache cleared"

# Regenerate Nuxt types and build
echo "🔧 Regenerating Nuxt build artifacts..."
npm run postinstall

echo "✨ Done! You can now run 'npm run dev' or 'npm run build'"

