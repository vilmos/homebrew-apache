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
    # install custom layout
    File.open('config.layout', 'w') { |f| f.write(httpd_layout) };

    args = %W[
      --enable-layout=Homebrew
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

  def httpd_layout
    return <<-EOS.undent
      <Layout Homebrew>
          prefix:        #{prefix}
          exec_prefix:   ${prefix}
          bindir:        ${exec_prefix}/bin
          sbindir:       ${exec_prefix}/bin
          libdir:        ${exec_prefix}/lib
          libexecdir:    ${exec_prefix}/libexec
          mandir:        #{man}
          sysconfdir:    #{etc}/apache2
          datadir:       #{var}/www
          installbuilddir: ${datadir}/build
          errordir:      ${datadir}/error
          iconsdir:      ${datadir}/icons
          htdocsdir:     ${datadir}/htdocs
          manualdir:     ${datadir}/manual
          cgidir:        #{var}/apache2/cgi-bin
          includedir:    ${prefix}/include/apache2
          localstatedir: #{var}/apache2
          runtimedir:    #{var}/run/apache2
          logfiledir:    #{var}/log/apache2
          proxycachedir: ${localstatedir}/proxy
      </Layout>
      EOS

  test do
    system sbin/"httpd", "-v"
  end
end
