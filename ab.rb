require "formula"

class Ab < Formula
  homepage "https://httpd.apache.org/docs/trunk/programs/ab.html"
  url "https://archive.apache.org/dist/httpd/httpd-2.4.10.tar.bz2"
  sha1 "00f5c3f8274139bd6160eda2cf514fa9b74549e5"

  bottle do
    cellar :any
    root_url "https://bitbucket.org/alanthing/homebrew-apache/downloads"
    sha1 "24995d9281dd40dac28dd2e64d3ed50e3364e86e" => :snow_leopard
    sha1 "6f7abdb25b37c1db8a216f0b33732da935a06f4c" => :lion
    sha1 "a6f96b9917ae3b289b886c6813d2c59cd890dc91" => :mountain_lion
    sha1 "1304c0810728468ca032e0ecec445f58f56adc33" => :mavericks
    sha1 "d394d4baf4faaa5165a3653283e902043cae14ea" => :yosemite
  end

  keg_only :provided_by_osx

  conflicts_with "httpd22", "httpd24", :because => "both install `ab`"

  depends_on "apr-util"
  depends_on "libtool" => :build

  option "with-ssl-patch", 'Apply patch for: Bug 49382 - ab says "SSL read failed"'

  # Disable requirement for PCRE, because "ab" does not use it
  patch :DATA

  # Patch for https://issues.apache.org/bugzilla/show_bug.cgi?id=49382
  # Upstream has not incorporated the patch. Should keep following
  # what upstream does about this.
  patch do
    url "https://gist.githubusercontent.com/Noctem/a0ba1477dbc11b5108b2/raw/ddf33c8a8b7939bbc3f12a1eb700a12b339d9194/ab-ssl-patch.diff"
    sha1 "7c4591e343c84d956e241194aac2b2804d327147"
  end if build.with? "ssl-patch"

  def install
    # Mountain Lion requires this to be set, as otherwise libtool complains
    # about being "unable to infer tagged configuration"
    ENV["LTFLAGS"] = "--tag CC"
    system "./configure", "--prefix=#{prefix}", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--with-apr=#{Formula["apr"].opt_prefix}",
                          "--with-apr-util=#{Formula["apr-util"].opt_prefix}"

    cd "support" do
      system "make", "ab"
      # We install into the "bin" directory, although "ab" would normally be
      # installed to "/usr/sbin/ab"
      bin.install("ab")
    end
    man1.install("docs/man/ab.1")
  end

  test do
    system *%W{#{bin}/ab -k -n 10 -c 10 http://www.apple.com/}
  end
end

__END__
diff --git a/configure b/configure
index 90ae8be..243e9cf 100755
--- a/configure
+++ b/configure
@@ -6156,8 +6156,6 @@ $as_echo "$as_me: Using external PCRE library from $PCRE_CONFIG" >&6;}
     done
   fi
 
-else
-  as_fn_error $? "pcre-config for libpcre not found. PCRE is required and available from http://pcre.org/" "$LINENO" 5
 fi
 
   APACHE_VAR_SUBST="$APACHE_VAR_SUBST PCRE_LIBS"
