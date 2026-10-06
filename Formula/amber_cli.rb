class AmberCli < Formula
  desc "Command-line tool and LSP for the Amber web framework (Crystal)"
  homepage "https://amberframework.org"
  url "https://github.com/amberframework/amber_cli/releases/download/v2.0.7/amber_cli-source-2.0.7.tar.gz"
  # Recomputed from git archive at CLI commit 647da53f785723bc90d466154fdaa1b4d86081ba.
  # The CI-built source archive must match this hash before publishing the release.
  sha256 "9954ef9a21e402f50767f13faeb2c614c84732326ddc3f1d49209f8546a7c1fd"
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
    system "minecart", "install", "--frozen", "--production", "--skip-ai-docs",
           "--skip-postinstall", "--skip-executables"
  end

  def install
    ENV["SHARDS_CACHE_PATH"] = (buildpath/".minecart-cache").to_s
    ENV["CRYSTAL_CACHE_DIR"] = (buildpath/".crystal-cache").to_s
    system "minecart", "install", "--frozen", "--production", "--local", "--skip-ai-docs",
           "--skip-postinstall", "--skip-executables"
    system "crystal", "build", "src/amber_cli.cr", "--release", "-o", "amber"
    system "crystal", "build", "src/amber_lsp.cr", "--release", "-o", "amber-lsp"
    bin.install "amber", "amber-lsp"

    checksum_directory = pkgshare
    checksum_directory.mkpath
    lsp_sha256 = (bin/"amber-lsp").sha256
    (checksum_directory/"checksums.txt").write("#{lsp_sha256}  amber-lsp\n")

    api_directory = pkgshare/"api"
    api_directory.mkpath
    api_directory.install buildpath/"src/amber_lsp/cards/crystal.yml"
  end

  test do
    assert_match "Amber CLI v2.0.7", shell_output("#{bin}/amber --version")
    assert_equal "amber-lsp 1.0.0 (amber_cli 2.0.7, commit unknown)\n",
                 shell_output("#{bin}/amber-lsp --version")
    assert_match "Minecart 2025.11.25.7", shell_output("#{formula_opt_bin("minecart")}/minecart --version")
    checksum_path = pkgshare/"checksums.txt"
    assert_equal "#{(bin/"amber-lsp").sha256}  amber-lsp\n", checksum_path.read
    api_card_path = pkgshare/"api/crystal.yml"
    assert_path_exists api_card_path
    assert_equal "80bf5dff1c453a94d91da83c0f99a093a2997f8070b6a04af4b02b8c03cd454d", api_card_path.sha256

    system bin/"amber", "new", "brew_test_app", "--type", "web", "-y", "--no-deps"
    shard = (testpath/"brew_test_app"/"shard.yml").read
    policy = (testpath/"brew_test_app"/".minecart-policy.yml").read
    assert_match "version: 2.0.0-beta.5", shard
    assert_match "version: 0.37.0", shard
    assert_match "require_exact: true", policy

    crystal_alpha_directory = testpath/"tool-bin"
    crystal_alpha_directory.mkpath
    (crystal_alpha_directory/"crystal-alpha").make_symlink(formula_opt_bin("crystal")/"crystal")
    ENV.prepend_path "PATH", crystal_alpha_directory

    check_file = testpath/"formula_check.cr"
    check_file.write("puts \"amber-lsp formula check\"\n")
    check_output = IO.popen([bin/"amber-lsp", "--check", check_file.to_s], &:read)
    assert_match(/\Aamber-lsp: (?:covered|declined)\b/, check_output)

    lookup_output = shell_output("#{bin}/amber-lsp lookup 'Dir.mkdir_p'")
    assert_match(/amber-lsp lookup: found\b/, lookup_output)
    assert_match(/Dir\.mkdir_p/, lookup_output)
  end
end
