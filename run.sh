#!/bin/zsh

HOMEBREW_CHECK=`which brew`
HOMEBREW_PATH=`echo $HOMEBREW_CHECK | cut -d "/" -f 1-3`
CURRENT_DIR=`basename "$PWD"`

if [[ ! -x "$(which brew)" ]];then
  sudo echo "Session now have sudo"
  echo | /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ `uname -m` == 'arm64' ]]; then
    sudo softwareupdate --install-rosetta --agree-to-license
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  source ~/
  HOMEBREW_PATH=`echo $HOMEBREW_CHECK | cut -d "/" -f 1-3`
fi

if [[ ! -d $HOME/.config/bootstrap_mac ]]; then
  mkdir -p $HOME/.config
  git clone https://github.com/purplejay-io/bootstrap_mac.git $HOME/.config/bootstrap_mac
fi

cd $HOME/.config/bootstrap_mac
git fetch

if [[ `git rev-list HEAD...origin/main --count` != 0 ]]; then
  git pull
fi

if [[ `git rev-list HEAD...origin/main --count` != 0 ]]; then
  exit 1
fi

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

# Install homebrew python3 if not already installed
if [[ ! "$(which brew)"  == "$HOMEBREW_PATH/bin/python3" ]];then
  brew install python3
  source ~/
  python3 -m pip install pip --upgrade
fi

# Install ansible if not already installed
if [[ ! $ANSIBLE_CHECK == "$HOMEBREW_PATH/bin/ansible" ]];then
  python3 -m pip install -r requirements.txt
  source ~/
fi

if [[ ! -x "$(which op)" ]];then
  brew install --cask 1password-cli
  source ~/
fi

if [[ ! -x "$(which wg)" ]];then
  brew install wireguard-tools jq
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