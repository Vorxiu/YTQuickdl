# Features
- Simple GUI for yt-dlp 
- Easy installation
- setupMultiple configurations for different use cases easily 
- Many more
- Now correctly downloads a playlist into a folder named after the playlist
# Prerequisites

- Termux for Android 
- Termux-api from GitHub or Fdroid depending upon your Termux installation

Note : if termux-api is not working properly the script will fallback to bash
# Installation
```bash
curl -O https://raw.githubusercontent.com/Vorxiu/YTQuickdl/main/installer.sh && chmod +x installer.sh && ./installer.sh
```
The installer will automatically install and configure the script.
if you don't want the UI you can uninstall termux-api

# Updates
- Now uses Aria2 as the default downloader which is much faster compared to the default downloader

# Todo
- Spotify support
- Cookie support
