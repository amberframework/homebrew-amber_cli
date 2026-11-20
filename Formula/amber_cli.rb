class AmberCli < Formula
  desc "Command-line tool and LSP for the Amber web framework (Crystal)"
  homepage "https://amberframework.org"
  url "https://github.com/amberframework/amber_cli/releases/download/v2.0.11/amber_cli-source-2.0.11.tar.gz"
  # Published asset of CLI tag v2.0.11 (commit 72df758d64a05a5d12d593dd5c9632daa00b484a); its contents equal that tree.
  sha256 "282de3d6a43b315e578ef9e9ce3442114764942f04208b3f9d90b6ab11af0387"
  license "MIT"

  depends_on "crystal"
  depends_on "libpq"
  depends_on "minecart"
  depends_on "mysql-client"
  depends_on "openssl@3"
  depends_on "sqlite"

  conflicts_with "amber", because: "both install the amber binary"

  def install
    ENV["SHARDS_CACHE_PATH"] = (buildpath/".minecart-cache").to_s
    ENV["CRYSTAL_CACHE_DIR"] = (buildpath/".crystal-cache").to_s
    # The source archive has no git checkout, so the formula names the commit amber-lsp reports.
    ENV["AMBER_CLI_BUILD_COMMIT"] = "72df758d64a0"
    # --frozen installs exactly shard.lock and verifies each shard's SHA-256 checksum.
    system "minecart", "install", "--frozen", "--production", "--skip-ai-docs",
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
    assert_match "Amber CLI v2.0.11", shell_output("#{bin}/amber --version")
    assert_equal "amber-lsp 1.0.0 (amber_cli 2.0.11, commit 72df758d64a0)\n",
                 shell_output("#{bin}/amber-lsp --version")
    assert_match "Minecart 2025.11.25.9", shell_output("#{formula_opt_bin("minecart")}/minecart --version")
    checksum_path = pkgshare/"checksums.txt"
    assert_equal "#{(bin/"amber-lsp").sha256}  amber-lsp\n", checksum_path.read
    api_card_path = pkgshare/"api/crystal.yml"
    assert_path_exists api_card_path
    assert_equal "80bf5dff1c453a94d91da83c0f99a093a2997f8070b6a04af4b02b8c03cd454d", api_card_path.sha256

    system bin/"amber", "new", "brew_test_app", "--type", "web", "-y", "--no-deps"
    shard = (testpath/"brew_test_app"/"shard.yml").read
    policy = (testpath/"brew_test_app"/".minecart-policy.yml").read
    assert_match "commit: f987f1bb19b789f8f14b000b6ee00ed496fe6cbb # v2.0.0-beta.11", shard
    assert_match "commit: 7bb4b9d45e74c490e6f3ad80cef8cc1cebd5b889 # v0.24.0", shard
    assert_match "commit: 73c89c3417a5282d9ac4179b283bcc660b7f898a # v0.38.0", shard
    assert_match "require_exact: true", policy

    crystal_alpha_directory = testpath/"tool-bin"
    crystal_alpha_directory.mkpath
    (crystal_alpha_directory/"crystal-alpha").make_symlink(formula_opt_bin("crystal")/"crystal")
    ENV.prepend_path "PATH", crystal_alpha_directory

    check_file = testpath/"formula_check.cr"
    check_file.write("puts \"amber-lsp formula check\"\n")
    check_output = IO.popen([bin/"amber-lsp", "--check", check_file.to_s], &:read)
    assert_match(/\Aamber-lsp: (?:covered|declined)\b/, check_output)

    # Lookup indexes a project, so run it inside the generated app.
    cd testpath/"brew_test_app" do
      lookup_output = shell_output("#{bin}/amber-lsp lookup 'Dir.mkdir_p'")
      assert_match(/amber-lsp lookup: found\b/, lookup_output)
      assert_match(/Dir\.mkdir_p/, lookup_output)
    end
  end
end
