class RedmineTools < Formula
  desc "Command-line tool for working with Redmine projects"
  homepage "https://github.com/vfa-khuongdv/homebrew-redmine-tools"
  version "1.0.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/vfa-khuongdv/homebrew-redmine-tools/releases/download/v1.0.1/redmine-tools-darwin-arm64.tar.gz"
      sha256 "9e5c9f4a7adca1590fdebdf985d4574c6d94c1b06d6939bfaef1379f4a154c71
9449299a5ca22ad59ade3ed9529e891f39c26e52188538c4fe6fdf07a4889bc6"
    end
    if Hardware::CPU.intel?
      url "https://github.com/vfa-khuongdv/homebrew-redmine-tools/releases/download/v1.0.1/redmine-tools-darwin-amd64.tar.gz"
      sha256 "cb40f37fb1d5e4a0f85e40558049f9a6370e63900ee945f8d22c7acc5ed854e9
bbebb28a45792f8b262d2269d3dbc01c09502f1eea5a788af3a7660b2cfb8edb"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.arch_64_bit?
      url "https://github.com/vfa-khuongdv/homebrew-redmine-tools/releases/download/v1.0.1/redmine-tools-linux-arm64.tar.gz"
      sha256 "ae59c37ffcbf943bc33422d072f79a127e29561b42ae94a82c7954f7315cdfc4
1521ac0f6b62cf6ffd7966ab1b4ede761a4b205d5131671d3e7673abc8058c81"
    end
    if Hardware::CPU.intel?
      url "https://github.com/vfa-khuongdv/homebrew-redmine-tools/releases/download/v1.0.1/redmine-tools-linux-amd64.tar.gz"
      sha256 "d600daba969fc441e2aeb1c43b061c70587e07e09b642ed1e7a4a6c181b7997d
b2e4b028ecda5411bcc76b1b2c2c0a381359e5d098e0e17d1304a3e7e4b3e3b5"
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
