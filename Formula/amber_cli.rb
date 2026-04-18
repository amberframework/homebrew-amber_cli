class AmberCli < Formula
  desc "Command-line tool and LSP for the Amber web framework (Crystal)"
  homepage "https://amberframework.org"
  license "MIT"
  version "0.0.1"

  depends_on "crystal"
  depends_on "libpq"
  depends_on "mysql-client"
  depends_on "sqlite"

  conflicts_with "amber", because: "both install an `amber` binary"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/amberframework/amber_cli/releases/download/v#{version}/amber_cli-darwin-arm64.tar.gz"
      sha256 "PLACEHOLDER"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/amberframework/amber_cli/releases/download/v#{version}/amber_cli-linux-x86_64.tar.gz"
      sha256 "PLACEHOLDER"
    end
  end

  def install
    bin.install "amber"
    bin.install "amber-lsp"
  end

  test do
    system "#{bin}/amber", "--version"
    assert_predicate bin/"amber-lsp", :exist?
    assert_predicate bin/"amber-lsp", :executable?
    system "#{bin}/amber", "new", "brew_test_app", "-y", "--no-deps"
    assert_predicate testpath/"brew_test_app"/"shard.yml", :exist?
    assert_predicate testpath/"brew_test_app"/".amber.yml", :exist?
  end
end
