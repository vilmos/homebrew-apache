require "formula"

class ModSuexec < Formula
  homepage "http://httpd.apache.org/docs/current/suexec.html"
  url "http://archive.apache.org/dist/httpd/httpd-2.2.24.tar.bz2" if MacOS.version == :snow_leopard
  sha1 "f73bce14832ec40c1aae68f4f8c367cab2266241" if MacOS.version == :snow_leopard
  url "http://archive.apache.org/dist/httpd/httpd-2.2.26.tar.bz2" if MacOS.version == :lion
  sha1 "ecfa7dab239ef177668ad1d5cf9d03c4602607b8" if MacOS.version == :lion
  url "http://archive.apache.org/dist/httpd/httpd-2.2.22.tar.bz2" if MacOS.version == :mountain_lion
  sha1 "766cd0843050a8dfb781e48b976f3ba6ebcf8696" if MacOS.version == :mountain_lion
  url "http://archive.apache.org/dist/httpd/httpd-2.2.26.tar.bz2" if MacOS.version == :mavericks
  sha1 "ecfa7dab239ef177668ad1d5cf9d03c4602607b8" if MacOS.version == :mavericks
  url "http://archive.apache.org/dist/httpd/httpd-2.4.9.tar.bz2" if MacOS.version == :yosemite
  sha1 "646aedbf59519e914c424b3a85d846bf189be3f4" if MacOS.version == :yosemite

  bottle do
    cellar :any
    root_url "https://bitbucket.org/alanthing/homebrew-apache/downloads"
    sha1 "0b5099ab855dce387b876f66d108c935331cbe18" => :yosemite
  end

  depends_on "libtool" => :build
  depends_on "pcre"

  def install
    system "./configure",
      "LDFLAGS=--tag=cc",
      "--enable-suexec=shared",
      "--with-suexec-bin=/usr/bin/suexec",
      "--with-suexec-caller=_www",
      "--with-suexec-userdir=Sites",
      "--with-suexec-docroot=/",
      "--with-suexec-uidmin=100",
      "--with-suexec-gidmin=20",
      "--with-suexec-logfile=suexec_log",
      "--with-suexec-safepath=/usr/local/bin:/usr/bin:/bin"

    args = "CC=#{ENV.cc}" if MacOS.version >= :lion
    system "make", *args

    libexec.install "modules/generators/.libs/mod_suexec.so"
    libexec.install "support/suexec"

    include.install "modules/generators/mod_suexec.h"
  end

  def caveats; <<-EOS.undent
    NOTE: This is formula is not needed with Homebrew httpd22 or httpd24; this
    is intended for use with the built-in httpd. Homebrew httpd22 and httpd24
    build mod_suexec by default.

    To complete the installation, you must execute the following commands
      sudo cp -vf #{libexec}/suexec /usr/bin/
      sudo chown -v root:_www /usr/bin/suexec
      sudo chmod -v 4750 /usr/bin/suexec

    Then, you must edit /etc/apache2/httpd.conf to include
      LoadModule suexec_module #{libexec}/mod_suexec.so

    Upon restarting Apache, you should see the following message in the error log:
      [notice] suEXEC mechanism enabled (wrapper: /usr/bin/suexec)

    Be sure to understand the security implications of suexec by carefully
    reading http://httpd.apache.org/docs/current/suexec.html
    EOS
  end

end
