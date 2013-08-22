Homebrew-apache
===============

How do I install these formulae?
--------------------------------
Just `brew tap homebrew/apache` and then `brew install <formula>`.

If the formula conflicts with one from mxcl/master or another tap, you can `brew install homebrew/apache/<formula>`.

You can also install via URL:

```
brew install https://raw.github.com/Homebrew/homebrew-apache/master/<formula>.rb
```

Docs
----
`brew help`, `man brew`, or the Homebrew [wiki][].

[wiki]:http://wiki.github.com/mxcl/homebrew

Troubleshooting
---------------

A common problem on OS X 10.8 Mountain Lion systems is an error about a missing *OSX10.8.xctoolchain* directory:

```
/usr/share/apr-1/build-1/libtool: line 4574: /Applications/Xcode.app/Contents/Developer/Toolchains/OSX10.8.xctoolchain/usr/bin/cc: No such file or directory
```

This is because the OS X tool `apr-1-config` returns a path for a compiler that does not exist, even with Xcode installed:

```
$ apr-1-config --cc
/Applications/Xcode.app/Contents/Developer/Toolchains/OSX10.8.xctoolchain/usr/bin/cc
$ apr-1-config --cpp
/Applications/Xcode.app/Contents/Developer/Toolchains/OSX10.8.xctoolchain/usr/bin/cc -E
$ which apr-1-config
/usr/bin/apr-1-config
```

The simplest solution is to go to the */Applications/Xcode.app/Contents/Developer/Toolchains/* directory and create a symlink named *OSX10.8.xctoolchain* to *XcodeDefault.xctoolchain*. This requires you to have Xcode installed. If you only have the [Xcode Command Line tools](https://developer.apple.com/downloads/) or [OSX-GCC-Installer](http://kennethreitz.com/xcode-gcc-and-homebrew.html), a simple symlink will not work.

This single line will set up the symlink if you have Xcode installed, and if you don't, it will create directories leading up to the toolchain and a symlink to /usr/bin that will satisfy the requirements needed for `apr-1-config` to find the compiler it needs:

```bash
[ "$(sw_vers -productVersion | sed 's/^\(10\.[0-9]\).*/\1/')" = "10.8" ] && bash -c "[ -d /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain ] && sudo bash -c 'cd /Applications/Xcode.app/Contents/Developer/Toolchains/ && ln -vs XcodeDefault.xctoolchain OSX10.8.xctoolchain' || sudo bash -c 'mkdir -vp /Applications/Xcode.app/Contents/Developer/Toolchains/OSX10.8.xctoolchain/usr && cd /Applications/Xcode.app/Contents/Developer/Toolchains/OSX10.8.xctoolchain/usr && ln -vs /usr/bin'"
```

[![githalytics.com alpha](https://cruel-carlota.pagodabox.com/6c80ad364071a0cd7d2ebae1f2f28b09 "githalytics.com")](http://githalytics.com/homebrew/homebrew-apache)