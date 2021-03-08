#!/bin/bash

# Allow Touch ID to sudo 
cat << EOF > .sudo
# sudo: auth account password session
auth       sufficient     pam_tid.so
auth       sufficient     pam_smartcard.so
auth       required       pam_opendirectory.so
account    required       pam_permit.so
password   required       pam_deny.so
session    required       pam_permit.so

EOF

sudo mv .sudo /etc/pam.d/sudo
sudo chown root:wheel /etc/pam.d/sudo

# MacOS Settings
## Remove all icons from the dock
defaults write com.apple.dock persistent-apps -array
killall Dock

## 3 finger drag
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -int 1

## single touch
defaults write com.apple.AppleMultitouchTrackpad Clicking -int 1
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -int 1

## Search within current folder
defaults write com.apple.finder FXDefaultSearchScope SCcf

## Show Status Bar
defaults write com.apple.finder ShowStatusBar -int 1

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

if [[ `uname -m` == 'arm64' ]]; then
    sudo softwareupdate --install-rosetta
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

brew install python3 npm nmap tree wget 

brew install --cask github visual-studio-code
brwe install --cask intune-company-portal microsoft-edge microsoft-office microsoft-teams
brew install --cask 1password homebrew/cask-drivers/yubico-yubikey-manager
brew install --cask jetbrains-toolbox
brew install --cask firefox
brew install --cask mactex
brew install --cask wireshark

if [[ ! `uname -m` == 'arm64' ]]; then
    brew install --cask docker
fi

