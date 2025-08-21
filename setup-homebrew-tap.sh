#!/bin/bash

# Setup script for Homebrew tap
set -e

echo "🍺 Setting up Homebrew tap for redmine-tools..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if we're in the right directory
if [ ! -f "go.mod" ] || [ ! -d "cmd" ]; then
    echo -e "${RED}❌ Error: This script should be run from the redmine-tools project root${NC}"
    exit 1
fi

# Create homebrew tap repository
HOMEBREW_TAP_DIR="../homebrew-redmine-tools"
echo -e "${YELLOW}📁 Creating Homebrew tap directory...${NC}"

if [ -d "$HOMEBREW_TAP_DIR" ]; then
    echo -e "${YELLOW}⚠️  Directory $HOMEBREW_TAP_DIR already exists${NC}"
    read -p "Do you want to recreate it? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$HOMEBREW_TAP_DIR"
    else
        echo -e "${YELLOW}Using existing directory${NC}"
    fi
fi

if [ ! -d "$HOMEBREW_TAP_DIR" ]; then
    mkdir -p "$HOMEBREW_TAP_DIR"
fi

# Copy files to homebrew tap directory
echo -e "${YELLOW}📋 Copying formula and README...${NC}"
cp redmine-tools.rb "$HOMEBREW_TAP_DIR/"
cp homebrew-tap-readme.md "$HOMEBREW_TAP_DIR/README.md"

# Initialize git repository if not exists
cd "$HOMEBREW_TAP_DIR"
if [ ! -d ".git" ]; then
    echo -e "${YELLOW}🔧 Initializing git repository...${NC}"
    git init
    git add .
    git commit -m "Initial commit: Add redmine-tools formula"
    
    echo -e "${GREEN}✅ Homebrew tap repository created!${NC}"
    echo -e "${YELLOW}📋 Next steps:${NC}"
    echo "1. Create a GitHub repository named 'homebrew-redmine-tools'"
    echo "2. Add the remote: git remote add origin https://github.com/vfa-khuongdv/homebrew-redmine-tools.git"
    echo "3. Push: git push -u origin main"
    echo "4. Create a release of your main project to get proper SHA256"
    echo "5. Update the formula with correct URL and SHA256"
else
    echo -e "${GREEN}✅ Files updated in existing git repository${NC}"
fi

cd - > /dev/null

echo -e "${GREEN}🎉 Homebrew tap setup complete!${NC}"
echo -e "${YELLOW}📁 Tap location: $HOMEBREW_TAP_DIR${NC}"
