class AmberCli < Formula
  desc "Command-line tool and LSP for the Amber web framework (Crystal)"
  homepage "https://amberframework.org"
  version "2.0.4"
  license "MIT"

  depends_on "crystal"
  depends_on "libpq"
  depends_on "mysql-client"
  depends_on "openssl@3"
  depends_on "sqlite"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/amberframework/amber_cli/releases/download/v2.0.4/amber_cli-darwin-arm64.tar.gz"
      sha256 "55f5f07c453b9a74ae67d275896d9e5322fe78137d31f0a7694fcf29f2d9b7dd"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/amberframework/amber_cli/releases/download/v2.0.4/amber_cli-linux-x86_64.tar.gz"
      sha256 "3ababddef0f81ca479b1a6636eb828b8743403485d4f7566e504824c613f995a"
    elsif Hardware::CPU.arm?
      url "https://github.com/amberframework/amber_cli/releases/download/v2.0.4/amber_cli-linux-arm64.tar.gz"
      sha256 "4852e9cf739f158798b8a3adb5e74e60a05817ad90171e3f8b9272d2ca9f4ab0"
    end
  end

  conflicts_with "amber", because: "both install the amber binary"

  def install
    bin.install "amber"
    bin.install "amber-lsp"
  end

  test do
    assert_match "Amber CLI v2.0.4", shell_output("#{bin}/amber --version")
    raise "amber-lsp binary is missing" unless (bin/"amber-lsp").exist?
    raise "amber-lsp binary is not executable" unless (bin/"amber-lsp").executable?

    system "#{bin}/amber", "new", "brew_test_app", "--type", "web", "-y", "--no-deps"
    raise "Amber app scaffold did not generate shard.yml" unless (testpath/"brew_test_app"/"shard.yml").exist?
    raise "Amber app scaffold did not generate .amber.yml" unless (testpath/"brew_test_app"/".amber.yml").exist?

    shard = (testpath/"brew_test_app"/"shard.yml").read
    config = (testpath/"brew_test_app"/".amber.yml").read
    assert_match "github: amberframework/amber", shard
    assert_match "version: 2.0.0-beta.", shard
    assert_match "grant:", shard
    assert_match "github: crimson-knight/grant", shard
    assert_match "sqlite3:", shard
    assert_match "database: sqlite", config
    assert_match "model: grant", config
    assert_match "template: ecr", config
    refute_match(/gemma:|slang/i, shard + config)
  end
end
