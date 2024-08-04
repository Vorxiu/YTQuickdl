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
termux-wake-lock
clear
echo "Starting..."
# Request storage permission
print blue "Allow storage permission"
termux-setup-storage || print red "Couldn't get storage permissions"
sleep 2
# Update packages
print blue "Updating packages"
pkg update -y && pkg upgrade -y || print red "Failed to update packages"
clear
# Install termux-api
print yellow "Installing termux-api"
pkg install termux-api -y || print red "Couldn't install termux-api"
clear
echo -e "\e[33mMake sure you have installed the Termux API APK from F-Droid or GitHub based on your initial Termux installation\e[0m"
sleep 2

# Install required packages
print blue "Installing ffmpeg, jq, libexpat, and openssl"
pkg install ffmpeg -y || print red "Could not install ffmpeg"
pkg install jq -y || print red "Could not install jq"
pkg install libexpat -y || print red "Could not install libexpat"
pkg install openssl -y || print red "Could not install openssl"

# Install Python and yt-dlp
print blue "Installing Python"
pkg install python -y || print red "Could not install Python"
clear
print blue "Installating yt-dlp "
pip install yt-dlp || print red "Could not install yt-dlp"
sleep 2
clear

# Create bin directory if it doesn't exist
mkdir -p $HOME/bin || print red "Could not create bin directory"

# Download and set executable permissions for scripts
print blue "Downloading and setting permissions for scripts"
curl -o $HOME/bin/YTQuickDL.sh https://raw.githubusercontent.com/Vorxiu/YTQuickdl/main/YTQuickDL.sh && chmod +x $HOME/bin/YTQuickDL.sh || print red "Failed to download YTQuickDL.sh"
curl -o $HOME/bin/QuickConfigs.sh https://raw.githubusercontent.com/Vorxiu/YTQuickdl/main/QuickConfigs.sh && chmod +x $HOME/bin/QuickConfigs.sh || print red "Failed to download QuickConfigs.sh"
curl -o $HOME/bin/termux-url-opener https://raw.githubusercontent.com/Vorxiu/YTQuickdl/main/termux-url-opener && chmod +x $HOME/bin/termux-url-opener || print red "Failed to download termux-url-opener"
print green "installation complete"
clear
#clearing cache
print blue "Freeing up space"
pkg autoclean || print red "couldn't clear apt cache"

termux-wake-unlock || print "couldn't free wake lock"
sleep 2

print green "Starting config script required"
echo "======================================================="
bash $HOME/bin/QuickConfigs.sh || print red "couldn't start config script run it manually by:cd bin && bash QuickConfigs.sh"
