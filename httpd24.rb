require "formula"

class Httpd24 < Formula
  homepage "https://httpd.apache.org/"
  url "https://www.apache.org/dist/httpd/httpd-2.4.9.tar.bz2"
  sha1 "646aedbf59519e914c424b3a85d846bf189be3f4"

  skip_clean :la

  depends_on "pcre" if build.with? "brewed-pcre"
  depends_on "openssl" if build.with? "brewed-openssl"

  if build.with? "brewed-apr"
    depends_on "homebrew/dupes/apr"
    depends_on "homebrew/dupes/apr-util"
  end

  def install
    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --prefix=#{prefix}
      --mandir=#{man}
      --localstatedir=#{var}/apache2
      --sysconfdir=#{etc}/apache2
      --enable-layout=GNU
      --enable-mods-shared=all
      --with-mpm=prefork
      --disable-unique-id
      --enable-ssl
      --enable-dav
      --enable-cache
      --enable-proxy
      --enable-logio
      --enable-deflate
      --enable-cgi
      --enable-cgid
      --enable-suexec
      --enable-rewrite
    ]

    if build.with? "brewed-openssl"
      openssl = Formula["openssl"].opt_prefix
      args << "--with-ssl=#{openssl}"
    else
      args << "--with-ssl=/usr"
    end

    if build.with? "brewed-apr"
      apr = Formula["apr"].opt_prefix
      aprutil = Formula["apr-util"].opt_prefix

      args << "--with-apr=#{apr}",
      args << "--with-apr-util=#{aprutil}"
    else
      args << "--with-included-apr"
    end

    args << "--with-pcre=#{Formula['pcre'].opt_prefix}" if build.with? "brewed-pcre"

    system "./configure", *args

    system "make"
    system "make install"
    (var/"apache2/log").mkpath
    (var/"apache2/run").mkpath
  end

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_prefix}/sbin/httpd</string>
        <string>-D</string>
        <string>FOREGROUND</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
    </dict>
    </plist>
    EOS
  end

  test do
    system sbin/"httpd", "-v"
  end
end
