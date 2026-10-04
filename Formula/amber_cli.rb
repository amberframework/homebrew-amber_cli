class AmberCli < Formula
  desc "Command-line tool and LSP for the Amber web framework (Crystal)"
  homepage "https://amberframework.org"
  url "https://github.com/amberframework/amber_cli/releases/download/v2.0.7/amber_cli-source-2.0.7.tar.gz"
  version "2.0.7"
  sha256 "95f26e540ef2db86604283f8ae418f22afed0a6fe67839758311bbdaab6d64b8"
  license "MIT"

  depends_on "crystal"
  depends_on "libpq"
  depends_on "minecart"
  depends_on "mysql-client"
  depends_on "openssl@3"
  depends_on "sqlite"

  conflicts_with "amber", because: "both install the amber binary"

  def fetch
    ENV["SHARDS_CACHE_PATH"] = (buildpath/".minecart-cache").to_s
    system "minecart", "install", "--frozen", "--production", "--skip-postinstall", "--skip-executables"
  end

  def install
    ENV["SHARDS_CACHE_PATH"] = (buildpath/".minecart-cache").to_s
    ENV["CRYSTAL_CACHE_DIR"] = (buildpath/".crystal-cache").to_s
    system "minecart", "install", "--frozen", "--production", "--local", "--skip-postinstall", "--skip-executables"
    system "crystal", "build", "src/amber_cli.cr", "--release", "-o", "amber"
    system "crystal", "build", "src/amber_lsp.cr", "--release", "-o", "amber-lsp"
    bin.install "amber", "amber-lsp"
  end

  test do
    assert_match "Amber CLI v2.0.7", shell_output("#{bin}/amber --version")
    assert_path_exists bin/"amber-lsp"
    assert_match "Minecart 2025.11.25.7", shell_output("#{formula_opt_bin("minecart")}/minecart --version")

    system bin/"amber", "new", "brew_test_app", "--type", "web", "-y", "--no-deps"
    shard = (testpath/"brew_test_app"/"shard.yml").read
    policy = (testpath/"brew_test_app"/".minecart-policy.yml").read
    assert_match "version: 2.0.0-beta.5", shard
    assert_match "version: 0.37.0", shard
    assert_match "require_exact: true", policy
  end
end
