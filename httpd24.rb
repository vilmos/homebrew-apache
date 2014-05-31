require "formula"

class Httpd24 < Formula
  homepage "https://httpd.apache.org/"
  url "https://www.apache.org/dist/httpd/httpd-2.4.9.tar.bz2"
  sha1 "646aedbf59519e914c424b3a85d846bf189be3f4"

  conflicts_with "httpd22", :because => "different versions of the same software"

  skip_clean :la

  option "with-brewed-openssl", "Use Homebrew's SSL instead of the system version"
  option "with-privileged-ports", "Use the default ports 80 and 443 (which require root privileges), instead of 8080 and 8443"

  depends_on "apr"
  depends_on "apr-util"
  depends_on "pcre"
  depends_on "openssl" if build.with? "brewed-openssl"

  def install
    apr = Formula["apr"].opt_prefix
    aprutil = Formula["apr-util"].opt_prefix

    # point config files to opt_prefix instead of the version-specific prefix
    inreplace "makefile.in",
      '#@@ServerRoot@@#$(prefix)#', '#@@ServerRoot@@'"##{opt_prefix}#"

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
      --enable-logio
      --enable-deflate
      --enable-cgi
      --enable-cgid
      --enable-suexec
      --enable-rewrite
      --with-apr=#{apr}
      --with-apr-util=#{aprutil}
    ]

    if build.with? "brewed-openssl"
      openssl = Formula["openssl"].opt_prefix
      args << "--with-ssl=#{openssl}"
    else
      args << "--with-ssl=/usr"
    end

    if build.with? "privileged-ports"
      args << "--with-port=80"
      args << "--with-sslport=443"
    else
      args << "--with-port=8080"
      args << "--with-sslport=8443"
    end

    args << "--with-pcre=#{Formula['pcre'].opt_prefix}" if build.with? "pcre"

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
        <string>#{opt_prefix}/bin/httpd</string>
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
          sysconfdir:    #{etc}/apache2/2.4
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
  end

  test do
    system sbin/"httpd", "-v"
  end
end
