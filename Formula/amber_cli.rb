class AmberCli < Formula
  desc "Command-line tool and LSP for the Amber web framework (Crystal)"
  homepage "https://amberframework.org"
  url "https://github.com/amberframework/amber_cli/releases/download/v2.0.17/amber_cli-source-2.0.17.tar.gz"
  # Published asset of CLI tag v2.0.17 (commit 20fbaeec4c88ecfd255d6e3b36623c023b908266); its contents equal that tree.
  sha256 "2617187e439c1e5c5716864ae8c0dc37690b3b085deda8676f046f9ba38ce65d"
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
    ENV["AMBER_CLI_BUILD_COMMIT"] = "20fbaeec4c88"
    # --frozen installs exactly shard.lock and verifies each shard's SHA-256 checksum.
    system "minecart", "install", "--frozen", "--production", "--skip-ai-docs",
           "--skip-postinstall", "--skip-executables"
    # amber calls no OpenSSL: Beryl does its cryptography and its database drivers
    # speak TLS 1.3 on Beryl, so the binary links no libssl or libcrypto.
    system "crystal", "build", "src/amber_cli.cr", "-Dwithout_openssl", "--release", "-o", "amber"
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
    assert_match "Amber CLI v2.0.17", shell_output("#{bin}/amber --version")
    assert_equal "amber-lsp 1.0.0 (amber_cli 2.0.17, commit 20fbaeec4c88)\n",
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
    assert_match "commit: 261cf2d3b4a6f3292fefb8113e71e0fe6900fcee # v2.0.0-beta.16", shard
    assert_match "commit: 4ba859e673a85de91b5dd815556ee83be3cc13b2 # v0.28.2", shard
    assert_match "commit: 9a0447c0e10d645307e8532c7794b89491281210 # v0.40.1", shard
    assert_match "require_exact: true", policy

    if OS.mac?
      linkage = shell_output("otool -L #{bin}/amber")
      refute_match(/libssl|libcrypto/, linkage)
    end

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
