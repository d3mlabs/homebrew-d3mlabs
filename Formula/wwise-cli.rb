class WwiseCli < Formula
  desc "CLI tool for downloading and integrating Wwise SDK"
  homepage "https://github.com/mircearoata/wwise-cli"
  url "https://github.com/mircearoata/wwise-cli/archive/refs/tags/v0.2.3.tar.gz"
  version "0.2.3"
  sha256 "8609209e187150244182f2507038063e96bc2107b43c45342d7d85d955720849"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w")
  end

  test do
    system "#{bin}/wwise-cli", "--help"
  end
end
