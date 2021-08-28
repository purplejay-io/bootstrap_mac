#!/bin/zsh

HOMEBREW_CHECK=`which brew`
HOMEBREW_PATH=`echo $HOMEBREW_CHECK | cut -d "/" -f 1-3`
PYTHON3_CHECK=`which python3`
ANSIBLE_CHECK=`which ansible`

# Exit if in Virtual Environment
if [[ ! -z $VIRTUAL_ENV ]];then
  echo "You cannot run this script from a Virtual Environment!"
  exit 1
fi

# If reset selected, then run
if [[ $1 == "reset" ]];then
  echo "About to reset your laptop, are you sure you want to continue?"
  # https://unix.stackexchange.com/questions/293940/how-can-i-make-press-any-key-to-continue
  read -s -k '?Press any key to continue.'
  # sudo echo "You now have SUDO in this session"

  echo | /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
  sudo rm -Rf $HOMEBREW_PATH

  rm -Rf ~/Library/Caches/com.apple.python
  rm -Rf ~/Library/Caches/pip

  rm ansible-logs.txt
  rm ~/.config/op/config
  exit 1
fi

# Install Homebrew if not already installed
if [[ ! $HOMEBREW_CHECK =~ "bin" ]];then
  echo | /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  softwareupdate -ia

  if [[ `uname -m` == 'arm64' ]]; then
    sudo softwareupdate --install-rosetta --agree-to-license
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi

  source ~/
  brew install wireguard-tools jq
  brew install --cask 1password-cli
  source ~/
fi

# Install homebrew python3 if not already installed
if [[ ! $PYTHON3_CHECK == "$HOMEBREW_PATH/bin/python3" ]];then
  brew install python3
  source ~/
  python3 -m pip install pip --upgrade
fi

# Install ansible if not already installed
if [[ ! $ANSIBLE_CHECK == "$HOMEBREW_PATH/bin/ansible" ]];then
  python3 -m pip install -r requirements.txt
  source ~/
fi

if [[ $1 == "env" ]];then
  if [[ ! -f ~/.config/op/config ]];then
    echo "What is your Purple Jay email?"
    read EMAIL_ADDRESS
    eval $(op signin purplejayllc.1password.com $EMAIL_ADDRESS)
  else
    eval $(op signin purplejayllc)
  fi
  ansible-playbook local.yml
fi

if [[ ! -f ./env.yml ]];then
  ansible-playbook local.yml --skip-tags envyml
else
  if [[ $1 == "noupdate" ]];then
    ansible-playbook local.yml --vault-password-file .pass -e @env.yml --skip-tags update
  else
    ansible-playbook local.yml --vault-password-file .pass -e @env.yml
  fi
fi


#python3 -m pip install pip --upgrade
#
#
#sudo echo "You have sudo access now"
#
#ansible-playbook -t default local.yml