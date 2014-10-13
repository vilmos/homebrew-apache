require "formula"

class AprUtil < Formula
  homepage "https://apr.apache.org/"
  url "https://archive.apache.org/dist/apr/apr-util-1.5.4.tar.bz2"
  sha1 "b00038b5081472ed094ced28bcbf2b5bb56c589d"

  bottle do
    root_url "https://bitbucket.org/alanthing/homebrew-apache/downloads"
    sha1 "06fb57fdefd47e778c9a05344c1d83f52898cf32" => :lion
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
