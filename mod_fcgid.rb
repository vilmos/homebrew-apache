require "formula"

class ModFcgid < Formula
  homepage "http://httpd.apache.org/mod_fcgid/"
  url "http://archive.apache.org/dist/httpd/mod_fcgid/mod_fcgid-2.3.9.tar.gz"
  sha1 "99d6b24f3f83a3a83d1d93d12a0d5992e3fa7851"

  head "http://svn.apache.org/repos/asf/httpd/mod_fcgid/trunk"

  bottle do
    cellar :any
    root_url "https://bitbucket.org/alanthing/homebrew-apache/downloads"
    sha1 "b1f06bce389c24e965e291283c0635fd404bb434" => :snow_leopard
    sha1 "630b0389c5fbf0c9cae3625cc5bed1d886165f8a" => :lion
    sha1 "ac93fd97bb376288efece0844c781fdd1c15a99d" => :mountain_lion
    sha1 "4e8895a6c9ac788d9bea451fbf113be643f62449" => :mavericks
    sha1 "5cdbd977a60711772bb7decd7b10146ab5b4613f" => :yosemite
  end

  option "with-brewed-httpd22", "Use Homebrew Apache httpd 2.2"
  option "with-brewed-httpd24", "Use Homebrew Apache httpd 2.4"

  depends_on "httpd22" if build.with? "brewed-httpd22"
  depends_on "httpd24" if build.with? "brewed-httpd24"

  if build.with? "brewed-httpd22" and build.with? "brewed-httpd24"
    onoe "Cannot build for http22 and httpd24 at the same time"
    exit 1
  end

  if (! (build.with? "brewed-httpd22" or build.with? "brewed-httpd24")) and (MacOS.version >= :mavericks)
    unless system("pkgutil --pkgs | grep -qx com.apple.pkg.CLTools_Executables")
      onoe "Command Line Tools required, even if Xcode is installed, on OS X 10.9 or 10.10 and not
       using Homebrew httpd22 or httpd24. Resolve by running `xcode-select --install`."
      exit 1
    end
  end

  def apache_apxs
    if build.with? "brewed-httpd22"
      %W[sbin bin].each do |dir|
        if File.exist?(location = "#{Formula['httpd22'].opt_prefix}/#{dir}/apxs")
          return location
        end
      end
    elsif build.with? "brewed-httpd24"
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
    if build.with? "brewed-httpd22"
      "#{etc}/apache2/2.2"
    elsif build.with? "brewed-httpd24"
      "#{etc}/apache2/2.4"
    else
      "/etc/apache2"
    end
  end

  def install
    system "APXS='#{apache_apxs}' ./configure.apxs"
    system "make"
    libexec.install "modules/fcgid/.libs/mod_fcgid.so"
  end

  def caveats; <<-EOS.undent
    You must manually edit #{apache_configdir}/httpd.conf to include
      LoadModule fcgid_module #{libexec}/mod_fcgid.so

    NOTE: If you're _NOT_ using --with-brewed-httpd22 or --with-brewed-httpd24 and having
    installation problems relating to a missing `cc` compiler and `OSX#{MacOS.version}.xctoolchain`,
    read the "Troubleshooting" section of https://github.com/Homebrew/homebrew-apache
    EOS
  end

end
