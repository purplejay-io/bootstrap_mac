# https://www.jamf.com/blog/reinstall-a-clean-macos-with-one-button/

curl -L aka.ms/EnrollMyMac --output /tmp/intune.pkg

softwareupdate --fetch-full-installer

'/Applications/Install macOS Catalina.app/Contents/Resources/startosinstall' --eraseinstall --agreetolicense \
--forcequitapps --newvolumename 'Macintosh HD' --installpackage '/tmp/intune.pkg'