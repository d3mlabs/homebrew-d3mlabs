# clang-format 18.1.8, pinned. One formula per version; add clang-format@X.Y.Z.rb
# for new versions (do NOT mutate this one). Formatting output changes between
# clang-format releases, so every machine and CI must run the exact same version
# to avoid spurious diffs; this is how repos pin it through the org package manager
# instead of an ad-hoc `pip install clang-format==...`.
#
# Source: the ssciwr clang-format wheel (https://github.com/ssciwr/clang-format-wheel),
# built from official LLVM sources in public CI and published to PyPI. A wheel is
# just a zip; we fetch the sha-pinned wheel and lift the single bundled binary. This
# is NOT pip -- no Python, no resolver -- brew downloads a static file and unzips it.
# A 4 MB binary installs in seconds, unlike fetching all of LLVM.
#
# Bump recipe (rare, deliberate): create clang-format@<new>.rb with the per-platform
# wheel url + sha256 from `https://pypi.org/pypi/clang-format/<new>/json` (the
# bdist_wheel entries for macosx_11_0_arm64, macosx_10_9_x86_64, and
# manylinux_2_17_x86_64), or use `brew bump-formula-pr`.
class ClangFormatAT1818 < Formula
  desc "Pinned standalone clang-format 18.1.8 (LLVM C/C++ formatter)"
  homepage "https://github.com/ssciwr/clang-format-wheel"
  version "18.1.8"

  # :nounzip keeps the .whl as a file (Homebrew does not recognize the extension
  # as an archive, so we unpack it deterministically in install rather than rely
  # on auto-detection).
  on_macos do
    on_arm do
      url "https://files.pythonhosted.org/packages/18/4c/5f82861a89cbdd99b1525c353a35a034d2eb3ee392348b4ba713dc697a3e/clang_format-18.1.8-py2.py3-none-macosx_11_0_arm64.whl", using: :nounzip
      sha256 "4be2b5d983a0cc1ef90a224b599f5928d82ce31154ba69accfdcb670aea62f40"
    end
    on_intel do
      url "https://files.pythonhosted.org/packages/15/36/974be8a5b9776d39a2f96746db80c3d963b232ab9660fd0891765b5b6a17/clang_format-18.1.8-py2.py3-none-macosx_10_9_x86_64.whl", using: :nounzip
      sha256 "7c41e2521b7e6ba706cc5d1c3e95eed9a41c1522244e23624e1518991f02a604"
    end
  end

  on_linux do
    on_intel do
      url "https://files.pythonhosted.org/packages/05/a8/d94adc8025c6a313bed5da994c421fff7dc4288d20028b309b1d45e15032/clang_format-18.1.8-py2.py3-none-manylinux_2_17_x86_64.manylinux2014_x86_64.whl", using: :nounzip
      sha256 "2de122b8aa78ba49e326f974131caab2c79f4ae877c227cd4e3e5d82a98d21e5"
    end
  end

  def install
    # The wheel is a zip; unpack it and install just the bundled binary as plain
    # `clang-format`.
    system "unzip", "-q", Dir["*.whl"].first
    bin.install "clang_format/data/bin/clang-format"
  end

  test do
    assert_match "18.1.8", shell_output("#{bin}/clang-format --version")
  end
end
