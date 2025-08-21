class RedmineTools < Formula
  desc "Command-line tool for working with Redmine projects"
  homepage "https://github.com/vfa-khuongdv/homebrew-redmine-tools"
  url "https://github.com/vfa-khuongdv/homebrew-redmine-tools/archive/v1.0.0.tar.gz"
  sha256 "bd0afde162f74c0c7ef164a34728b42726f399226b1a44bfde82cb534cdec07d"
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
