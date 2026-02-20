# Global dev CLI: finds repo with dev.yml, runs commands with pretty CLI (Frame, in-process Ruby).
# Install: brew tap d3mlabs/d3mlabs && brew install d3mlabs/d3mlabs/dev
class Dev < Formula
  desc "Find repo with dev.yml and run declared commands (d3mlabs convention)"
  homepage "https://github.com/d3mlabs/dev"
  version "0.2.4"
  depends_on "ruby"
  depends_on "shadowenv"
  url "https://github.com/d3mlabs/dev/archive/refs/tags/v0.2.4.tar.gz"
  sha256 "25f483aef6b862f0b2e15bad9c6cb9475b377115ce24c041bebaf5cd49a4ef4a"

  def install
    bin.install "dev"
  end

  test do
    output = shell_output("#{bin}/dev 2>&1", 1)
    assert_match(/no dev\.yml found/, output)
  end
end
