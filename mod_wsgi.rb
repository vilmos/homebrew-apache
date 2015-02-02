require "formula"

class ModWsgi < Formula
  class CLTRequirement < Requirement
    fatal true
    satisfy { MacOS.version < :mavericks || MacOS::CLT.installed? }

    def message; <<-EOS.undent
      Command Line Tools required, even if Xcode is installed, on OS X 10.9 or
      10.10 and not using Homebrew httpd22 or httpd24. Resolve by running
        xcode-select --install
      EOS
    end
  end

  homepage "http://modwsgi.readthedocs.org/en/latest/"
  url "https://github.com/GrahamDumpleton/mod_wsgi/archive/4.4.7.tar.gz"
  sha1 "1a8dc498384a7de00166d4912338a9375845f8e5"
  sha256 "dc9810866ee9cdbcd68b4cd14e76e1bdec619694176d90787423d17adfc4b1e0"

  head "https://github.com/GrahamDumpleton/mod_wsgi.git"

  option "with-homebrew-httpd22", "Use Homebrew Apache httpd 2.2"
  option "with-homebrew-httpd24", "Use Homebrew Apache httpd 2.4"
  option "with-homebrew-python", "Use Homebrew python"

  deprecated_option "with-brewed-httpd22" => "with-homebrew-httpd22"
  deprecated_option "with-brewed-httpd24" => "with-homebrew-httpd24"
  deprecated_option "with-brewed-python" => "with-homebrew-python"

  depends_on "httpd22" if build.with? "homebrew-httpd22"
  depends_on "httpd24" if build.with? "homebrew-httpd24"
  depends_on "python" if build.with? "homebrew-python"
  depends_on CLTRequirement if build.without? "homebrew-httpd22" and build.without? "homebrew-httpd24"

  if build.with? "homebrew-httpd22" and build.with? "homebrew-httpd24"
    onoe "Cannot build for http22 and httpd24 at the same time"
    exit 1
  end

  def apache_apxs
    if build.with? "homebrew-httpd22"
      %W[sbin bin].each do |dir|
        if File.exist?(location = "#{Formula['httpd22'].opt_prefix}/#{dir}/apxs")
          return location
        end
      end
    elsif build.with? "homebrew-httpd24"
      %W[sbin bin].each do |dir|
        if File.exist?(location = "#{Formula['httpd24'].opt_prefix}/#{dir}/apxs")
          return location
        end
      end
    else
      "/usr/sbin/apxs"
    end
  end

  def apache_configdir
    if build.with? "homebrew-httpd22"
      "#{etc}/apache2/2.2"
    elsif build.with? "homebrew-httpd24"
      "#{etc}/apache2/2.4"
    else
      "/etc/apache2"
    end
  end

  def install
    args = "--prefix=#{prefix}", "--disable-framework"
    args << "--with-apxs=#{apache_apxs}"
    args << "--with-python=#{HOMEBREW_PREFIX}/bin/python" if build.with? "homebrew-python"
    system "./configure", *args

    system "make"

    libexec.install "src/server/.libs/mod_wsgi.so"
  end

  def caveats; <<-EOS.undent
    You must manually edit #{apache_configdir}/httpd.conf to include
      LoadModule wsgi_module #{libexec}/mod_wsgi.so

    NOTE: If you're _NOT_ using --with-homebrew-httpd22 or --with-homebrew-httpd24 and having
    installation problems relating to a missing `cc` compiler and `OSX#{MacOS.version}.xctoolchain`,
    read the "Troubleshooting" section of https://github.com/Homebrew/homebrew-apache
    EOS
  end

end
