#!/bin/bash

pretty_print() {
  printf "\n%b\n" "$1"
}

checkFor() {
  type "$1" &> /dev/null ;
}

# Set continue to false by default
CONTINUE=false

pretty_print "\n###############################################"
pretty_print "#        DO NOT RUN THIS SCRIPT BLINDLY       #"
pretty_print "#         YOU'LL PROBABLY REGRET IT...        #"
pretty_print "#                                             #"
pretty_print "#              READ IT THOROUGHLY             #"
pretty_print "###############################################\n\n"

sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

echo "\nWould you like to set your computer name (as done via System Preferences >> Sharing)?  (y/n)"
read -r response
case $response in
  [yY])
      echo "What would you like it to be?"
      read COMPUTER_NAME
      sudo scutil --set ComputerName $COMPUTER_NAME --set HostName $COMPUTER_NAME --set LocalHostName $COMPUTER_NAME
      sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string $COMPUTER_NAME
      break;;
  *) break;;
esac

echo ""
echo "Check for software updates daily, not just once per week"
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

###############################################################################
# Finder
###############################################################################

echo ""
echo "Show hidden files in Finder by default? (y/n)"
read -r response
case $response in
  [yY])
    defaults write com.apple.Finder AppleShowAllFiles -bool true
    break;;
  *) break;;
esac

echo ""
echo "Show dotfiles in Finder by default? (y/n)"
read -r response
case $response in
  [yY])
    defaults write com.apple.finder AppleShowAllFiles TRUE
    break;;
  *) break;;
esac

echo ""
echo "Show all filename extensions in Finder by default? (y/n)"
read -r response
case $response in
  [yY])
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    break;;
  *) break;;
esac

echo ""
echo "Use column view in all Finder windows by default? (y/n)"
read -r response
case $response in
  [yY])
    defaults write com.apple.finder FXPreferredViewStyle Clmv
    break;;
  *) break;;
esac

echo ""
echo "Avoid creation of .DS_Store files on network volumes? (y/n)"
read -r response
case $response in
  [yY])
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    break;;
  *) break;;
esac


echo ""
echo "Allowing text selection in Quick Look/Preview in Finder by default"
defaults write com.apple.finder QLEnableTextSelection -bool true


echo ""
echo "Enabling snap-to-grid for icons on the desktop and in other icon views"
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist


echo ""
echo "Enabling the Develop menu and the Web Inspector in Safari"
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" -bool true

echo "\nAdding a context menu item for showing the Web Inspector in web views"
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

# Use current directory as default search scope in Finder
echo "\nUse current directory as default search scope in Finder"
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Show Path bar in Finder
echo "\nShow Path bar in Finder"
defaults write com.apple.finder ShowPathbar -bool true

# Show Status bar in Finder
echo "\nShow Status bar in Finder"
defaults write com.apple.finder ShowStatusBar -bool true

# Show indicator lights for open applications in the Dock
echo "\nShow indicator lights for open applications in the Dock"
defaults write com.apple.dock show-process-indicators -bool true

# Set a blazingly fast keyboard repeat rate
echo "\nSet a blazingly fast keyboard repeat rate"
defaults write NSGlobalDomain KeyRepeat -int 1

# Set a shorter Delay until key repeat
echo "\nSet a shorter Delay until key repeat"
defaults write NSGlobalDomain InitialKeyRepeat -int 12

# Show the ~/Library folder
echo "\nShow the ~/Library folder"
chflags nohidden ~/Library

###############################################################################
# Terminal
###############################################################################
echo ""
echo "Enabling UTF-8 ONLY in Terminal.app and setting the Pro theme by default"
defaults write com.apple.terminal StringEncodings -array 4
defaults write com.apple.Terminal "Default Window Settings" -string "Pro"
defaults write com.apple.Terminal "Startup Window Settings" -string "Pro"

###############################################################################
# XCode
###############################################################################
pretty_print "Installing xcode dev tools..."
if [ "$(checkFor pkgutil --pkg-info=com.apple.pkg.CLTools_Executables)" ]; then
    printf 'Command-Line Tools is not installed.  Installing..' ;
    xcode-select --install
    sleep 1
    osascript -e 'tell application "System Events"' -e 'tell process "Install Command Line Developer Tools"' -e 'keystroke return' -e 'click button "Agree" of window "License Agreement"' -e 'end tell' -e 'end tell'
