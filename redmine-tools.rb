class RedmineTools < Formula
  desc "Command-line tool for working with Redmine projects"
  homepage "https://github.com/vfa-khuongdv/homebrew-redmine-tools"
  version "1.0.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/vfa-khuongdv/homebrew-redmine-tools/releases/download/v1.0.1/redmine-tools-darwin-arm64.tar.gz"
      sha256 "c15636f3e633700ca0c945379de235f70802b67a0f028e25abb3891133d38c56"
    end
    if Hardware::CPU.intel?
      url "https://github.com/vfa-khuongdv/homebrew-redmine-tools/releases/download/v1.0.1/redmine-tools-darwin-amd64.tar.gz"
      sha256 "90bcad7b0b0cfb17aec8167d978bc7110775cca2dab421cac320fa24170d7436"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.arch_64_bit?
      url "https://github.com/vfa-khuongdv/homebrew-redmine-tools/releases/download/v1.0.1/redmine-tools-linux-arm64.tar.gz"
      sha256 "161592fc9498fddf8951d33acf1718b54e1a111f290c12d7d5f3b08aa0bba60d"
    end
    if Hardware::CPU.intel?
      url "https://github.com/vfa-khuongdv/homebrew-redmine-tools/releases/download/v1.0.1/redmine-tools-linux-amd64.tar.gz"
      sha256 "2c83d83895dc60a7cf0e72058c51f465f984605261a95c965d87a7fc18485aa9"
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
