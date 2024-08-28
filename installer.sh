#!/data/data/com.termux/files/usr/bin/bash

# Function to print colored output
print() {
    local color=$1
    local text=$2
    case $color in
        red) echo -e "\033[0;31m$text\033[0m" ;;
        green) echo -e "\033[0;32m$text\033[0m" ;;
        yellow) echo -e "\033[0;33m$text\033[0m" ;;
        blue) echo -e "\033[0;36m$text\033[0m" ;;
        *) echo "$text" ;;
    esac
}
# function for checking if a package is working if it isn't installed an attempt is made to install it
check() {
if ! command -v "$1" &> /dev/null
then
#installing the command
echo -e "\033[0;36mInstalling $1\033[0m"
pkg install "$1" -y && echo -e "\033[0;32mInstalled $1 \033[0m" || echo -e "\e[31mCould not install $1 \e[0m"
else
   echo -e "\033[0;36m •$1 is working \033[0m"
fi
}

clear
echo "Starting..."
# Request storage permission
print blue "Allow storage permission"
termux-setup-storage || print red "Couldn't get storage permissions"

# Update packages
print blue "Updating packages"
pkg update -y && pkg upgrade -y

# Install termux-api
print yellow "Installing termux-api"
pkg install termux-api -y || print red "Couldn't install termux-api"
clear
echo -e "\e[33mMake sure you have installed the Termux API APK from F-Droid or GitHub based on your initial Termux installation\e[0m"
sleep 2
echo "Checking Termux api"
termux-toast -b black -c green -g top "Termux-api is working" && print green "Termux api is working"|| print red "Termux-api is not working"

# List of commands to check
commands=("ffmpeg" "jq" "libexpat" "openssl" "python" "aria2" "yt-dlp")
# Loop through each command in the list and check it
for cmd in "${commands[@]}"
do
    check "$cmd"
done

# Create bin directory if it doesn't exist

if [ ! -d "$HOME/bin" ]; then
mkdir -p $HOME/bin || print red "Could not create bin directory"
fi

# Download and set executable permissions for scripts
print blue "Downloading and setting permissions for scripts"
curl -o $HOME/bin/YTQuickDL.sh https://raw.githubusercontent.com/Vorxiu/YTQuickdl/main/YTQuickDL.sh && chmod +x $HOME/bin/YTQuickDL.sh || print red "Failed to download YTQuickDL.sh"
curl -o $HOME/bin/QuickConfigs.sh https://raw.githubusercontent.com/Vorxiu/YTQuickdl/main/QuickConfigs.sh && chmod +x $HOME/bin/QuickConfigs.sh || print red "Failed to download QuickConfigs.sh"
curl -o $HOME/bin/termux-url-opener https://raw.githubusercontent.com/Vorxiu/YTQuickdl/main/termux-url-opener && chmod +x $HOME/bin/termux-url-opener || print red "Failed to download termux-url-opener"
print green "installation complete"

#clearing cache
pkg autoclean
clear
print green "Starting config script required"
echo "======================================================="
bash $HOME/bin/QuickConfigs.sh || print red "couldn't start config script run it manually by:cd bin && bash QuickConfigs.sh"
