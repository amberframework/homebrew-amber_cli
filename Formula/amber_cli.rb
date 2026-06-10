class AmberCli < Formula
  desc "Command-line tool and LSP for the Amber web framework (Crystal)"
  homepage "https://amberframework.org"
  license "MIT"
  version "2.0.1"

  depends_on "crystal"
  depends_on "libpq"
  depends_on "mysql-client"
  depends_on "sqlite"

  conflicts_with "amber", because: "both install the amber binary"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/amberframework/amber_cli/releases/download/v2.0.1/amber_cli-darwin-arm64.tar.gz"
      sha256 "Not"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/amberframework/amber_cli/releases/download/v2.0.1/amber_cli-linux-x86_64.tar.gz"
      sha256 "Not"
    end
  end

  def install
    bin.install "amber"
    bin.install "amber-lsp"
  end

  test do
    system "#{bin}/amber", "--version"
    raise "amber-lsp binary is missing" unless (bin/"amber-lsp").exist?
    raise "amber-lsp binary is not executable" unless (bin/"amber-lsp").executable?
    system "#{bin}/amber", "new", "brew_test_app", "-y", "--no-deps"
    raise "Amber app scaffold did not generate shard.yml" unless (testpath/"brew_test_app"/"shard.yml").exist?
    raise "Amber app scaffold did not generate .amber.yml" unless (testpath/"brew_test_app"/".amber.yml").exist?
  end
end
