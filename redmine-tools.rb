class RedmineTools < Formula
  desc "Command-line tool for working with Redmine projects"
  homepage "https://github.com/vfa-khuongdv/homebrew-redmine-tools"
  version "1.0.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/vfa-khuongdv/homebrew-redmine-tools/releases/download/v1.0.1/redmine-tools-darwin-arm64.tar.gz"
      sha256 "f2fffa2473a4fd1defad5e9962f65202cabe629207e74264b63e262c96c5487b"
    end
    if Hardware::CPU.intel?
      url "https://github.com/vfa-khuongdv/homebrew-redmine-tools/releases/download/v1.0.1/redmine-tools-darwin-amd64.tar.gz"
      sha256 "26b5488a908b18e27b8e420beeda70ff73f5d9bc7442a045999e813faaab8a3e"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.arch_64_bit?
      url "https://github.com/vfa-khuongdv/homebrew-redmine-tools/releases/download/v1.0.1/redmine-tools-linux-arm64.tar.gz"
      sha256 "815e8c2d3a0aa2f3007a52eb86a17c448435e6461032b24761d464100d80f990"
    end
    if Hardware::CPU.intel?
      url "https://github.com/vfa-khuongdv/homebrew-redmine-tools/releases/download/v1.0.1/redmine-tools-linux-amd64.tar.gz"
      sha256 "6799eaeb30b5851605a9849b5953f97edfae4208be9fc08a6b6ec20d036e6cb3"
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
