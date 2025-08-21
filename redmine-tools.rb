class RedmineTools < Formula
  desc "Command-line tool for working with Redmine projects"
  homepage "https://github.com/vfa-khuongdv/homebrew-redmine-tools"
  version "1.0.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/vfa-khuongdv/homebrew-redmine-tools/releases/download/v1.0.0/redmine-tools-darwin-arm64.tar.gz"
      sha256 "027190a8168d459bca421cbe861208f55297b828c818f8b1d9abd9cec24eb6ef
fd10686678a41dfb15188aaa8045ec3c3a595847c0efa36da533f499ec6f69f5"
    end
    if Hardware::CPU.intel?
      url "https://github.com/vfa-khuongdv/homebrew-redmine-tools/releases/download/v1.0.0/redmine-tools-darwin-amd64.tar.gz"
      sha256 "15274ba4f40dbaf0ec7e976dc99f11cd8e88151f4d73f1b10fb48535fa86fffc
665a38a3aa6097dfc9826842c453d41d32d7a7ea555b6f90f61569dd9ff85df4"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.arch_64_bit?
      url "https://github.com/vfa-khuongdv/homebrew-redmine-tools/releases/download/v1.0.0/redmine-tools-linux-arm64.tar.gz"
      sha256 "22267687891a34b8092a435930bb17460a949d31df07cf6fe238ecbf34ec8211
b35e1e27048641b6e9e4b2acf799a3dfad0bf513c25e1c93feeec1ee3b42a27b"
    end
    if Hardware::CPU.intel?
      url "https://github.com/vfa-khuongdv/homebrew-redmine-tools/releases/download/v1.0.0/redmine-tools-linux-amd64.tar.gz"
      sha256 "015580a21a20d3696b2136807f4f289982f41d1842b7fa215f947cb64e1dcce0
a12182fc134413b8b8f89940d2424dfee18bf6a31253fec4cede70956fab4d5f"
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
