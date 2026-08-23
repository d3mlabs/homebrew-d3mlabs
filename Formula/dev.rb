# The d3mlabs DEPLOYMENT of dev: the generic tool (dev-core) plus the
# d3mlabs org identity, in one install command.
# Install: brew tap d3mlabs/d3mlabs && brew install d3mlabs/d3mlabs/dev
#
# The tool itself lives in dev-core.rb; this formula ships only the org
# config.yml into etc/dev/ (the system layer of dev's layered settings)
# and the dependency edge. Adopting orgs publish the same shape in their
# own tap — a formula named `dev` depending on d3mlabs/d3mlabs/dev-core —
# so every org's install is `brew install <org>/<tap>/dev`. See dev's
# README, "Org configuration & deployment".
class Dev < Formula
  desc "D3mlabs deployment of the dev CLI (tool plus org configuration)"
  homepage "https://github.com/d3mlabs/dev"
  # Same release tarball as dev-core: the deployment versions in lockstep
  # with the tool, and the tarball provides the keg payload (docs) brew
  # requires of every formula.
  url "https://github.com/d3mlabs/dev/archive/refs/tags/v0.2.79.tar.gz"
  sha256 "9793b1b0694baa2b380cccfa2fb5d7e90ef7179868d871999815dbcc392b03ee"

  depends_on "d3mlabs/d3mlabs/dev-core"

  def install
    doc.install "README.md"

    # The d3mlabs org identity, into $(brew --prefix)/etc/dev/config.yml —
    # the system layer of dev's layered settings (ENV > user file > this).
    # etc files are brew-protected: a locally-modified copy survives
    # upgrades untouched (the fresh one lands beside it as .default).
    (buildpath/"config.yml").write <<~YAML
      plans_repo: d3mlabs/plans
      knowledge_repo: d3mlabs/knowledge
      baseline_repo: d3mlabs/knowledge
      default_org: d3mlabs
    YAML
    pkgetc.install "config.yml"
  end

  # No auto-converge in post_install: it would nest a brew invocation
  # inside brew (deadlock-prone). The caveat prints on install and upgrade.
  def caveats
    <<~EOS
      Run `dev up` to converge the d3mlabs host baseline (git, gh, rbenv,
      shadowenv, the Cursor agent CLI). It works from any directory; inside
      a project it also provisions that project.
    EOS
  end

  test do
    assert_path_exists etc/"dev/config.yml"
  end
end
