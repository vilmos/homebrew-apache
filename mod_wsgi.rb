require "formula"

class ModWsgi < Formula
  homepage "http://modwsgi.readthedocs.org/en/latest/"
  url "https://github.com/GrahamDumpleton/mod_wsgi/archive/3.5.tar.gz"
  sha1 "57552287ced75e5fd0b2b00fb186f963f9c4236b"

  head "https://github.com/GrahamDumpleton/mod_wsgi.git"

  bottle do
    cellar :any
    root_url "https://bitbucket.org/alanthing/homebrew-apache/downloads"
    sha1 "0ac0906c38c857d878a4206159ad6769dc40fb73" => :snow_leopard
    sha1 "1fab633b53a1840289e518c1e2fbeb5f523b042f" => :lion
    sha1 "f4c38b9890e1b0e91e027e49e6a9e7f54577d499" => :mountain_lion
    sha1 "ef89f27ae5a637d42329bbd8deeeaf2c59939f2f" => :mavericks
    sha1 "9fc46cef36a90e50c3aafc2e2e516eba8d951703" => :yosemite
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
    args = "--prefix=#{prefix}", "--disable-framework"
    args << "--with-apxs=#{apache_apxs}"
    args << "--with-python=#{HOMEBREW_PREFIX}/bin/python" if build.with? "brewed-python"
    system "./configure", *args

    system "make"

    libexec.install ".libs/mod_wsgi.so"
  end

  def caveats; <<-EOS.undent
    You must manually edit #{apache_configdir}/httpd.conf to include
      LoadModule wsgi_module #{libexec}/mod_wsgi.so

    NOTE: If you're _NOT_ using --with-brewed-httpd22 or --with-brewed-httpd24 and having
    installation problems relating to a missing `cc` compiler and `OSX#{MacOS.version}.xctoolchain`,
    read the "Troubleshooting" section of https://github.com/Homebrew/homebrew-apache
    EOS
  end

end