fi

###############################################################################
# Homebrew
###############################################################################
if ! command -v brew &>/dev/null; then
  pretty_print "Installing Homebrew, an OSX package manager, follow the instructions..."
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if ! grep -qs "recommended by brew doctor" ~/.zshrc; then
    pretty_print "Put Homebrew location earlier in PATH ..."
      printf '\n# recommended by brew doctor\n' >> ~/.zshrc
      printf 'export PATH="/usr/local/bin:$PATH"\n' >> ~/.zshrc
      export PATH="/usr/local/bin:$PATH"
  fi
else
  pretty_print "You already have Homebrew installed...good job!"
fi

###############################################################################
# Homebrew Libs
###############################################################################
pretty_print "Updating brew formulas"
  	brew update

pretty_print "Installing GNU core utilities..."
	brew install coreutils

pretty_print "Installing GNU find, locate, updatedb and xargs..."
	brew install findutils

pretty_print "Installing the most recent verions of some OSX tools"
	brew tap homebrew/dupes
	brew install homebrew/dupes/grep

printf 'export PATH="$(brew --prefix coreutils)/libexec/gnubin:$PATH"' >> ~/.zshrc
export PATH="$(brew --prefix coreutils)/libexec/gnubin:$PATH"

###############################################################################
# Git
###############################################################################
pretty_print "Installing git for control version"
  brew install git

pretty_print "Setting up .gitconfig... (y/n)"
# Write settings to ~/.gitconfig
read -r response
case $response in
  [yY])
      echo "What name would you like use?"
      read NAME
      # $NAME for usage
      git config --global user.name $NAME

      echo "What email would you like use?"
      read EMAIL
      # $EMAIL for usage
      git config --global user.email $EMAIL

      # a global git ignore file:
      git config --global core.excludesfile '~/.gitignore'
      echo '.DS_Store' >> ~/.gitignore

      # use keychain for storing passwords
      git config --global credential.helper osxkeychain

      # you might not see colors without this
      git config --global color.ui true

      # ssh keys - probably can skip this since github app auto adds it for you which is nice
      ls -al ~/.ssh # Lists the files in your .ssh directory, if they exist
      ssh-keygen -t rsa -C $EMAIL # Creates a new ssh key, using the provided email as a label
      eval "$(ssh-agent -s)" # start the ssh-agent in the background
      ssh-add ~/.ssh/id_rsa
      pbcopy < ~/.ssh/id_rsa.pub # Copies the contents of the id_rsa.pub file to your clipboard to paste in github or w/e

      break;;
  *) break;;
esac

###############################################################################
# Homebrew Libs
###############################################################################
pretty_print "Installing NodeJS..."
  brew install node

pretty_print "Installing NPM..."
  brew install npm

pretty_print "Installing Composer..."
  brew update
  brew install composer

pretty_print "Installing cask to install apps"
  brew cask

apps=(
  firefox
  brave
  github
  microsoft-teams
  iterm2
  discord
  putty
  postman
  visual-studio-code
  oh-my-posh
  sevenzip
)

echo "Installing apps..."
brew install --cask ${apps[@]}

# when done with cask
brew update && brew upgrade brew-cask && brew cleanup && brew cask cleanup

# iterm - copy files into ~ dir
pretty_print "Setup iTerm dotnet files..."
  cp {.bash_profile,.bash_prompt,.aliases} ~

###############################################################################
# Kill affected applications
###############################################################################

echo ""
echo ""
pretty_print "################################################################################"
echo ""
echo ""
pretty_print "Note that some of these changes require a logout/restart to take effect."
pretty_print "Killing some open applications in order to take effect."
echo ""

find ~/Library/Application\ Support/Dock -name "*.db" -maxdepth 1 -delete
for app in "Activity Monitor" "Address Book" "Calendar" "Contacts" "cfprefsd" \
  "Dock" "Finder" "Mail" "Messages" "Safari" "SystemUIServer" \
  "Terminal" "Transmission"; do
  killall "${app}" > /dev/null 2>&1
done