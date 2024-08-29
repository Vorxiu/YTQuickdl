---

# Features

- User-friendly GUI for `yt-dlp`
- Easy installation process
- Flexible configuration options for various use cases
- Enhanced playlist downloading: now saves playlists in folders named after them
- Many more 👀

# Prerequisites

- Termux for Android
- Termux-api (available via GitHub or F-Droid, depending on your Termux installation)
- `spotdl` (required if you wish to download Spotify music)
- All other dependencies are installed automatically

*Note: If `termux-api` encounters issues, the script will fall back to bash.*

# Installation

Paste the following command into your Termux terminal:

```bash
curl -O https://raw.githubusercontent.com/Vorxiu/YTQuickdl/main/installer.sh && chmod +x installer.sh && ./installer.sh
```

The installer will handle the automatic installation and configuration of the script.

# Updates

- Now utilizes Aria2 as the default downloader for improved speed

# To Do

- ~Spotdl support~

---