class Minecart < Formula
  desc "Crystal dependency manager with checksum locks and assistant setup"
  homepage "https://github.com/crimson-knight/shards"
  url "https://github.com/crimson-knight/shards/releases/download/v2025.11.25.10/minecart-source-2025.11.25.10.tar.gz"
  # Published asset of tag v2025.11.25.10 (commit 3f64555a923f8e9f6a61b99d99d81b607a2ff7c4,
  # tree 23113d32d216c679b4327c6c0b0cc5633ece3397): git archive of that commit.
  version "2025.11.25.10"
  sha256 "fc6727f031031eef05da54054a331c8dc004f8fef23878a30f6d43f77c53e671"
  license "Apache-2.0"

  # Minecart builds with the AgentC compiler and runs it to read the Crystal
  # version and to build shard executables. Its Mica and Beryl stand in for
  # PCRE2, libyaml, zlib, libiconv and OpenSSL, so Minecart links only the
  # operating system.
  depends_on "crimson-knight/agent-crystal/agent-crystal"

  conflicts_with "shards-alpha", because: "both install shards-alpha"

  def install
    # Crystal programs trust $PWD for Dir.current; Homebrew can keep a caller's $PWD it may not read.
    ENV["PWD"] = buildpath.to_s
    ENV["CRYSTAL_CACHE_DIR"] = (buildpath/".crystal-cache").to_s
    system "make", "bin/minecart", "bin/shards-alpha", "release=1", "CRYSTAL=#{crystal_alpha}"
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
    assert_match "Minecart 2025.11.25.10", shell_output("#{bin}/minecart --version")
    assert_match "Minecart 2025.11.25.10", shell_output("#{bin}/shards-alpha --version 2>&1")

    # Minecart links the operating system's own libraries and nothing else.
    if OS.mac?
      list_of_lines = shell_output("otool -L #{libexec}/minecart").lines.drop(1)
      list_of_libraries = list_of_lines.map { |line| line.strip.split.first }
      assert_equal ["/usr/lib/libSystem.B.dylib"], list_of_libraries
    else
      list_of_lines = shell_output("ldd #{libexec}/minecart").lines
      list_of_libraries = list_of_lines.map { |line| File.basename(line.strip.split.first) }
      operating_system_library = /\A(linux-vdso\.so|libc\.so|libm\.so|libgcc_s\.so|libpthread\.so|libdl\.so|ld-linux)/
      assert_empty list_of_libraries.grep_v(operating_system_library)
    end

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
