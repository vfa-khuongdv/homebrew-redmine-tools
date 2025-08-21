class RedmineTools < Formula
  desc "Command-line tool for working with Redmine projects"
  homepage "https://github.com/vfa-khuongdv/homebrew-redmine-tools"
  version "1.0.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/vfa-khuongdv/homebrew-redmine-tools/releases/download/v1.0.0/redmine-tools-darwin-arm64.tar.gz"
      sha256 "b4f30114254b0182552fa1574ace5b9baac5852b574b2f67a2a9cc0a24d8f1c8"
    end
    if Hardware::CPU.intel?
      url "https://github.com/vfa-khuongdv/homebrew-redmine-tools/releases/download/v1.0.0/redmine-tools-darwin-amd64.tar.gz"
      sha256 "cf2aa28a51db1af3583dc6eb74c567b6309f12ea7899abaad6c94776acccf916"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.arch_64_bit?
      url "https://github.com/vfa-khuongdv/homebrew-redmine-tools/releases/download/v1.0.0/redmine-tools-linux-arm64.tar.gz"
      sha256 "3f610b707add0d415a704bcdf72aa39ad956b3fc93f171e65d00d31737dd1ae1"
    end
    if Hardware::CPU.intel?
      url "https://github.com/vfa-khuongdv/homebrew-redmine-tools/releases/download/v1.0.0/redmine-tools-linux-amd64.tar.gz"
      sha256 "b0210eb9f327805250ef3da4df71641ad6bc47ff55845ded2c8015cb38f988da"
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
