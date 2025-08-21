class RedmineTools < Formula
  desc "Command-line tool for working with Redmine projects"
  homepage "https://github.com/vfa-khuongdv/homebrew-redmine-tools"
  version "1.0.4"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/vfa-khuongdv/homebrew-redmine-tools/releases/download/v1.0.4/redmine-tools-darwin-arm64.tar.gz"
      sha256 "1d3d743af02b76cf8aca8357751d086597788b27d4940e2dabc8dca5b110a109
777485b6dedd07f67fa4a43153d7bbba52f784664240e89188f680e4bd86e377"
    end
    if Hardware::CPU.intel?
      url "https://github.com/vfa-khuongdv/homebrew-redmine-tools/releases/download/v1.0.4/redmine-tools-darwin-amd64.tar.gz"
      sha256 "42c704671c3fa7c7d2c47b242cd879a9d36d50e81d9232cc1f910b10f57b06ad
eef917955b4735bd09678369c53ac036b95b6acb99ffd1722d8f0cf2162ba509"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.arch_64_bit?
      url "https://github.com/vfa-khuongdv/homebrew-redmine-tools/releases/download/v1.0.4/redmine-tools-linux-arm64.tar.gz"
      sha256 "79be2329007eb11de902d334f921d58fd6b82129feb6158cbc8a7c932ab84243
476b7136f1dd51318eee3cfbd650f3d7030b4c1e88f4c2b149f713b75135d2e7"
    end
    if Hardware::CPU.intel?
      url "https://github.com/vfa-khuongdv/homebrew-redmine-tools/releases/download/v1.0.4/redmine-tools-linux-amd64.tar.gz"
      sha256 "99056f3e3fe9d93f33fe7130bc319f30beff526e87deb42aac90184d80fd96ca
79888c10202055ab403fc7dd5075370724d17e6294eea3358db0693c9f8d6d75"
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
