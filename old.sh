setdefaults() {
    defaults write com.apple.dock persistent-apps -array
	killall Dock
	
	# Remove all icons from the dock
	defaults write com.apple.dock persistent-apps -array
	killall Dock
	
	# Turn the Firewall on
	sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1
	
	# 3 finger drag
	defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -int 1
	
	# single touch
	defaults write com.apple.AppleMultitouchTrackpad Clicking -int 1
	defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -int 1
	
	defaults write com.apple.finder FXDefaultSearchScope SCcf
	
	defaults write com.apple.finder ShowStatusBar -int 1

	code ./
	
	cp settings.json ~/Library/Application\ Support/Code/User/
	
}



#hash brew 2>/dev/null || {echo >&2 "I require foo but it's not installed.  Aborting."; exit 1; }

#sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 0
#To turn the firewall on for specific applications/services:

#sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1
#To turn the firewall on for essential services like DHCP and ipsec, block all the rest:

#sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 2    

brewcheck() {
    if hash brew 2>/dev/null; then
        brew update
		brew upgrade
		brew cask upgrade wireshark
		brew bundle --file=Brewfile_apple
    else
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
		brew bundle --file=Brewfile_apple
    fi
}

systemcheck() {
    brew doctor
	csrutil status
	fdesetup status
	/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate
	
	declare -a LISTENERS
	echo -e "    Listeners: ${green} `lsof -i -n -P | grep LISTEN | grep -v 127.0.0.1 | wc -l | tr -d ' '` ${magenta}[`lsof -i -n -P | grep LISTEN | grep -v 127.0.0.1 | awk '{print $1}' | sort | uniq | tr '\n' ' '`] ${foreground}"
	ls -al /Library/LaunchDaemons/
	
}

setssh() {
    mkdir -p ~/.ssh
	cp authorized_keys ~/.ssh/authorized_keys
	#cp ssh_config ~/.ssh/config
	chmod -R 700 ~/.ssh/
	
	sudo sed -i -e 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
	sudo sed -i -e 's/^#ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
	sudo sed -i -e 's/^UsePAM yes/UsePAM no/' /etc/ssh/sshd_config
	
	sudo launchctl stop com.openssh.sshd
	sudo systemsetup -setremotelogin on
	
}

setvnc() {
    sudo defaults write /Library/Preferences/com.apple.RemoteManagement.plist VNCOnlyLocalConnections -bool yes
	#sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -deactivate
	#sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -allowAccessFor -allUsers -privs -all
	
	#sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -allowAccessFor -specifiedUsers
	
	#sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -users "Brian Carlin" -access -on -privs -ControlObserve -ObserveOnly 
	
	#sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -access -on -users "Brian Carlin" -privs -all -restart -agent -menu
	
	#sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -uninstall -files -settings -prefs
	
	#sudo defaults read /var/db/launchd.db/com.apple.launchd/overrides.plist com.apple.screensharing
	
	sudo defaults write /var/db/launchd.db/com.apple.launchd/overrides.plist com.apple.screensharing -dict Disabled -bool false
	sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.screensharing.plist
	sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.screensharing.plist
	
	#if you get a "No such key: uid" error
	#sudo rm /Library/Preferences/com.apple.RemoteManagement.plist
	#/System/Library/LaunchDaemons/com.apple.remotemanagementd.plist
}

updatemacos() {
    sudo softwareupdate -ia -R
}

configpf () {
	sudo cp -p /etc/pf.conf.bak /etc/pf.conf
	sudo cp -p /etc/pf.conf /etc/pf.conf.bak
	echo "set skip on lo0" | sudo tee -a /etc/pf.conf
	echo "block in proto tcp from any to any port 5900" | sudo tee -a /etc/pf.conf
	echo "pass in inet proto tcp from any to 127.0.0.1 port 5900 no state" | sudo tee -a /etc/pf.conf
	echo "block in proto {tcp, udp} from any to any port 3283" | sudo tee -a /etc/pf.conf
	#echo "pass in inet proto tcp from 127.0.0.1 to any port 3283 no state" | sudo tee -a /etc/pf.conf
	
	sudo pfctl -f /etc/pf.conf
	sudo pfctl -E
}


brewcheck
setdefaults
setssh
setvnc
configpf
systemcheck
updatemacos