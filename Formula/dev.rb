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
  # Same release tarball as dev-core: the deployment versions in lockstep
  # with the tool, and the tarball provides the keg payload (docs) brew
  # requires of every formula.
  url "https://github.com/d3mlabs/dev/archive/refs/tags/v0.2.81.tar.gz"
  sha256 "a4a0c4984dbc1fd4545d23d4f9cd58296fc7438336b06ecb844682180cc0fb44"

  depends_on "d3mlabs/d3mlabs/dev-core"

  def install
    doc.install "README.md"

    # The d3mlabs org identity, into $(brew --prefix)/etc/dev/config.yml —
    # the system layer of dev's layered settings (ENV > user file > this).
    # etc files are brew-protected: a locally-modified copy survives
    # upgrades untouched (the fresh one lands beside it as .default).
    # deployment_formula is this formula's own name: it is how `dev up`
    # knows which formula to self-upgrade (the deployment names itself).
    (buildpath/"config.yml").write <<~YAML
      plans_repo: d3mlabs/plans
      knowledge_repo: d3mlabs/knowledge
      deployment_formula: d3mlabs/d3mlabs/dev
      default_org: d3mlabs
    YAML
    pkgetc.install "config.yml"

    # The org's host tooling beyond dev-core's own dependencies (the sets
    # are disjoint by design). `dev up` converges it via brew bundle.
    (buildpath/"Brewfile").write <<~BREWFILE
      cask "cursor-cli"
    BREWFILE
    pkgetc.install "Brewfile"
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
