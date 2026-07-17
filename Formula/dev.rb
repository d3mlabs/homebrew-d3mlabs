# Global dev CLI: finds repo with dev.yml, runs commands with pretty CLI (Frame, in-process Ruby).
# Install: brew tap d3mlabs/d3mlabs && brew install d3mlabs/d3mlabs/dev
class Dev < Formula
  desc "Find repo with dev.yml and run declared commands (d3mlabs convention)"
  homepage "https://github.com/d3mlabs/dev"
  url "https://github.com/d3mlabs/dev/archive/refs/tags/v0.2.69.tar.gz"
  sha256 "0cea3ced94259c4c64e3e14d000fcb38e161c49a2a54161a895f74a70ccfcc4e"

  depends_on "rbenv"
  depends_on "ruby"
  depends_on "ruby-build"
  depends_on "shadowenv"

  # Runtime gems (dev.gemspec). Vendored as resources so they're fetched
  # before Homebrew's network-less build sandbox and installed offline — a
  # plain `gem install` would reach rubygems.org mid-build and fail. Both are
  # dependency-free, so no transitive resources are needed.
  resource "cli-ui" do
    url "https://rubygems.org/downloads/cli-ui-2.7.0.gem"
    sha256 "e36147f2e8088796b996f0560f577bd1599f2b6aa3c374fe09fff59af5589c35"
  end

  resource "sorbet-runtime" do
    url "https://rubygems.org/downloads/sorbet-runtime-0.6.13295.gem"
    sha256 "c61a89c1a2c6ed79b4d38c64b9ce2c03de4d362e6803be2a871562000964114e"
  end

  def install
    # Vendor runtime gems into libexec. GEM_HOME/GEM_PATH point there so the
    # wrapper (run with GEM_HOME=libexec) resolves them under any >= 3.1 ruby
    # (rbenv, shadowenv-pinned, or Homebrew), independent of the build
    # machine's gems.
    ENV["GEM_HOME"] = libexec
    ENV["GEM_PATH"] = libexec

    # Homebrew fetches resources during the unsandboxed fetch phase, so
    # reference the already-downloaded file here. Calling r.fetch inside
    # install would re-download under the sandbox and fail.
    resources.each do |r|
      system "gem", "install", r.cached_download,
             "--no-document", "--ignore-dependencies", "--install-dir", libexec
    end

    (libexec/"dev").install "bin", "src", "lib"
    # share/ carries the ai-flow Cursor skill (symlinked into ~/.cursor/skills
    # by `dev plan`); conditional so the formula still installs tarballs
    # predating it.
    (libexec/"dev").install "share" if File.directory?("share")
    (bin/"dev").write_env_script(libexec/"dev/bin/dev", GEM_HOME: libexec)
  end

  test do
    output = shell_output("#{bin}/dev 2>&1", 1)
    assert_match(/no dev\.yml/, output)
  end
end
