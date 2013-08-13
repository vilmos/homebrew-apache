require 'formula'

class ModSecurity < Formula
  homepage 'http://www.modsecurity.org/'
  url 'https://www.modsecurity.org/tarball/2.7.5/modsecurity-apache_2.7.5.tar.gz'
  sha1 '3901c792e8c1324578c959fa4ed9c52befe18570'

  depends_on 'pcre'

  def apr_bin
    superbin or "/usr/bin"
  end

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--with-pcre=#{HOMEBREW_PREFIX}",
                          "--with-apr=#{apr_bin}"

    # Don't install to the system Apache libexec folder or use non-existent CC path (OS X's `apxs -q` is bad)
    makefiles = ['Makefile', 'apache2/Makefile', 'mlogc/Makefile', 'tests/Makefile' , 'tools/Makefile']
    makefiles.each do |makefile|
      inreplace makefile do |s|
        s.change_make_var! "APXS_CC", ENV.cc
        s.change_make_var! "APXS_MODULES", libexec
      end
    end

    system "make"

    # mod_security's Makefile wants to copy the module to ${eprefix}/libexec, so we'll 
    # need to create the target directory first
    libexec.mkpath

    system "make install"

    prefix.install "modsecurity.conf-recommended"
  end

  def caveats; <<-EOS.undent
    To use mod_security, you must manually edit /etc/apache2/httpd.conf to load:
      #{libexec}/mod_security.so

    Sample configuration file for Apache is at:
      #{prefix}/modsecurity.conf-recommended
    EOS
  end
end