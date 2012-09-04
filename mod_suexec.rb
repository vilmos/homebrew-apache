require 'formula'

class ModSuexec < Formula
  url 'http://archive.apache.org/dist/httpd/httpd-2.2.20.tar.gz'
  homepage 'http://httpd.apache.org/docs/current/suexec.html'
  md5 '4504934464c5ee51018dbafa6d99810d'

  def install
    if MacOS.mountain_lion?
      # Force this formula to use OS X's built-in apr-1-config
      ENV['HOMEBREW_CCCFG'] = ENV['HOMEBREW_CCCFG'].delete "a"
      # Force the toolchain reported by apr-1-config
      ENV['CC'] = "/Applications/Xcode.app/Contents/Developer/Toolchains/OSX10.8.xctoolchain/usr/bin/cc"
      ENV['CPP'] = ENV['CC'] + " -E"
      # This formula must be built with the compiler at the same path as `apr-1-config --cc`
      # (Other workarounds, like HOMEBREW_CCCFG containing 'a', do not seem to work here)
      unless File.exists?('/Applications/Xcode.app/Contents/Developer/Toolchains/OSX10.8.xctoolchain/usr/bin/cc')
        abort "ERROR: An OS X bug exists that requires the compiler to be at /Applications/Xcode.app/Contents/Developer/Toolchains/OSX10.8.xctoolchain/usr/bin/cc
               If you have Xcode installed, create a symbolic link to the correct location:
               ln -s /Applications/Xcode.app/Contents/Developer/Toolchains/{XcodeDefault,OSX10.8.xctoolchain}.xctoolchain
               (sudo might be needed if you downloaded Xcode from the App Store)

               If you do not have Xcode installed, create a fake OSX10.8.xctoolchain directory pointing to system 
               folder that contain the compilers and libraries needed:
               mkdir -p /Applications/Xcode.app/Contents/Developer/Toolchains/OSX10.8.xctoolchain/usr
               ln -s /usr/bin /Applications/Xcode.app/Contents/Developer/Toolchains/OSX10.8.xctoolchain/usr/bin
               ln -s /usr/include /Applications/Xcode.app/Contents/Developer/Toolchains/OSX10.8.xctoolchain/usr/include
               ln -s /usr/lib /Applications/Xcode.app/Contents/Developer/Toolchains/OSX10.8.xctoolchain/usr/lib
               ln -s /usr/libexec /Applications/Xcode.app/Contents/Developer/Toolchains/OSX10.8.xctoolchain/usr/libexec
               ln -s /usr/share /Applications/Xcode.app/Contents/Developer/Toolchains/OSX10.8.xctoolchain/usr/share"
      end
    end
    suexec_userdir   = ENV['SUEXEC_USERDIR']  || 'Sites'
    suexec_docroot   = ENV['SUEXEC_DOCROOT']  || '/Library/WebServer'
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
