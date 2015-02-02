require "formula"

class ModFastcgi < Formula
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

  url "http://www.fastcgi.com/dist/mod_fastcgi-2.4.6.tar.gz"
  homepage "http://www.fastcgi.com/"
  sha1 "69c56548bf97040a61903b32679fe3e3b7d3c2d4"
  sha256 "a5a887eecc8fe13e4cb1cab4d140188a3d2b5e6f337f8a1cce88ca441ddbe689"

  option "with-homebrew-httpd22", "Use Homebrew Apache httpd 2.2"
  option "with-homebrew-httpd24", "Use Homebrew Apache httpd 2.4"

  depends_on "httpd22" if build.with? "homebrew-httpd22"
  depends_on "httpd24" if build.with? "homebrew-httpd24"
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

  if (MacOS.version == :yosemite or build.with? "homebrew-httpd24")
    patch do
      url "https://raw.githubusercontent.com/ByteInternet/libapache-mod-fastcgi/byte/debian/patches/byte-compile-against-apache24.diff"
      sha1 "1000fac5bf814d716641bbd1528de34449049a73"
    end
  end

  def install
    system "#{apache_apxs} -o mod_fastcgi.so -c *.c"
    libexec.install ".libs/mod_fastcgi.so"
  end

  def caveats; <<-EOS.undent
    You must manually edit #{apache_configdir}/httpd.conf to contain:
      LoadModule fastcgi_module #{libexec}/mod_fastcgi.so

    Upon restarting Apache, you should see the following message in the error log:
      [notice] FastCGI: process manager initialized

    NOTE: If you're _NOT_ using --with-homebrew-httpd22 or --with-homebrew-httpd24 and having
    installation problems relating to a missing `cc` compiler and `OSX#{MacOS.version}.xctoolchain`,
    read the "Troubleshooting" section of https://github.com/Homebrew/homebrew-apache
    EOS
  end

end
