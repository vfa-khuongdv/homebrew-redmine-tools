#!/bin/bash

# Simple deployment script for redmine-tools to Homebrew
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Simple Redmine Tools Deployment${NC}"
echo "=================================="

# Get version from user
echo -e "${YELLOW}📝 Enter version (e.g., 1.0.4):${NC}"
read -p "Version: " VERSION

if [ -z "$VERSION" ]; then
    echo -e "${RED}❌ Version cannot be empty${NC}"
    exit 1
fi

# Add 'v' prefix if not present
if [[ ! $VERSION =~ ^v ]]; then
    VERSION="v$VERSION"
fi

echo -e "${BLUE}📦 Processing release $VERSION${NC}"

# Step 1: Create tag
echo -e "${YELLOW}1️⃣ Creating tag...${NC}"
if git rev-parse "$VERSION" >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Tag $VERSION already exists, deleting and recreating...${NC}"
    git tag -d "$VERSION"
fi

git tag "$VERSION"
echo -e "${GREEN}✅ Tag $VERSION created${NC}"

# Step 2: Push tag and handle workflow scope issue
echo -e "${YELLOW}2️⃣ Pushing tag...${NC}"
if git push origin "$VERSION" 2>&1; then
    echo -e "${GREEN}✅ Tag pushed successfully${NC}"
    
    # Wait a moment for GitHub Actions to start
    echo -e "${YELLOW}⏳ Waiting for GitHub Actions to start...${NC}"
    sleep 5
    
    echo -e "${BLUE}🔗 Check build status: https://github.com/vfa-khuongdv/homebrew-redmine-tools/actions${NC}"
    echo -e "${BLUE}🔗 Release page: https://github.com/vfa-khuongdv/homebrew-redmine-tools/releases${NC}"
    
    echo ""
    echo -e "${YELLOW}📋 Manual steps to complete:${NC}"
    echo "1. Wait for GitHub Actions to complete the release build"
    echo "2. Check that the release appears at: https://github.com/vfa-khuongdv/homebrew-redmine-tools/releases"
    echo "3. Then run: ./update-formula.sh $VERSION"
    
else
    echo -e "${RED}❌ Failed to push tag${NC}"
    echo -e "${YELLOW}💡 Try one of these solutions:${NC}"
    echo "1. Update your GitHub token to include 'workflow' scope"
    echo "2. Or manually create release on GitHub:"
    echo "   - Go to: https://github.com/vfa-khuongdv/homebrew-redmine-tools/releases"
    echo "   - Click 'Create a new release'"
    echo "   - Use tag: $VERSION"
    echo "   - Publish the release"
fi

echo ""
echo -e "${BLUE}🎯 Next: Run './update-formula.sh $VERSION' after release is created${NC}"
