# PowerShell (pwsh) 7.4.0 for Linux. One formula per version; add powershell@X.Y.Z.rb for new versions.
# macOS uses the cask (script installs via dev.cask in dependencies.yaml); this formula is Linux-only.
class PowershellAT740 < Formula
  desc "PowerShell (pwsh) 7.4.0 - cross-platform shell"
  homepage "https://github.com/PowerShell/PowerShell"
  version "7.4.0"

  on_linux do
    url "https://github.com/PowerShell/PowerShell/releases/download/v7.4.0/powershell_7.4.0-1.deb_amd64.deb"
    sha256 "550331e243a7311e1bf0ca83d8c96c5e78ba82a765c4a9ba34aa0db6eb9a9f22"
  end

  def install
    on_linux do
      deb = Pathname.glob(buildpath/"*.deb").first
      odie "No .deb found" unless deb&.exist?
      system "dpkg", "-i", deb
    end
  end

  test do
    system "pwsh", "-Command", "Write-Host 'OK'"
  end
end
