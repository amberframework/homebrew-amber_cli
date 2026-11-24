class AmberCli < Formula
  desc "Command-line tool and LSP for the Amber web framework (Crystal)"
  homepage "https://amberframework.org"
  url "https://github.com/amberframework/amber_cli/releases/download/v2.0.16/amber_cli-source-2.0.16.tar.gz"
  # Published asset of CLI tag v2.0.16 (commit 86e46fbe18aeb79c73a14205694359ddc9bc17b4); its contents equal that tree.
  sha256 "a4f67fe609d3027189e2082abdd07cd88096088977627f6bffb6aafc73516e51"
  license "MIT"

  depends_on "crystal"
  depends_on "libpq"
  depends_on "minecart"
  depends_on "mysql-client"
  depends_on "openssl@3"
  depends_on "sqlite"

  conflicts_with "amber", because: "both install the amber binary"

  def install
    # Crystal programs trust $PWD for Dir.current and stop when they cannot stat it. Homebrew
    # keeps the caller's $PWD but denies reads under ~/Documents, ~/.claude and similar folders,
    # so a build started from one of them crashed minecart and crystal. Use the build directory.
    ENV["PWD"] = buildpath.to_s
    ENV["SHARDS_CACHE_PATH"] = (buildpath/".minecart-cache").to_s
    ENV["CRYSTAL_CACHE_DIR"] = (buildpath/".crystal-cache").to_s
    # The source archive has no git checkout, so the formula names the commit amber-lsp reports.
    ENV["AMBER_CLI_BUILD_COMMIT"] = "86e46fbe18ae"
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
    # Same $PWD reset as install: the test sandbox denies the same folders.
    ENV["PWD"] = testpath.to_s
    assert_match "Amber CLI v2.0.16", shell_output("#{bin}/amber --version")
    assert_equal "amber-lsp 1.0.0 (amber_cli 2.0.16, commit 86e46fbe18ae)\n",
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
    assert_match "commit: 0830e3fdbc5e05be851c3c7ae7bf03b67be10732 # v2.0.0-beta.15", shard
    assert_match "commit: b83a82f0261509d4ce1f26fadb318c8ba132a066 # v0.26.0", shard
    assert_match "commit: 84f3188239e43dc6e0bcfd2e72074e8ec67156cd # v0.40.0", shard
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
