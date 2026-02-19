class Axslcc < Formula
  desc "Axmol shader compiler (axslcc)"
  homepage "https://github.com/simdsoft/axslcc"
  version "1.14.0"

  on_linux do
    url "https://github.com/simdsoft/axslcc/releases/download/v1.14.0/axslcc-1.14.0-linux.tar.gz"
    sha256 "c8a9113f942f3025aaa5dfd46440b3256915a5b5a02fade6b2884bb4be69d7a2"
  end

  on_macos do
    url "https://github.com/simdsoft/axslcc/releases/download/v1.14.0/axslcc-1.14.0-osx-x64.tar.gz"
    sha256 "648e8a8d5630c878413585c09b78bad442442d03ca25a2caaf5651ef4531aab5"
  end

  def install
    # Tarballs contain a single 'axslcc' binary at the top level.
    bin.install "axslcc"
  end

  test do
    system "#{bin}/axslcc", "--version"
  end
end
