# Global dev CLI: finds repo with dev.yml, runs commands with pretty CLI (Frame, in-process Ruby).
# Install: brew tap d3mlabs/d3mlabs && brew install d3mlabs/d3mlabs/dev
class Dev < Formula
  desc "Find repo with dev.yml and run declared commands (d3mlabs convention)"
  homepage "https://github.com/d3mlabs/dev"
  version "0.2.10"
  depends_on "ruby"
  depends_on "rbenv"
  depends_on "ruby-build"
  depends_on "shadowenv"
  url "https://github.com/d3mlabs/dev/archive/refs/tags/v0.2.10.tar.gz"
  sha256 "28b826926dfbe19db2ee88fb7cfbc5d425a7f9bc2ee29e6df85ab9e9f6b0151f"

  def install
    (libexec/"dev").install "dev", "src"
    bin.install_symlink libexec/"dev/dev" => "dev"
  end

  test do
    output = shell_output("#{bin}/dev 2>&1", 1)
    assert_match(/no dev\.yml found/, output)
  end
end
