require 'formula'

class ModSuexec < Formula
  homepage 'http://httpd.apache.org/docs/current/suexec.html'
  url 'http://archive.apache.org/dist/httpd/httpd-2.2.22.tar.bz2' if MacOS.version == :mountain_lion
  sha1 '766cd0843050a8dfb781e48b976f3ba6ebcf8696' if MacOS.version == :mountain_lion
  url 'http://archive.apache.org/dist/httpd/httpd-2.2.26.tar.bz2' if MacOS.version == :mavericks
  sha1 'ecfa7dab239ef177668ad1d5cf9d03c4602607b8' if MacOS.version == :mavericks

  depends_on 'libtool'

  def install
    suexec_userdir   = ENV['SUEXEC_USERDIR']  || 'Sites'
    suexec_docroot   = ENV['SUEXEC_DOCROOT']  || '/'
    suexec_uidmin    = ENV['SUEXEC_UIDMIN']   || '500'
    suexec_gidmin    = ENV['SUEXEC_GIDMIN']   || '20'
    suexec_safepath  = ENV['SUEXEC_SAFEPATH'] || '/usr/local/bin:/usr/bin:/bin:/opt/local/bin'
    logfile          = '/private/var/log/apache2/suexec_log'

    begin
      suexecbin = `/usr/sbin/apachectl -V`.match(/SUEXEC_BIN="(.+)"/)[1]
    rescue # This should never happen, unless Apple drops support for suexec in the future...
      abort "Could not determine suexec path. Are you sure that Apache has been compiled with suexec support?"
    end

    system "./configure",
      "LTFLAGS=--tag=cc",
      "--enable-suexec=shared",
      "--with-suexec-bin=#{suexecbin}",
      "--with-suexec-caller=_www",
      "--with-suexec-userdir=#{suexec_userdir}",
      "--with-suexec-docroot=#{suexec_docroot}",
      "--with-suexec-uidmin=#{suexec_uidmin.to_i}",
      "--with-suexec-gidmin=#{suexec_gidmin.to_i}",
      "--with-suexec-logfile=#{logfile}",
      "--with-suexec-safepath=#{suexec_safepath}"

    system "make"

    libexec.install 'modules/generators/.libs/mod_suexec.so'
    libexec.install 'support/suexec'

    include.install 'modules/generators/mod_suexec.h'
  end

  def caveats
    suexecbin = `/usr/sbin/apachectl -V`.match(/SUEXEC_BIN="(.+)"/)[1]
    <<-EOS.undent
      NOTE: If you're having installation problems relating to a missing `cc` compiler and
      `OSX10.8.xctoolchain` or `OSX10.9.xctoolchain`, read the "Troubleshooting" section
      of https://github.com/Homebrew/homebrew-apache

      To complete the installation, execute the following commands:
        sudo cp #{libexec}/suexec #{File.dirname(suexecbin)}
        sudo chown root:_www #{suexecbin}
        sudo chmod 4750 #{suexecbin}

      Then, you need to edit /etc/apache2/httpd.conf to add the following line:
        LoadModule suexec_module #{libexec}/mod_suexec.so

      Upon restarting Apache, you should see the following message in the error log:
        [notice] suEXEC mechanism enabled (wrapper: #{suexecbin})

      Please, be sure to understand the security implications of suexec
      by carefully reading http://httpd.apache.org/docs/current/suexec.html.

      This formula will use the values of the following environment
      variables, if set: SUEXEC_DOCROOT, SUEXEC_USERDIR, SUEXEC_UIDMIN,
      SUEXEC_GIDMIN, SUEXEC_SAFEPATH.
    EOS
  end

end
