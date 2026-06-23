# clang-format 18.1.8, pinned. One formula per version; add clang-format@X.Y.Z.rb
# for new versions. Formatting output changes between clang-format releases, so
# every machine (and CI) must run the exact same version to avoid spurious diffs;
# this formula is how repos pin it through the org package manager instead of an
# ad-hoc `pip install clang-format==...`.
#
# Source: muttleyxd/clang-tools-static-binaries ships a single ~4 MB statically
# linked clang-format per LLVM major (the "-18" asset is the final 18.x release;
# verified `clang-format --version` == 18.1.8), pinned here to a specific release
# tag for reproducibility. A single binary installs in seconds in CI, unlike
# fetching all of LLVM.
class ClangFormatAT1818 < Formula
  desc "Pinned standalone clang-format 18.1.8 (LLVM C/C++ formatter)"
  homepage "https://github.com/muttleyxd/clang-tools-static-binaries"
  version "18.1.8"

  on_macos do
    on_arm do
      url "https://github.com/muttleyxd/clang-tools-static-binaries/releases/download/master-796e77c/clang-format-18_macos-arm-arm64"
      sha256 "12dcb6a2476f927d642b327313b9b435207ebaafaa8c9b021108285653a8c9c1"
    end
    on_intel do
      url "https://github.com/muttleyxd/clang-tools-static-binaries/releases/download/master-796e77c/clang-format-18_macosx-amd64"
      sha256 "1c976a12d8627a0cc5bc6e91436c40153ede3927e4ad855507a6bdec1972efcb"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/muttleyxd/clang-tools-static-binaries/releases/download/master-796e77c/clang-format-18_linux-amd64"
      sha256 "bef23637c7c7d1c127d52f6c691e55b6ead1ff00e8199a36ecfd19ff554037dd"
    end
  end

  def install
    # The release asset is a bare executable whose staged name carries the
    # platform suffix (clang-format-18_<platform>); install whichever one was
    # downloaded as plain `clang-format`.
    binary = Dir["#{buildpath}/clang-format-18_*"].first
    odie "no clang-format binary was downloaded" if binary.nil?

    bin.install binary => "clang-format"
  end

  test do
    assert_match "18.1.8", shell_output("#{bin}/clang-format --version")
  end
end
