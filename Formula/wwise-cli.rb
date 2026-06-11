class WwiseCli < Formula
  desc "CLI tool for downloading and integrating Wwise SDK"
  homepage "https://github.com/mircearoata/wwise-cli"
  # d3mlabs fork: adds --token / WWISE_TOKEN to bypass the legacy
  # email/password login, which Audiokinetic's Cognito migration broke for
  # newer accounts. Tracking https://github.com/mircearoata/wwise-cli (PR
  # pending); revert to upstream once the token flow merges.
  url "https://github.com/d3mlabs/wwise-cli/archive/refs/tags/v0.2.3-token.1.tar.gz"
  version "0.2.3-token.1"
  sha256 "c0717832f085f88d07cf6478cff698e359a8270602390ad96c18e8610b47ca45"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w")
  end

  test do
    system "#{bin}/wwise-cli", "--help"
  end
end
