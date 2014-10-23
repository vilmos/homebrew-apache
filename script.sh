#!/bin/bash

set -x
set -e

BOTTLE="yes"

if [[ "$BOTTLE" == "yes" ]]; then
  cd ~/Documents
  [ ! -d bottles ] && mkdir bottles
  cd bottles
else
  brew list | xargs brew uninstall
fi

rm -rfv /Library/Caches/Homebrew/*

# sw_vers -productVersion | grep -E '^10\.([89]|10)' > /dev/null && bash -c "[ -d /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain ] && sudo -u $(ls -ld /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain | awk '{print $3}') bash -c 'ln -vs XcodeDefault.xctoolchain /Applications/Xcode.app/Contents/Developer/Toolchains/OSX$(sw_vers -productVersion | cut -c-4).xctoolchain' || sudo bash -c 'mkdir -vp /Applications/Xcode.app/Contents/Developer/Toolchains/OSX$(sw_vers -productVersion | cut -c-4).xctoolchain/usr && ln -s /usr/bin /Applications/Xcode.app/Contents/Developer/Toolchains/OSX$(sw_vers -productVersion | cut -c-4).xctoolchain/usr/bin'"

for pkg in mod_{bonjour,fastcgi,fcgid,python,security,wsgi}; do
  if [[ "$BOTTLE" == "yes" ]]; then
    brew install --build-bottle $pkg
    brew bottle $pkg | tee -a bottles.txt
  else
    brew install $pkg
  fi
  brew uninstall $pkg
done

for pkg in apr{,-util} ab; do
  if [[ "$BOTTLE" == "yes" ]]; then
    brew install --build-bottle $pkg
    brew bottle $pkg | tee -a bottles.txt
  else
    brew install $pkg
  fi
done

brew install mod_security --with-brewed-apr
brew uninstall mod_security

brew install httpd22
brew uninstall httpd22
brew install httpd22 --with-brewed-openssl
brew uninstall httpd22
brew install httpd22 --with-pcre
brew uninstall httpd22
brew install httpd22 --with-brewed-openssl --with-pcre

brew unlink httpd22

brew install httpd24
brew uninstall httpd24
brew install httpd24 --with-brewed-openssl

for pkg in mod_{bonjour,fastcgi,fcgid,python,security,wsgi}; do
  brew install $pkg --with-brewed-httpd24
  brew uninstall $pkg
done

brew install mod_python --with-brewed-httpd24 --with-brewed-python
brew install mod_wsgi --with-brewed-httpd24 --with-brewed-python
brew uninstall mod_python mod_wsgi

brew unlink httpd24
brew link httpd22

for pkg in mod_{bonjour,fastcgi,fcgid,python,security,wsgi}; do
  brew install $pkg --with-brewed-httpd22
  brew uninstall $pkg
done

brew install mod_python --with-brewed-httpd22 --with-brewed-python
brew install mod_wsgi --with-brewed-httpd22 --with-brewed-python
brew uninstall mod_python mod_wsgi
