class AmberCli < Formula
  desc "Command-line tool and LSP for the Amber web framework (Crystal)"
  homepage "https://amberframework.org"
  version "2.0.6"
  license "MIT"

  depends_on "crystal"
  depends_on "libpq"
  depends_on "mysql-client"
  depends_on "openssl@3"
  depends_on "sqlite"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/amberframework/amber_cli/releases/download/v2.0.6/amber_cli-darwin-arm64.tar.gz"
      sha256 "4e47aad856427a54799e4275b79deaaaf5e569b32559fae798d99af0eedd6bb0"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/amberframework/amber_cli/releases/download/v2.0.6/amber_cli-linux-x86_64.tar.gz"
      sha256 "74cb45729d8c1f208d678003a81017df4832f7dad38e9103ee17583feddd4f73"
    elsif Hardware::CPU.arm?
      url "https://github.com/amberframework/amber_cli/releases/download/v2.0.6/amber_cli-linux-arm64.tar.gz"
      sha256 "8b914f3cacf8432dee388af4973bb68984676314a8a0f162ac7b6a9040412ac0"
    end
  end

  conflicts_with "amber", because: "both install the amber binary"

  def install
    bin.install "amber"
    bin.install "amber-lsp"
  end

  def caveats
    <<~EOS
      AI agent workflow (optional): the incremental compiler and fast rebuilds
      use the crystal-alpha command, which is not part of this formula. Install
      it with:
        brew install crimson-knight/agent-crystal/agent-crystal
      It builds from source and takes about 30 minutes. Amber CLI works without
      it, using the Crystal compiler from Homebrew.
    EOS
  end

  test do
    assert_match "Amber CLI v2.0.6", shell_output("#{bin}/amber --version")
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
