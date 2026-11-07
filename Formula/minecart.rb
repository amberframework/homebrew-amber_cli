class Minecart < Formula
  desc "Crystal dependency manager with checksum locks and assistant setup"
  homepage "https://github.com/crimson-knight/shards"
  url "https://github.com/crimson-knight/shards/releases/download/v2025.11.25.9/minecart-source-2025.11.25.9.tar.gz"
  version "2025.11.25.9"
  sha256 "eea3951ec589fcf005517514a5b83d0d6702bd82e5e261ac0bf38d6900204ec2"
  license "Apache-2.0"

  depends_on "crystal"

  conflicts_with "shards-alpha", because: "both install shards-alpha"

  def install
    system "make", "bin/minecart", "bin/shards-alpha", "release=1"
    bin.install "bin/minecart"
    bin.install "bin/shards-alpha"
  end

  test do
    assert_match "Minecart 2025.11.25.9", shell_output("#{bin}/minecart --version")
    assert_path_exists bin/"shards-alpha"
  end
end
