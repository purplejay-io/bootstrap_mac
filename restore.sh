#!/bin/bash
# https://www.jamf.com/blog/reinstall-a-clean-macos-with-one-button/

#curl -L aka.ms/EnrollMyMac --output /tmp/intune.pkg

FMM_CHECK=`/usr/sbin/nvram -x -p | /usr/bin/grep fmm-mobileme-token-FMM`

if [ ! -z "$FMM_CHECK" ]; then
  echo "Activation Lock is enabled. Sign out of iCloud and try again."
  exit 1
fi

if [ ! -d "/Applications/Install macOS Big Sur.app" ]; then
  softwareupdate --fetch-full-installer
  sleep 5
  killall InstallAssistant
fi

# defaults delete MobileMeAccounts

'/Applications/Install macOS Big Sur.app/Contents/Resources/startosinstall' --eraseinstall --agreetolicense \
--forcequitapps --newvolumename 'Macintosh HD' --passprompt
