class RedmineTools < Formula
  desc "Command-line tool for working with Redmine projects"
  homepage "https://github.com/vfa-khuongdv/homebrew-redmine-tools"
  version "1.0.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/vfa-khuongdv/homebrew-redmine-tools/releases/download/v1.0.0/redmine-tools-darwin-arm64.tar.gz"
      sha256 "4c214cfd2d89762e3bf71cffb3480c459c2bdb788150b5c0ada8179e86aff3a1"
    end
    if Hardware::CPU.intel?
      url "https://github.com/vfa-khuongdv/homebrew-redmine-tools/releases/download/v1.0.0/redmine-tools-darwin-amd64.tar.gz"
      sha256 "eb505eda3867054f163c43348aeefa1b0d17870fe2e24a33e28526746399243b"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.arch_64_bit?
      url "https://github.com/vfa-khuongdv/homebrew-redmine-tools/releases/download/v1.0.0/redmine-tools-linux-arm64.tar.gz"
      sha256 "f893df8e3fa8c95a816d7a3f3c7234bfeeec08e60978a34f05d8abea9d54e21d"
    end
    if Hardware::CPU.intel?
      url "https://github.com/vfa-khuongdv/homebrew-redmine-tools/releases/download/v1.0.0/redmine-tools-linux-amd64.tar.gz"
      sha256 "f05ee5d5bac479ec6a376361c56ff4136ca53cdf4157e96d6a9662d099093029"
    end
  end

  def install
    bin.install Dir["redmine-tools-*"].first => "redmine-tools"
  end

  test do
    output = shell_output("#{bin}/redmine-tools --version")
    assert_match "redmine-tools version #{version}", output
  end
end
