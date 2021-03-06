class Oniguruma < Formula
  desc "Regular expressions library"
  homepage "https://github.com/kkos/oniguruma/"
  url "https://github.com/kkos/oniguruma/releases/download/v6.7.0/onig-6.7.0.tar.gz"
  sha256 "32d73c37d3c350b16287d86288f4bc98b95467fc37091cbcade60d83b01da073"

  bottle do
    cellar :any
    sha256 "577d595fce96056893075142ca5b2b27eb1bffa222e3c764da33859d84de2d6f" => :high_sierra
    sha256 "6bed9c7285ef0d2d2683d2817297e8ccaf17e9cfd3ffefb6e48c30bdea9ceaa0" => :sierra
    sha256 "0f8c5ff26eb18ea0966570bac198b730dbc3178ade9655f9ae9fd6b6bca867e9" => :el_capitan
    sha256 "1de3e0fdfcfe047b646983f7930e7e2891e4d8912ec42ad0b887e5d98915a466" => :x86_64_linux
  end

  def install
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    assert_match /#{prefix}/, shell_output("#{bin}/onig-config --prefix")
  end
end
