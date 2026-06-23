# Global dev CLI: finds repo with dev.yml, runs commands with pretty CLI (Frame, in-process Ruby).
# Install: brew tap d3mlabs/d3mlabs && brew install d3mlabs/d3mlabs/dev
class Dev < Formula
  desc "Find repo with dev.yml and run declared commands (d3mlabs convention)"
  homepage "https://github.com/d3mlabs/dev"
  url "https://github.com/d3mlabs/dev/archive/refs/tags/v0.2.44.tar.gz"
  sha256 "be776d458d9350c6bba6fd07ac298894b4261cb342aeeffe967e4e33cab55629"

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
    sha256 "be776d458d9350c6bba6fd07ac298894b4261cb342aeeffe967e4e33cab55629"
  end

  resource "sorbet-runtime" do
    url "https://rubygems.org/downloads/sorbet-runtime-0.6.13295.gem"
    sha256 "be776d458d9350c6bba6fd07ac298894b4261cb342aeeffe967e4e33cab55629"
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
    (bin/"dev").write_env_script(libexec/"dev/bin/dev", GEM_HOME: libexec)
  end

  test do
    output = shell_output("#{bin}/dev 2>&1", 1)
    assert_match(/no dev\.yml/, output)
  end
end
