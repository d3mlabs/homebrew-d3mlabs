# Global dev CLI: finds repo with dev.yml, runs commands with pretty CLI (Frame, in-process Ruby).
# Install: brew tap d3mlabs/d3mlabs && brew install d3mlabs/d3mlabs/dev
class Dev < Formula
  desc "Find repo with dev.yml and run declared commands (d3mlabs convention)"
  homepage "https://github.com/d3mlabs/dev"
  version "0.2.39"
  url "https://github.com/d3mlabs/dev/archive/refs/tags/v0.2.39.tar.gz"
  sha256 "e4507060a210ffa43f30f797852eb490c48ab33f60cbe786be070242669e8a14"

  depends_on "ruby"
  depends_on "rbenv"
  depends_on "ruby-build"
  depends_on "shadowenv"

  def install
    # GEM_PATH must also point at libexec: dependency resolution consults the
    # ambient gem path, so without this, deps already present on the build
    # machine (e.g. in Homebrew ruby's site gems) would be skipped instead of
    # vendored.
    ENV["GEM_HOME"] = libexec
    ENV["GEM_PATH"] = libexec

    # Vendor runtime dependencies (declared in dev.gemspec) into libexec by
    # building and installing dev as a gem. Unlike `bundle install` with
    # system gems, this guarantees every runtime dep lands in libexec
    # regardless of which gems the build machine already has, so the wrapper
    # works under any >= 2.7 ruby (rbenv, shadowenv-pinned, or Homebrew).
    system "gem", "build", "dev.gemspec", "--output", "dev.gem"
    system "gem", "install", "--no-document", "dev.gem"

    (libexec/"dev").install "bin", "src", "lib"
    (bin/"dev").write_env_script(libexec/"dev/bin/dev",
      GEM_HOME: libexec)
  end

  test do
    output = shell_output("#{bin}/dev 2>&1", 1)
    assert_match(/no dev\.yml/, output)
  end
end
