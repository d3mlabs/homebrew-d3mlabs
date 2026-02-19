# Global dev CLI: finds repo with dev.yml, runs commands with pretty CLI (Frame, in-process Ruby).
# Install: brew tap d3mlabs/d3mlabs && brew install d3mlabs/d3mlabs/dev
class Dev < Formula
  desc "Find repo with dev.yml and run declared commands (d3mlabs convention)"
  homepage "https://github.com/d3mlabs/dev"
  version "0.2.1"
  depends_on "ruby"
  url "https://github.com/d3mlabs/dev/archive/refs/tags/v0.2.1.tar.gz"
  sha256 "edd84ade1578e26fedcb945715ee360313d936e6b0ba9144031e82be065ad896"

  def install
    bin.install "dev"
  end

  test do
    output = shell_output("#{bin}/dev 2>&1", 1)
    assert_match(/no dev\.yml found/, output)
  end
end
