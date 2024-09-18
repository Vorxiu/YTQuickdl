#!/bin/bash

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
sudo apt install "$1" -y && echo -e "\033[0;32mInstalled $1 \033[0m" || echo -e "\e[31mCould not install $1 \e[0m" \ sleep 1;
else
   echo -e "\033[0;36m $1 is working \033[0m"
fi
}
clear
echo "Starting..."

# Update packages
print blue "Updating packages"
sudo apt update -y && sudo apt upgrade -y

# List of commands to check
commands=("ffmpeg" "python" "aria2")
# Loop through each command in the list and check it
for cmd in "${commands[@]}"
do
    check "$cmd"
done

pip install yt-dlp || print red "couldn't install yt-dlp"

# Create bin directory if it doesn't exist
dir="$HOME/YTDL"
if [ ! -d "$dir" ]; then
mkdir -p $dir || print red "Could not create bin directory"
fi

# Download and set executable permissions for scripts
print blue "Downloading and setting permissions for scripts"
curl -o $dir/YTQuickDL.sh https://raw.githubusercontent.com/Vorxiu/YTQuickdl/main/YTQuickDL.sh && chmod +x $dir/YTQuickDL.sh || print red "Failed to download YTQuickDL.sh"
curl -o $dir/QuickConfigs.sh https://raw.githubusercontent.com/Vorxiu/YTQuickdl/main/QuickConfigs.sh && chmod +x $dir/QuickConfigs.sh || print red "Failed to download QuickConfigs.sh"
curl -o $dir/termux-url-opener https://raw.githubusercontent.com/Vorxiu/YTQuickdl/main/termux-url-opener && chmod +x $dir/termux-url-opener || print red "Failed to download termux-url-opener"
print green "installation complete"

print "    Press any key to continue   "
read response
print green "Starting config script required"
echo "======================================================="
bash $dir/QuickConfigs.sh || print red "couldn't start config script run it manually by:cd bin && bash QuickConfigs.sh"
