require "formula"

class ModSecurity < Formula
  homepage "http://www.modsecurity.org/"
  url "https://www.modsecurity.org/tarball/2.8.0/modsecurity-2.8.0.tar.gz"
  sha1 "0ac3931806468eef616ee2301c98b3dd1f567f7c"

  option "with-brewed-apr", "Use Homebrew apr"
  option "with-brewed-httpd22", "Use Homebrew Apache httpd 2.2"
  option "with-brewed-httpd24", "Use Homebrew Apache httpd 2.4"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "apr-util" if build.with? "brewed-apr"
  depends_on "httpd22" if build.with? "brewed-httpd22"
  depends_on "httpd24" if build.with? "brewed-httpd24"
  depends_on "libtool" => :build
  depends_on "pcre"

  if build.with? "brewed-apr" and (build.with? "brewed-httpd22" or build.with? "brewed-httpd24")
    opoo "Ignoring --with-brewed-apr: homebrew apr included in httpd22 and httpd24"
  end

  if build.with? "brewed-httpd22" and build.with? "brewed-httpd24"
    onoe "Cannot build for http22 and httpd24 at the same time"
    exit 1
  end

  if (! (build.with? "brewed-httpd22" or build.with? "brewed-httpd24" or build.with? "brewed-apr")) and MacOS.version == :mavericks
    unless system("pkgutil --pkgs | grep -qx com.apple.pkg.CLTools_Executables")
      onoe "Command Line Tools required, even if Xcode is installed, on 10.9 Mavericks and not
       using Homebrew httpd22, httpd24, or apr. Resolve by running `xcode-select --install`."
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
    args = "--prefix=#{prefix}", "--disable-dependency-tracking"
    args << "--with-pcre=#{Formula['pcre'].opt_prefix}"
    args << "--with-apxs=#{apache_apxs}"

    if (build.with? "brewed-httpd22") || (build.with? "brewed-httpd24") || (build.with? "brewed-apr")
      args << "--with-apr=#{Formula['apr'].opt_prefix}"
      args << "--with-apu=#{Formula['apr-util'].prefix}/bin"
    else
      args << "--with-apr=/usr/bin"
      args << "--with-apu=/usr/bin"
    end

    system "./autogen.sh"
    system "./configure", *args
    system "make"

    libexec.install "apache2/.libs/mod_security2.so"

    # Use Homebrew paths in the sample file
    inreplace "modsecurity.conf-recommended" do |s|
      s.gsub! " /var/log", " #{var}/log"
      s.gsub! " /opt/modsecurity/var", " #{opt_prefix}/var"
    end

    prefix.install "modsecurity.conf-recommended"
  end

  def caveats; <<-EOS.undent
    You must manually edit #{apache_configdir}/httpd.conf to include
      LoadModule security2_module #{libexec}/mod_security2.so

    You must also uncomment a line similar to the line below in #{apache_configdir}/httpd.conf to enable unique_id_module
      #LoadModule unique_id_module libexec/mod_unique_id.so

    Sample configuration file for Apache is at:
      #{prefix}/modsecurity.conf-recommended

    NOTE: If you're _NOT_ using --with-brewed-httpd22 or --with-brewed-httpd24 and having
    installation problems relating to a missing `cc` compiler and `OSX#{MACOS_VERSION}.xctoolchain`,
    read the "Troubleshooting" section of https://github.com/Homebrew/homebrew-apache
    EOS
  end

end
