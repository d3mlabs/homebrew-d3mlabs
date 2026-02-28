# Global dev CLI: finds repo with dev.yml, runs commands with pretty CLI (Frame, in-process Ruby).
# Install: brew tap d3mlabs/d3mlabs && brew install d3mlabs/d3mlabs/dev
class Dev < Formula
  desc "Find repo with dev.yml and run declared commands (d3mlabs convention)"
  homepage "https://github.com/d3mlabs/dev"
  version "0.2.18"
  url "https://github.com/d3mlabs/dev/archive/refs/tags/v0.2.18.tar.gz"
  sha256 "ddb911d526499bf59fe978e8c7dd8a27c038e6db16652ed72e8ff89d145e951b"

  depends_on "ruby"
  depends_on "rbenv"
  depends_on "ruby-build"
  depends_on "shadowenv"

  def install
    ENV["GEM_HOME"] = libexec
    ENV["BUNDLE_WITHOUT"] = "development test"

    system "bundle", "config", "set", "--local", "path.system", "true"
    system "bundle", "install"

    (libexec/"dev").install "bin", "src"
    (bin/"dev").write_env_script(libexec/"dev/bin/dev",
      GEM_HOME: libexec,
      PATH:     "#{Formula["ruby"].opt_bin}:#{libexec}/bin:$PATH")
  end

  test do
    output = shell_output("#{bin}/dev 2>&1", 1)
    assert_match(/no dev\.yml/, output)
  end
end
