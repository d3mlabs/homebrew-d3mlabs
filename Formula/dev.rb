# Global dev CLI: finds git repo root with dev.yml and executes declared commands.
# Install: brew tap d3mlabs/d3mlabs && brew install d3mlabs/d3mlabs/dev
class Dev < Formula
  desc "Find git repo with dev.yml and run declared commands (d3mlabs convention)"
  homepage "https://github.com/d3mlabs/dev"
  version "0.1.0"
  depends_on "ruby"
  # Point at tagged release tarball from d3mlabs/dev repo
  url "https://github.com/d3mlabs/dev/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "b14942d2c59d1a6aeb8119a450e8271b61dded2ecada03a03740d035033918ea"

  def install
    bin.install "dev"
  end

  test do
    # In an empty dir (no git repo): expect clear error and exit 1
    output = shell_output("#{bin}/dev 2>&1", 1)
    assert_match(/no git repo \(with dev\.yml\) found/, output)
  end
end
