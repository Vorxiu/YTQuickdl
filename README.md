
# Features

- User-friendly GUI for `yt-dlp`
- Easy installation process
- Flexible configuration options for various use cases
- Enhanced playlist downloading: now saves playlists in folders named after them
- Many more 👀

# Prerequisites

- Termux from [GitHub](https://github.com/termux/termux-app/releases) or [Fdroid](https://f-droid.org/en/packages/com.termux/)
- Termux-api (available via [GitHub](https://github.com/termux/termux-api/releases/tag/v0.50.1) or [F-Droid](https://f-droid.org/en/packages/com.termux.api/), depending on your Termux installation)
- [`spotdl`](https://github.com/spotDL/spotify-downloader) (required if you wish to download Spotify music)
- All other dependencies are installed automatically

*Note: If `termux-api` encounters issues, the script will fall back to bash.*

# Installation

Paste the following command into your Termux terminal:

```bash
curl -O https://raw.githubusercontent.com/Vorxiu/YTQuickdl/main/installer.sh && chmod +x installer.sh && ./installer.sh
```

The installer will handle the automatic installation and configuration of the script.

For installing spotdl (Optional)
```curl -L https://raw.githubusercontent.com/spotDL/spotify-downloader/master/scripts/termux.sh | sh
```

# Updates

- Now utilizes Aria2 as the default downloader for improved speed

# To Do

- ~Spotdl support~