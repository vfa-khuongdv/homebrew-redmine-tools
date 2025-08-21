class RedmineTools < Formula
  desc "Command-line tool for working with Redmine projects"
  homepage "https://github.com/vfa-khuongdv/homebrew-redmine-tools"
  version "1.0.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/vfa-khuongdv/homebrew-redmine-tools/releases/download/v1.0.0/redmine-tools-darwin-arm64.tar.gz"
      sha256 "bd0afde162f74c0c7ef164a34728b42726f399226b1a44bfde82cb534cdec07d"
    end
    if Hardware::CPU.intel?
      url "https://github.com/vfa-khuongdv/homebrew-redmine-tools/releases/download/v1.0.0/redmine-tools-darwin-amd64.tar.gz"
      sha256 "bd0afde162f74c0c7ef164a34728b42726f399226b1a44bfde82cb534cdec07d"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.arch_64_bit?
      url "https://github.com/vfa-khuongdv/homebrew-redmine-tools/releases/download/v1.0.0/redmine-tools-linux-arm64.tar.gz"
      sha256 "bd0afde162f74c0c7ef164a34728b42726f399226b1a44bfde82cb534cdec07d"
    end
    if Hardware::CPU.intel?
      url "https://github.com/vfa-khuongdv/homebrew-redmine-tools/releases/download/v1.0.0/redmine-tools-linux-amd64.tar.gz"
      sha256 "bd0afde162f74c0c7ef164a34728b42726f399226b1a44bfde82cb534cdec07d"
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
