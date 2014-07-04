require 'formula'

class ModWsgi < Formula
  homepage 'http://code.google.com/p/modwsgi/'
  url 'http://modwsgi.googlecode.com/files/mod_wsgi-3.4.tar.gz'
  sha1 '92ebc48e60ab658a984f97fd40cb71e0ae895469'

  head 'http://modwsgi.googlecode.com/svn/trunk/mod_wsgi'

  option 'with-brewed-httpd22', 'Use Homebrew Apache httpd 2.2'
  option 'with-brewed-httpd24', 'Use Homebrew Apache httpd 2.4'
  option 'with-brewed-python', 'Use Homebrew python'

  depends_on 'httpd22' if build.with? 'brewed-httpd22'
  depends_on 'httpd24' if build.with? 'brewed-httpd24'
  depends_on 'python' if build.with? 'brewed-python'

  def apache_apxs
    if build.with? 'brewed-httpd22'
      ['sbin', 'bin'].each do |dir|
        if File.exist?(location = "#{Formula['httpd22'].opt_prefix}/#{dir}/apxs")
          return location
        end
      end
    elsif build.with? 'brewed-httpd24'
      ['sbin', 'bin'].each do |dir|
        if File.exist?(location = "#{Formula['httpd24'].opt_prefix}/#{dir}/apxs")
          return location
        end
      end
    else
      '/usr/sbin/apxs'
    end
  end

  def apache_configdir
    if build.with? 'brewed-httpd22'
      "#{etc}/apache2/2.2"
    elsif build.with? 'brewed-httpd24'
      "#{etc}/apache2/2.4"
    else
      '/etc/apache2'
    end
  end

  def install
    args = "--prefix=#{prefix}", "--disable-debug", "--disable-dependency-tracking", "--disable-framework"
    args << "--with-apxs=#{apache_apxs}"
    args << "--with-python=#{HOMEBREW_PREFIX}/bin/python" if build.with? "brewed-python"
    system './configure', *args

    inreplace 'Makefile' do |s|
      # --libexecdir parameter to ./configure isn't changing this, so cram it in
      # This will be where the Apache module ends up, and we don't want to touch
      # the system libexec.
      s.change_make_var! 'LIBEXECDIR', libexec
    end

    system 'make install'
  end

  def caveats
    <<-EOS.undent
    You must manually edit #{apache_configdir}/httpd.conf to include
      LoadModule wsgi_module #{libexec}/mod_wsgi.so

    NOTE: If you're _NOT_ using --with-brewed-httpd22 or --with-brewed-httpd24 and having
    installation problems relating to a missing `cc` compiler and `OSX#{MACOS_VERSION}.xctoolchain`,
    read the "Troubleshooting" section of https://github.com/Homebrew/homebrew-apache
    EOS
  end
end
