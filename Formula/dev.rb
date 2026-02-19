# Global dev CLI: finds repo with dev.yml, runs commands with pretty CLI (Frame, in-process Ruby).
# Install: brew tap d3mlabs/d3mlabs && brew install d3mlabs/d3mlabs/dev
class Dev < Formula
  desc "Find repo with dev.yml and run declared commands (d3mlabs convention)"
  homepage "https://github.com/d3mlabs/dev"
  version "0.2.3"
  depends_on "ruby"
  url "https://github.com/d3mlabs/dev/archive/refs/tags/v0.2.3.tar.gz"
  sha256 "7962555b18d33ed50be79a270bf557132f54fb4ffcba48e2ddb4aee1082e605a"

  def install
    bin.install "dev"
  end

  test do
    output = shell_output("#{bin}/dev 2>&1", 1)
    assert_match(/no dev\.yml found/, output)
  end
end
