# Homebrew Publishing Guide

This guide will help you publish your `redmine-tools` application to Homebrew.

## Prerequisites

1. Your main project repository: `https://github.com/vfa-khuongdv/redmine-tools`
2. Your Homebrew tap repository: `https://github.com/vfa-khuongdv/homebrew-redmine-tools`

## Step-by-Step Process

### 1. Setup Your Main Repository

First, make sure your main repository is ready:

```bash
# Add all files to git
git add .
git commit -m "Prepare for Homebrew release"
git push origin main
```

### 2. Create Your Homebrew Tap Repository

1. Go to GitHub and create a new repository named `homebrew-redmine-tools`
2. Run the setup script from your project directory:

```bash
./setup-homebrew-tap.sh
```

3. Navigate to the created tap directory and connect it to GitHub:

```bash
cd ../homebrew-redmine-tools
git remote add origin https://github.com/vfa-khuongdv/homebrew-redmine-tools.git
git branch -M main
git push -u origin main
```

### 3. Create Your First Release

1. Tag your first release in the main repository:

```bash
cd ../redmine-tools
git tag v1.0.0
git push origin v1.0.0
```

2. The GitHub Actions workflow will automatically:
   - Build binaries for multiple platforms
   - Create a GitHub release
   - Generate SHA256 checksums

### 4. Update the Homebrew Formula

After the release is created:

1. Download the source archive and calculate its SHA256:

```bash
# Get the SHA256 of the release archive
curl -L https://github.com/vfa-khuongdv/redmine-tools/archive/v1.0.0.tar.gz | shasum -a 256
```

2. Update the formula in your homebrew tap repository:

```ruby
class RedmineTools < Formula
  desc "Command-line tool for working with Redmine projects"
  homepage "https://github.com/vfa-khuongdv/redmine-tools"
  url "https://github.com/vfa-khuongdv/redmine-tools/archive/v1.0.0.tar.gz"
  sha256 "YOUR_ACTUAL_SHA256_HERE"
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
```

3. Commit and push the updated formula:

```bash
cd ../homebrew-redmine-tools
git add redmine-tools.rb
git commit -m "Update redmine-tools to v1.0.0"
git push
```

### 5. Test Your Formula

Test that your formula works:

```bash
# Install your tap locally
brew tap vfa-khuongdv/redmine-tools

# Install your tool
brew install redmine-tools

# Test it
redmine-tools --version
```

### 6. For Future Releases

For subsequent releases:

1. Tag a new version in your main repository
2. Wait for GitHub Actions to create the release
3. Update the formula with the new version and SHA256
4. Commit and push the updated formula

## Troubleshooting

### Common Issues

1. **SHA256 mismatch**: Always calculate the SHA256 from the actual release archive
2. **Build failures**: Ensure your Go version in the formula matches your project requirements
3. **Formula validation**: Use `brew audit --strict --online redmine-tools` to check your formula

### Testing Locally

Before pushing updates:

```bash
# Test formula syntax
brew audit --strict redmine-tools

# Test installation from local formula
brew install --build-from-source redmine-tools

# Test uninstallation
brew uninstall redmine-tools
```

## Resources

- [Homebrew Formula Cookbook](https://docs.brew.sh/Formula-Cookbook)
- [Go Formula Examples](https://github.com/Homebrew/homebrew-core/tree/master/Formula)
- [Acceptable Formulae](https://docs.brew.sh/Acceptable-Formulae)
