Homebrew-apache
===============

[![Build Status](https://travis-ci.org/Homebrew/homebrew-apache.svg?branch=master)](https://travis-ci.org/Homebrew/homebrew-apache)

How do I install these formulae?
--------------------------------
Just `brew tap homebrew/apache` and then `brew install <formula>`.

If the formula conflicts with one from mxcl/master or another tap, you can `brew install homebrew/apache/<formula>`.

You can also install via URL:

```
brew install https://raw.githubusercontent.com/Homebrew/homebrew-apache/master/<formula>.rb
```

Docs
----
`brew help`, `man brew`, or the Homebrew [wiki][].

[wiki]:http://wiki.github.com/mxcl/homebrew

Troubleshooting
---------------

A common problem on both OS X 10.8 Mountain Lion and 10.9 Mavericks systems is an error about a missing *OSX10.8.xctoolchain* or *OSX10.9.xctoolchain* directory:

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

The simplest solution is to go to the */Applications/Xcode.app/Contents/Developer/Toolchains/* directory and create a symlink named *OSX10.8.xctoolchain* or *OSX10.9.xctoolchain* to *XcodeDefault.xctoolchain*. This requires you to have Xcode installed. If you only have the [Xcode Command Line tools](https://developer.apple.com/downloads/) or [OSX-GCC-Installer](http://kennethreitz.com/xcode-gcc-and-homebrew.html), a simple symlink will not work.

This single-line command will set up the symlink if you have Xcode installed, and if you don't, it will create directories leading up to the toolchain and a symlink to /usr/bin that will satisfy the requirements needed for `apr-1-config` to find the compiler it needs:

```bash
sw_vers -productVersion | grep -E '^10\.[89]' > /dev/null && bash -c "[ -d /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain ] && sudo -u $(ls -ld /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain | awk '{print $3}') bash -c 'ln -vs XcodeDefault.xctoolchain /Applications/Xcode.app/Contents/Developer/Toolchains/OSX$(sw_vers -productVersion | cut -c-4).xctoolchain' || sudo bash -c 'mkdir -vp /Applications/Xcode.app/Contents/Developer/Toolchains/OSX$(sw_vers -productVersion | cut -c-4).xctoolchain/usr && ln -s /usr/bin /Applications/Xcode.app/Contents/Developer/Toolchains/OSX$(sw_vers -productVersion | cut -c-4).xctoolchain/usr/bin'"
```
