#!/bin/bash

# Deployment script for redmine-tools to Homebrew
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Redmine Tools Homebrew Deployment Script${NC}"
echo "=============================================="

# Check if we're in the right directory
if [ ! -f "go.mod" ] || [ ! -d "cmd" ]; then
    echo -e "${RED}❌ Error: This script should be run from the redmine-tools project root${NC}"
    exit 1
fi

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo -e "${YELLOW}🔍 Checking prerequisites...${NC}"

if ! command_exists git; then
    echo -e "${RED}❌ Git is not installed${NC}"
    exit 1
fi

if ! command_exists go; then
    echo -e "${RED}❌ Go is not installed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Prerequisites check passed${NC}"

# Get version from user
echo -e "${YELLOW}📝 Please enter the version for this release (e.g., 1.0.0):${NC}"
read -p "Version: " VERSION

if [ -z "$VERSION" ]; then
    echo -e "${RED}❌ Version cannot be empty${NC}"
    exit 1
fi

# Add 'v' prefix if not present
if [[ ! $VERSION =~ ^v ]]; then
    VERSION="v$VERSION"
fi

echo -e "${BLUE}📦 Preparing release $VERSION${NC}"

# Step 1: Ensure all changes are committed
echo -e "${YELLOW}1️⃣ Checking git status...${NC}"
if [ -n "$(git status --porcelain)" ]; then
    echo -e "${YELLOW}⚠️  You have uncommitted changes. Committing them now...${NC}"
    git add .
    git commit -m "Prepare for release $VERSION"
fi

# Step 2: Create and push tag
echo -e "${YELLOW}2️⃣ Creating and pushing tag $VERSION...${NC}"
git tag "$VERSION" || echo -e "${YELLOW}⚠️  Tag $VERSION already exists${NC}"
git push origin main
git push origin "$VERSION" || echo -e "${YELLOW}⚠️  Tag $VERSION already pushed${NC}"

echo -e "${GREEN}✅ Tag $VERSION created and pushed${NC}"

# Step 3: Wait for GitHub Actions (if applicable)
echo -e "${YELLOW}3️⃣ Waiting for GitHub release to be created...${NC}"
echo -e "${BLUE}Please wait for GitHub Actions to complete the release build.${NC}"
echo -e "${BLUE}Check: https://github.com/vfa-khuongdv/redmine-tools/releases${NC}"
read -p "Press Enter when the release is available on GitHub..."

# Step 4: Calculate SHA256
echo -e "${YELLOW}4️⃣ Calculating SHA256 for release archive...${NC}"
ARCHIVE_URL="https://github.com/vfa-khuongdv/redmine-tools/archive/$VERSION.tar.gz"
echo -e "${BLUE}Downloading: $ARCHIVE_URL${NC}"

SHA256=$(curl -sL "$ARCHIVE_URL" | shasum -a 256 | cut -d ' ' -f 1)
echo -e "${GREEN}✅ SHA256: $SHA256${NC}"

# Step 5: Update Homebrew formula
echo -e "${YELLOW}5️⃣ Updating Homebrew formula...${NC}"
HOMEBREW_TAP_DIR="../homebrew-redmine-tools"

if [ ! -d "$HOMEBREW_TAP_DIR" ]; then
    echo -e "${RED}❌ Homebrew tap directory not found. Run ./setup-homebrew-tap.sh first${NC}"
    exit 1
fi

# Update formula
cat > "$HOMEBREW_TAP_DIR/redmine-tools.rb" << EOF
class RedmineTools < Formula
  desc "Command-line tool for working with Redmine projects"
  homepage "https://github.com/vfa-khuongdv/redmine-tools"
  url "https://github.com/vfa-khuongdv/redmine-tools/archive/$VERSION.tar.gz"
  sha256 "$SHA256"
  license "MIT"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w -X main.version=#{version}"), "./cmd"
  end

  test do
    output = shell_output("#{bin}/redmine-tools --version")
    assert_match "redmine-tools version #{version}", output
  end
end
EOF

echo -e "${GREEN}✅ Formula updated${NC}"

# Step 6: Commit and push to tap repository
echo -e "${YELLOW}6️⃣ Committing formula to tap repository...${NC}"
cd "$HOMEBREW_TAP_DIR"

git add redmine-tools.rb
git commit -m "Update redmine-tools to $VERSION"

# Check if remote exists
if git remote get-url origin >/dev/null 2>&1; then
    git push origin main || git push origin master
    echo -e "${GREEN}✅ Formula pushed to GitHub${NC}"
else
    echo -e "${YELLOW}⚠️  Remote 'origin' not configured. Please set up your GitHub repository:${NC}"
    echo "git remote add origin https://github.com/vfa-khuongdv/homebrew-redmine-tools.git"
    echo "git push -u origin main"
fi

cd - > /dev/null

# Step 7: Final instructions
echo -e "${BLUE}🎉 Deployment complete!${NC}"
echo "================================================"
echo -e "${GREEN}✅ Tag $VERSION created and pushed${NC}"
echo -e "${GREEN}✅ SHA256 calculated: $SHA256${NC}"
echo -e "${GREEN}✅ Formula updated and committed${NC}"
echo ""
echo -e "${YELLOW}📋 Next steps:${NC}"
echo "1. Verify the release at: https://github.com/vfa-khuongdv/redmine-tools/releases"
echo "2. Test installation: brew tap vfa-khuongdv/redmine-tools && brew install redmine-tools"
echo "3. Test the tool: redmine-tools --version"
echo ""
echo -e "${BLUE}🍺 Your tool should now be available via Homebrew!${NC}"
