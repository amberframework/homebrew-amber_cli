class Minecart < Formula
  desc "Crystal dependency manager with checksum locks and assistant setup"
  homepage "https://github.com/crimson-knight/shards"
  url "https://github.com/crimson-knight/shards/releases/download/v2025.11.25.8/minecart-source-2025.11.25.8.tar.gz"
  version "2025.11.25.8"
  sha256 "15c7c0af5f29dbd5d651fbfe90bfe1c0cd614a5e72a55ccacc2c246c6e1ed38f"
  license "Apache-2.0"

  depends_on "crystal"

  conflicts_with "shards-alpha", because: "both install shards-alpha"

  def install
    system "make", "bin/minecart", "bin/shards-alpha", "release=1"
    bin.install "bin/minecart"
    bin.install "bin/shards-alpha"
  end

  test do
    assert_match "Minecart 2025.11.25.8", shell_output("#{bin}/minecart --version")
    assert_path_exists bin/"shards-alpha"
  end
end
