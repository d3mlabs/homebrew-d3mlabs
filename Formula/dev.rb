# The d3mlabs DEPLOYMENT of dev: the generic tool (dev-core) plus the
# d3mlabs org identity, in one install command.
# Install: brew tap d3mlabs/d3mlabs && brew install d3mlabs/d3mlabs/dev
#
# The tool itself lives in dev-core.rb; this formula ships only the org
# payload into etc/dev/ — the config.yml (the system layer of dev's
# layered settings) and the Brewfile (the org's host tooling, converged
# by `dev up` via brew bundle) — plus the dependency edge. Adopting orgs
# publish the same shape in their own tap — a formula named `dev`
# depending on d3mlabs/d3mlabs/dev-core — so every org's install is
# `brew install <org>/<tap>/dev`. See dev's README, "Org configuration &
# deployment" and "Host tooling: the Brewfile contract".
class Dev < Formula
  desc "D3mlabs deployment of the dev CLI (tool plus org configuration)"
  homepage "https://github.com/d3mlabs/dev"
  # The `dev` archive of dev's own GitHub release (dev#429): the org
  # payload, built by dev's bin/install-deployment and packaged by
  # `dev release`. `dev deploy brew` rewrites this url/sha256 pair on each
  # release; the deployment versions in lockstep with dev-core.
  url "https://github.com/d3mlabs/dev/releases/download/v0.8.9/dev-0.8.9.zip"
  sha256 "1dce57b879bc4d981ffc6305fbafd6ea54e629d500fa1812e61c8ed91d78c9a4"

  depends_on "d3mlabs/d3mlabs/dev-core"

  def install
    # The keg payload: pkgetc lands outside the keg, and brew refuses an
    # empty one — so the archive carries the docs too (dev#517).
    doc.install "README.md", "LICENSE"

    # The d3mlabs org identity (dev's deploy/d3mlabs/), into
    # $(brew --prefix)/etc/dev/: config.yml is the system layer of dev's
    # layered settings (ENV > user file > this) — its deployment_formula
    # names this formula, which is how `dev up` knows what to
    # self-upgrade; the Brewfile is the org's host tooling beyond
    # dev-core's own dependencies, converged by `dev up` via brew bundle.
    # etc files are brew-protected: a locally-modified copy survives
    # upgrades untouched (the fresh one lands beside it as .default).
    pkgetc.install "config.yml", "Brewfile"
  end

  # No auto-converge in post_install: it would nest a brew invocation
  # inside brew (deadlock-prone). The caveat prints on install and upgrade.
  def caveats
    <<~EOS
      Run `dev up` to converge the d3mlabs host tooling (Brewfile: the
      Cursor agent CLI). It works from any directory; inside a project it
      also provisions that project.
    EOS
  end

  test do
    assert_path_exists etc/"dev/config.yml"
    assert_path_exists etc/"dev/Brewfile"
  end
end
