class Minecart < Formula
  desc "Crystal dependency manager with checksum locks and assistant setup"
  homepage "https://github.com/crimson-knight/shards"
  url "https://github.com/crimson-knight/shards/releases/download/v2025.11.25.7/minecart-source-2025.11.25.7.tar.gz"
  version "2025.11.25.7"
  sha256 "987181366b4836a37f16f63138c37c37319f76a82e0dff062ca2caa15d37f9f2"
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
