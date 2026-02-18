# Global dev CLI: finds git repo root with dev.yml and executes declared commands.
# Install: brew tap d3mlabs/d3mlabs && brew install d3mlabs/d3mlabs/dev
class Dev < Formula
  desc "Find git repo with dev.yml and run declared commands (d3mlabs convention)"
  homepage "https://github.com/d3mlabs/dev"
  version "0.1.1"
  depends_on "ruby"
  # Point at tagged release tarball from d3mlabs/dev repo
  url "https://github.com/d3mlabs/dev/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "d42c0a05767f32566f9f85ceb3f2e4ba967e47ef8801cb2363ec73a19dd5b2e4"

  def install
    bin.install "dev"
  end

  test do
    # In an empty dir (no git repo): expect clear error and exit 1
    output = shell_output("#{bin}/dev 2>&1", 1)
    assert_match(/no git repo \(with dev\.yml\) found/, output)
  end
end
