#!/data/data/com.termux/files/usr/bin/bash

# Function to print colored output
print() {
    local color=$1
    local text=$2
    case $color in
        red) echo -e "\033[0;31m$text\033[0m" ;;
        green) echo -e "\033[0;32m$text\033[0m" ;;
        yellow) echo -e "\033[0;33m$text\033[0m" ;;
        blue) echo -e "\033[0;36m$text\033[0m" ;;  # Fixed color code
        *) echo "$text" ;;
    esac
}

# Request storage permission
print blue "Allow storage permission"
sleep 1
termux-setup-storage || print red "Couldn't get storage permissions"

# Update packages
print blue "Updating packages"
pkg update -y && pkg upgrade -y || print red "Failed to update packages"

# Install termux-api
print yellow "Installing termux-api"
pkg install termux-api -y || print red "Couldn't install termux-api"
print yellow "Make sure you have installed the Termux API APK from F-Droid or GitHub based on your initial Termux installation"
sleep 2

# Install required packages
print blue "Installing ffmpeg, jq, libexpat, and openssl"
pkg install ffmpeg -y || print red "Could not install ffmpeg"
pkg install jq -y || print red "Could not install jq"
pkg install libexpat -y || print red "Could not install libexpat"
pkg install openssl -y || print red "Could not install openssl"

# Install Python and yt-dlp
print blue "Installing Python and yt-dlp"
pkg install python -y || print red "Could not install Python"
pip install -U "yt-dlp[default]" || print red "Could not install yt-dlp"

# Create bin directory if it doesn't exist
mkdir -p $HOME/bin || print red "Could not create bin directory"

# Download and set executable permissions for scripts
print blue "Downloading and setting permissions for scripts"
curl -o $HOME/bin/YTQuickDL.sh https://raw.githubusercontent.com/Vorxiu/YTQuickdl/main/YTQuickDL.sh && chmod +x $HOME/bin/YTQuickDL.sh || print red "Failed to download YTQuickDL.sh"
curl -o $HOME/bin/QuickConfigs.sh https://raw.githubusercontent.com/Vorxiu/YTQuickdl/main/QuickConfigs.sh && chmod +x $HOME/bin/QuickConfigs.sh || print red "Failed to download QuickConfigs.sh"
curl -o $HOME/bin/termux-url-opener https://raw.githubusercontent.com/Vorxiu/YTQuickdl/main/termux-url-opener && chmod +x $HOME/bin/termux-url-opener || print red "Failed to download termux-url-opener"
print green "installation complete"
clear
#----------------------------------

print green "Starting config script required"
bash $HOME/bin/QuickConfigs.sh || print red "couldn't start config script run it manually by:cd bin && bash QuickConfigs.sh"