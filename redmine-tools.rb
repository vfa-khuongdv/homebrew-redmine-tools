class RedmineTools < Formula
  desc "Command-line tool for working with Redmine projects"
  homepage "https://github.com/vfa-khuongdv/homebrew-redmine-tools"
  version "1.0.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/vfa-khuongdv/homebrew-redmine-tools/releases/download/v1.0.1/redmine-tools-darwin-arm64.tar.gz"
      sha256 "9e5c9f4a7adca1590fdebdf985d4574c6d94c1b06d6939bfaef1379f4a154c71"
    end
    if Hardware::CPU.intel?
      url "https://github.com/vfa-khuongdv/homebrew-redmine-tools/releases/download/v1.0.1/redmine-tools-darwin-amd64.tar.gz"
      sha256 "cb40f37fb1d5e4a0f85e40558049f9a6370e63900ee945f8d22c7acc5ed854e9"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.arch_64_bit?
      url "https://github.com/vfa-khuongdv/homebrew-redmine-tools/releases/download/v1.0.1/redmine-tools-linux-arm64.tar.gz"
      sha256 "ae59c37ffcbf943bc33422d072f79a127e29561b42ae94a82c7954f7315cdfc4"
    end
    if Hardware::CPU.intel?
      url "https://github.com/vfa-khuongdv/homebrew-redmine-tools/releases/download/v1.0.1/redmine-tools-linux-amd64.tar.gz"
      sha256 "d600daba969fc441e2aeb1c43b061c70587e07e09b642ed1e7a4a6c181b7997d"
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
