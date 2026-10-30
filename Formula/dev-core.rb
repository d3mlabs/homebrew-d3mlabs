# Global dev CLI: finds repo with dev.yml, runs commands with pretty CLI (Frame, in-process Ruby).
#
# This is the GENERIC tool, org-blank by design: dev's source hardcodes no
# org content, and this formula ships none either. Org identity enters
# through a deployment formula (config.yml into etc/dev/ plus a dependency
# on this formula) — see `dev.rb` in this tap for the d3mlabs deployment,
# and dev's README, "Org configuration & deployment", for the adopter
# recipe. Individuals without an org can install this directly and write
# ~/.config/dev/config.yml by hand.
class DevCore < Formula
  desc "Find repo with dev.yml and run declared commands"
  homepage "https://github.com/d3mlabs/dev"
  url "https://github.com/d3mlabs/dev/archive/refs/tags/v0.7.0.tar.gz"
  sha256 "daec051177f08484e5e96be2a9efb1b6de0172de61e73016f807433ae089ac2c"

  # All of these are the tool's own runtime dependencies, not org choices:
  # git/gh back clone, plan sync, and dependency fetchers; ruby runs the CLI
  # itself (the bin/dev trampoline); shadowenv applies each project's
  # environment (every project command runs through `shadowenv exec`). A
  # project's own Ruby is a `ruby@X.Y.Z` pin from this tap that dev installs
  # as a dependency (dev ADR-0012), so no rbenv/ruby-build here.
  depends_on "gh"
  depends_on "git"
  depends_on "ruby"
  depends_on "shadowenv"

  # The macOS container engine dev owns: colima is the VM, and the docker CLI
  # + its buildx plugin replace the ones Docker Desktop bundled (`dev up`
  # registers the plugin and starts the VM). On Linux / WSL2 the engine is
  # the distro's dockerd + docker-ce-cli + docker-buildx-plugin, so these
  # stay out of the way there.
  on_macos do
    depends_on "colima"
    depends_on "docker"
    depends_on "docker-buildx"
  end

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
    # Vendor runtime gems into libexec, independent of the build machine's
    # gems. GEM_HOME/GEM_PATH are install-time only: at run time bin/dev
    # finds `libexec/specifications` beside itself and selects these gems
    # in-process (Gem.use_paths), so the installed command exports nothing —
    # a wrapper's GEM_HOME leaked into every child dev spawned (dev#180,
    # dev#274, dev#333).
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
    # VERSION is what `dev version` reads, and what a host dev compares
    # against when it provisions dev-core into a build container at its own
    # version (dev#218). Every release tarball carries it.
    (libexec/"dev").install "VERSION"
    bin.install_symlink libexec/"dev/bin/dev"
  end

  def caveats
    <<~EOS
      This is the org-blank tool. To adopt an org's configuration, install
      that org's deployment formula instead (d3mlabs: `brew install
      d3mlabs/d3mlabs/dev`). As an individual, configure dev by writing
      ~/.config/dev/config.yml — see the README for the available keys.
    EOS
  end

  test do
    # Outside a project dev is still a working CLI: `version` answers, and
    # the bare invocation lists the commands available there (exit 0).
    assert_match version.to_s, shell_output("#{bin}/dev version")
    assert_match "outside a project", shell_output("#{bin}/dev 2>&1")
  end
end
