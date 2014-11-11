require "formula"

class ModPython < Formula
  homepage "http://modpython.org/"
  url "http://dist.modpython.org/dist/mod_python-3.5.0.tgz"
  sha1 "9208bb813172ab51d601d78e439ea552f676d2d1"

  bottle do
    cellar :any
    root_url "https://bitbucket.org/alanthing/homebrew-apache/downloads"
    sha1 "3137a3cec5b6e32d514b62837959e9c736d8f9b2" => :snow_leopard
    sha1 "12bb474e8bff36f114f8080f31dde38064cd8a8d" => :lion
    sha1 "d4e908e9592e95aa55e1fcf2c7ea48ed4a2b3139" => :mountain_lion
    sha1 "2a013d1ef8cfb2ddf23f8ea48eb15a355fab83c4" => :mavericks
    sha1 "0316f2ab4c1606e835ec4063949bcdbf7904e7a0" => :yosemite
  end

  option "with-brewed-httpd22", "Use Homebrew Apache httpd 2.2"
  option "with-brewed-httpd24", "Use Homebrew Apache httpd 2.4"
  option "with-brewed-python", "Use Homebrew python"

  depends_on "httpd22" if build.with? "brewed-httpd22"
  depends_on "httpd24" if build.with? "brewed-httpd24"
  depends_on "python" if build.with? "brewed-python"

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
    args = "--prefix=#{prefix}"
    args << "--with-apxs=#{apache_apxs}"
    args << "--with-python=#{HOMEBREW_PREFIX}/bin/python" if build.with? "brewed-python"
    system "./configure", *args

    system "make"

    libexec.install "src/.libs/mod_python.so"
  end

  def caveats; <<-EOS.undent
    You must manually edit #{apache_configdir}/httpd.conf to include
      LoadModule python_module #{libexec}/mod_python.so

    NOTE: If you're _NOT_ using --with-brewed-httpd22 or --with-brewed-httpd24 and having
    installation problems relating to a missing `cc` compiler and `OSX#{MacOS.version}.xctoolchain`,
    read the "Troubleshooting" section of https://github.com/Homebrew/homebrew-apache
    EOS
  end

end
