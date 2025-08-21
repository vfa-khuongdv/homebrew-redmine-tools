#!/bin/bash

# Script to update Homebrew formula after release is created
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

VERSION=$1

if [ -z "$VERSION" ]; then
    echo -e "${RED}❌ Usage: $0 <version>${NC}"
    echo "Example: $0 v1.0.4"
    exit 1
fi

# Add 'v' prefix if not present
if [[ ! $VERSION =~ ^v ]]; then
    VERSION="v$VERSION"
fi

echo -e "${BLUE}🔧 Updating Homebrew formula for $VERSION${NC}"
echo "=================================="

# Step 1: Calculate SHA256
echo -e "${YELLOW}1️⃣ Calculating SHA256...${NC}"
ARCHIVE_URL="https://github.com/vfa-khuongdv/homebrew-redmine-tools/archive/$VERSION.tar.gz"
echo -e "${BLUE}Downloading: $ARCHIVE_URL${NC}"

SHA256=$(curl -sL "$ARCHIVE_URL" | shasum -a 256 | cut -d ' ' -f 1)
echo -e "${GREEN}✅ SHA256: $SHA256${NC}"

# Step 2: Update formula
echo -e "${YELLOW}2️⃣ Updating formula...${NC}"

cat > redmine-tools.rb << EOF
class RedmineTools < Formula
  desc "Command-line tool for working with Redmine projects"
  homepage "https://github.com/vfa-khuongdv/homebrew-redmine-tools"
  url "https://github.com/vfa-khuongdv/homebrew-redmine-tools/archive/$VERSION.tar.gz"
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

# Step 3: Commit and push
echo -e "${YELLOW}3️⃣ Committing changes...${NC}"

git add redmine-tools.rb
git commit -m "Update redmine-tools to $VERSION"
git push origin main

echo -e "${GREEN}✅ Changes committed and pushed${NC}"

echo ""
echo -e "${BLUE}🎉 Formula update complete!${NC}"
echo "==============================="
echo -e "${GREEN}✅ SHA256 calculated: $SHA256${NC}"
echo -e "${GREEN}✅ Formula updated and committed${NC}"
echo ""
echo -e "${YELLOW}📋 Test installation:${NC}"
echo "brew tap vfa-khuongdv/redmine-tools"
echo "brew install redmine-tools"
echo "redmine-tools --version"
