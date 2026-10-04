class Minecart < Formula
  desc "Crystal dependency manager with checksum locks and assistant setup"
  homepage "https://github.com/crimson-knight/shards"
  url "https://github.com/crimson-knight/shards/releases/download/v2025.11.25.7/minecart-source-2025.11.25.7.tar.gz"
  version "2025.11.25.7"
  sha256 "ec583594cf1f030659c8caf05a89655fb9dfff8354922d77d3e687414e2cff9b"
  license "Apache-2.0"

  depends_on "crystal"

  conflicts_with "shards-alpha", because: "both install shards-alpha"

  def install
    system "make", "bin/minecart", "bin/shards-alpha", "release=1"
    bin.install "bin/minecart"
    bin.install "bin/shards-alpha"
  end

  test do
    assert_match "Minecart 2025.11.25.7", shell_output("#{bin}/minecart --version")
    assert_path_exists bin/"shards-alpha"
  end
end
