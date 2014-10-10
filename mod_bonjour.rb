require "formula"

class ModBonjour < Formula
  homepage "http://www.opensource.apple.com/source/apache_mod_bonjour/apache_mod_bonjour-23/"
  url "http://www.opensource.apple.com/tarballs/apache_mod_bonjour/apache_mod_bonjour-23.tar.gz"
  sha1 "597ad957a6524ba05e03e2679fe622abdb2662f8"
  version "2.3"

  option "with-brewed-httpd22", "Use Homebrew Apache httpd 2.2"
  option "with-brewed-httpd24", "Use Homebrew Apache httpd 2.4"

  depends_on "httpd22" if build.with? "brewed-httpd22"
  depends_on "httpd24" if build.with? "brewed-httpd24"

  if build.with? "brewed-httpd22" and build.with? "brewed-httpd24"
    onoe "Cannot build for http22 and httpd24 at the same time"
    exit 1
  end

  if (! (build.with? "brewed-httpd22" or build.with? "brewed-httpd24")) and MacOS.version == :mavericks
    unless system("pkgutil --pkgs | grep -qx com.apple.pkg.CLTools_Executables")
      onoe "Command Line Tools required, even if Xcode is installed, on 10.9 Mavericks and not
       using Homebrew httpd22 or httpd24. Resolve by running `xcode-select --install`."
      exit 1
    end
  end

  def apache_apxs
    if build.with? "brewed-httpd22"
      %W[sbin, bin].each do |dir|
        if File.exist?(location = "#{Formula['httpd22'].opt_prefix}/#{dir}/apxs")
          return location
        end
      end
    elsif build.with? "brewed-httpd24"
      %W[sbin, bin].each do |dir|
        if File.exist?(location = "#{Formula['httpd24'].opt_prefix}/#{dir}/apxs")
          return location
        end
      end
    else
      "/usr/sbin/apxs"
    end
  end

  def apache_configdir
    if build.with? "brewed-httpd22"
      "#{etc}/apache2/2.2"
    elsif build.with? "brewed-httpd24"
      "#{etc}/apache2/2.4"
    else
      "/etc/apache2"
    end
  end

  def install
    system "#{apache_apxs} -o mod_bonjour.so -c *.c"
    libexec.install ".libs/mod_bonjour.so"
  end

  def caveats
    <<-EOS.undent
    You must manually edit #{apache_configdir}/httpd.conf to include
      LoadModule bonjour_module #{libexec}/mod_bonjour.so

    Add the following to your virtual host conf files to advertise them on bonjour. The
    last number is whatever port the virtual host is listening on.

        <IfModule bonjour_module>
            RegisterResource "Site Title" / 80
        </IfModule>

    NOTE: If you're _NOT_ using --with-brewed-httpd22 or --with-brewed-httpd24 and having
    installation problems relating to a missing `cc` compiler and `OSX#{MACOS_VERSION}.xctoolchain`,
    read the "Troubleshooting" section of https://github.com/Homebrew/homebrew-apache
    EOS
  end

end
