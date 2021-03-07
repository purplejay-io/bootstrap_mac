#!/bin/bash
# https://www.jamf.com/blog/reinstall-a-clean-macos-with-one-button/

#curl -L aka.ms/EnrollMyMac --output /tmp/intune.pkg

softwareupdate --fetch-full-installer

sleep 10

'/Applications/Install macOS Big Sur.app/Contents/Resources/startosinstall' --eraseinstall --agreetolicense \
--forcequitapps --newvolumename 'Macintosh HD' --passprompt
