class RedmineTools < Formula
  desc "Command-line tool for working with Redmine projects"
  homepage "https://github.com/vfa-khuongdv/homebrew-redmine-tools"
  url "https://github.com/vfa-khuongdv/homebrew-redmine-tools/archive/v1.0.0.tar.gz"
  sha256 "91f94d9211fdb98f79ee146c59d7067a47f2d9fca0ea8345cc0f6df4903115da"
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
