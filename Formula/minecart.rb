class Minecart < Formula
  desc "Crystal dependency manager with checksum locks and assistant setup"
  homepage "https://github.com/crimson-knight/shards"
  url "https://github.com/crimson-knight/shards/releases/download/v2025.11.25.9/minecart-source-2025.11.25.9.tar.gz"
  version "2025.11.25.9"
  sha256 "eea3951ec589fcf005517514a5b83d0d6702bd82e5e261ac0bf38d6900204ec2"
  license "Apache-2.0"

  # Minecart builds with the AgentC compiler and runs it to read the Crystal
  # version and to build shard executables.
  depends_on "crimson-knight/agent-crystal/agent-crystal"
  depends_on "openssl@3"
  # Minecart's HTML-to-Markdown step matches with a backreference, which runs on PCRE2.
  depends_on "pcre2"

  conflicts_with "shards-alpha", because: "both install shards-alpha"

  def install
    # Crystal programs trust $PWD for Dir.current; Homebrew can keep a caller's $PWD it may not read.
    ENV["PWD"] = buildpath.to_s
    ENV["CRYSTAL_CACHE_DIR"] = (buildpath/".crystal-cache").to_s
    system "make", "bin/minecart", "bin/shards-alpha", "release=1",
           "CRYSTAL=#{crystal_alpha}", "FLAGS=-Duse_pcre2"
    libexec.install "bin/minecart", "bin/shards-alpha"
    # Minecart runs $CRYSTAL, so each command defaults it to the AgentC compiler.
    %w[minecart shards-alpha].each do |command_name|
      (bin/command_name).write_env_script libexec/command_name, CRYSTAL: "${CRYSTAL:-#{crystal_alpha}}"
    end
  end

  def crystal_alpha
    formula_opt_bin("crimson-knight/agent-crystal/agent-crystal")/"crystal-alpha"
  end

  test do
    # Homebrew can hand the test a $PWD it may not read, and Crystal's Dir.current stops on it.
    ENV["PWD"] = testpath.to_s
    ENV["SHARDS_CACHE_PATH"] = (testpath/"cache").to_s
    assert_match "Minecart 2025.11.25.9", shell_output("#{bin}/minecart --version")
    assert_match "Minecart 2025.11.25.9", shell_output("#{bin}/shards-alpha --version 2>&1")

    # A shard that requires a Crystal version makes Minecart ask the compiler for its own.
    (testpath/"shard.yml").write <<~YAML
      name: compiler_probe
      version: 0.1.0
      crystal: ">= 1.0.0"
    YAML
    system bin/"minecart", "install", "--skip-ai-docs"
    assert_path_exists testpath/"shard.lock"
  end
end
