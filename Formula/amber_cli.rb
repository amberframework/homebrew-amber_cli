class AmberCli < Formula
  desc "Command-line tool and LSP for the Amber web framework (Crystal)"
  homepage "https://amberframework.org"
  license "MIT"
  version "2.0.0"

  depends_on "crystal"
  depends_on "libpq"
  depends_on "mysql-client"
  depends_on "sqlite"

  conflicts_with "amber", because: "both install an  binary"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/amberframework/amber_cli/releases/download/v2.0.0/amber_cli-darwin-arm64.tar.gz"
      sha256 "56a79eb91ecdb7945e2c4206fee936bc97aba91b98b313a31fbc98fc9840a147"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/amberframework/amber_cli/releases/download/v2.0.0/amber_cli-linux-x86_64.tar.gz"
      sha256 "e49bfe355f89f588c270ca2b8edfc9604229bfee6fda896392cf354c7f585e10"
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
