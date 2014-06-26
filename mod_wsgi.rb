require 'formula'

class ModWsgi < Formula
  homepage 'http://code.google.com/p/modwsgi/'
  url 'http://modwsgi.googlecode.com/files/mod_wsgi-3.4.tar.gz'
  sha1 '92ebc48e60ab658a984f97fd40cb71e0ae895469'

  head 'http://modwsgi.googlecode.com/svn/trunk/mod_wsgi'

  option 'with-brewed-python', 'Use Homebrew python instead of system python'

  depends_on 'python' if build.with? 'brewed-python'

  def install
    # Remove a flag added when homebrew isn't in /usr/local
    # causes apxs to fail with "unknown flags" error
    ENV.remove 'CPPFLAGS', "-isystem #{HOMEBREW_PREFIX}/include"

    args = "--prefix=#{prefix}", "--disable-debug", "--disable-dependency-tracking", "--disable-framework"
    args << "--with-python=#{HOMEBREW_PREFIX}/bin/python" if build.with? "brewed-python"
    system "./configure", *args

    # We need apxs to specify the right compiler to its libtool, but
    # doing so causes libtool to die unless this flag is also set
    ENV['LTFLAGS'] = '--tag=CC'

    inreplace 'Makefile' do |s|
      # APXS uses just "gcc" unless we specify CC this way
      s.gsub! '$(APXS)', "$(APXS) -S CC=#{ENV.cc}"
      # Remove 'ppc' support, so we can pass Intel-optimized CFLAGS.
      cflags = s.get_make_var("CFLAGS")
      cflags.gsub! "-Wc,'-arch ppc7400'", ""
      cflags.gsub! "-Wc,'-arch ppc64'", ""
      cflags.gsub! "-Wc,'-arch x86_64'", "" if Hardware.is_32_bit?
      s.change_make_var! "CFLAGS", cflags

      # --libexecdir parameter to ./configure isn't changing this, so cram it in
      # This will be where the Apache module ends up, and we don't want to touch
      # the system libexec.
      s.change_make_var! "LIBEXECDIR", libexec
    end

    system "make install"
  end

  def caveats
    <<-EOS.undent
    NOTE: If you're having installation problems relating to a missing `cc` compiler and
    `OSX10.8.xctoolchain` or `OSX10.9.xctoolchain`, read the "Troubleshooting" section
    of https://github.com/Homebrew/homebrew-apache

    You must manually edit /etc/apache2/httpd.conf to include
      LoadModule wsgi_module #{libexec}/mod_wsgi.so

    On 10.5, you must run Apache in 32-bit mode:
      http://code.google.com/p/modwsgi/wiki/InstallationOnMacOSX
    EOS
  end
end
