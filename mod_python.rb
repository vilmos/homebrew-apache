require 'formula'

class ModPython < Formula
  homepage 'http://modpython.org/'
  url 'http://dist.modpython.org/dist/mod_python-3.5.0.tgz'
  sha1 '9208bb813172ab51d601d78e439ea552f676d2d1'

  # patch-src-connobject.c.diff from MacPorts
  def patches; DATA; end

  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"

    # Explicitly set the arch in CFLAGS so the PSPModule will build against system Python
    # We remove 'ppc' support, so we can pass Intel-optimized CFLAGS.
    archs = archs_for_command("python")
    archs.remove_ppc!
    ENV.append_to_cflags archs.as_arch_flags

    # Don't install to the system Apache libexec folder
    inreplace 'Makefile' do |s|
      s.change_make_var! "LIBEXECDIR", libexec
    end

    system "make"
    system "make install"
  end

  def caveats; <<-EOS.undent
    NOTE: If you're having installation problems relating to a missing `cc` compiler and
    `OSX10.8.xctoolchain` or `OSX10.9.xctoolchain`, read the "Troubleshooting" section
    of https://github.com/Homebrew/homebrew-apache

    To use mod_python, you must manually edit /etc/apache2/httpd.conf to load:
      #{libexec}/mod_python.so
    EOS
  end
end
