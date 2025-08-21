class RedmineTools < Formula
  desc "Command-line tool for working with Redmine projects"
  homepage "https://github.com/khuongdv/redmine-tools"
  url "https://github.com/khuongdv/redmine-tools/archive/v1.0.0.tar.gz"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"
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
