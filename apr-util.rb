require "formula"

class AprUtil < Formula
  homepage "https://apr.apache.org/"
  url "https://archive.apache.org/dist/apr/apr-util-1.5.4.tar.bz2"
  sha1 "b00038b5081472ed094ced28bcbf2b5bb56c589d"

  bottle do
    root_url "https://bitbucket.org/alanthing/homebrew-apache/downloads"
    sha1 "2890f5b487951f68c42a0d240f126669dc9d4374" => :snow_leopard
    sha1 "06fb57fdefd47e778c9a05344c1d83f52898cf32" => :lion
    sha1 "0bad5cccdc7f33a541a0df5a2da14e0accc230b6" => :mountain_lion
    sha1 "12f13585ee31541e2104330d956a698793e6a4f2" => :mavericks
    sha1 "1d16b201833d6e9e62724b73a457865f070872a1" => :yosemite
  end

  keg_only :provided_by_osx

  depends_on "apr"
  depends_on "mysql-connector-c" => :optional

  def install
    # Compilation will not complete without deparallelize
    ENV.deparallelize

    args = %W[
      --disable-debug
      --prefix=#{prefix}
      --with-apr=#{Formula["apr"].opt_prefix}
    ]
    args << "--with-mysql=#{Formula["mysql-connector-c"].opt_prefix}" if build.with? "mysql-connector-c"

    system "./configure", *args
    system "make"
    system "make", "install"
  end
end
