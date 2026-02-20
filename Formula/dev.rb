# Global dev CLI: finds repo with dev.yml, runs commands with pretty CLI (Frame, in-process Ruby).
# Install: brew tap d3mlabs/d3mlabs && brew install d3mlabs/d3mlabs/dev
class Dev < Formula
  desc "Find repo with dev.yml and run declared commands (d3mlabs convention)"
  homepage "https://github.com/d3mlabs/dev"
  version "0.2.15"
  depends_on "ruby"
  depends_on "rbenv"
  depends_on "ruby-build"
  depends_on "shadowenv"
  url "https://github.com/d3mlabs/dev/archive/refs/tags/v0.2.15.tar.gz"
  sha256 "567ccd934778a5e49e879e30c657d49a3931a454ef0b68eef2e87cec9af15a5c"

  def install
    (libexec/"dev").install "bin", "src"
    bin.install_symlink libexec/"dev/bin/dev" => "dev"
  end

  test do
    output = shell_output("#{bin}/dev 2>&1", 1)
    assert_match(/no dev\.yml/, output)
  end
end
