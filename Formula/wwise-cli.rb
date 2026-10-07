class WwiseCli < Formula
  desc "CLI tool for downloading and integrating Wwise SDK"
  homepage "https://github.com/mircearoata/wwise-cli"
  # d3mlabs fork of upstream v0.2.4 (https://github.com/d3mlabs/wwise-cli):
  # builds on macOS; caches the version manifest and adds --offline so a
  # prewarmed cache can be integrated with no login; adds
  # fetch-ue-integration to fill that cache without a UE project. dev's
  # `wwise` dependency source drives the host side; a build image runs
  # `integrate-ue --offline` against the mounted cache.
  url "https://github.com/d3mlabs/wwise-cli/archive/refs/tags/v0.2.4-d3m.1.tar.gz"
  version "0.2.4-d3m.1"
  sha256 "d68c95eaa3871e8080b2f0fca0612c28d99dc534fa64cc8fc807606131f6c46f"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w")
  end

  test do
    system "#{bin}/wwise-cli", "--help"
  end
end
