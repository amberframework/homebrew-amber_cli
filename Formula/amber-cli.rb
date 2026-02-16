class AmberCli < Formula
  desc "Command-line tool and LSP for the Amber web framework (Crystal)"
  homepage "https://amberframework.org"
  license "MIT"
  version "0.0.1"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/crimson-knight/amber_cli/releases/download/v#{version}/amber-cli-darwin-arm64.tar.gz"
      sha256 "PLACEHOLDER"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/crimson-knight/amber_cli/releases/download/v#{version}/amber-cli-linux-x86_64.tar.gz"
      sha256 "PLACEHOLDER"
    end
  end

  def install
    bin.install "amber"
    bin.install "amber-lsp"
  end

  test do
    system "#{bin}/amber", "--version"
    system "#{bin}/amber-lsp", "--help"
  end
end
