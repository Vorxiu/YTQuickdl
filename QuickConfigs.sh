#!/data/data/com.termux/files/usr/bin/bash

# Function to prompt text input
prompt_text() {
  local title="$1"
  local default="$2"
  local result

  if command -v termux-dialog &> /dev/null; then
    result=$(termux-dialog text -t "$title" -i "$default" | jq -r '.text')
    echo "${result:-$default}"
  else
    echo "$title" >&2
    read -p "Enter (default: $default): " input
    echo "${input:-$default}"
  fi
}

# Function to prompt radio input
prompt_radio() {
  local title="$1"
  local options="$2"
  local result

  if command -v termux-dialog &> /dev/null; then
    result=$(termux-dialog spinner -t "$title" -v "$options" | jq -r '.text // .')
    echo "$result"
  else
    echo "$title" >&2
    IFS=',' read -ra opts <<< "$options"
    select choice in "${opts[@]}"; do
      if [[ -n $choice ]]; then
        echo "$choice"
        return 0
      fi
    done
  fi
}

# Function to prompt confirm input
prompt_confirm() {
  local prompt="$1"
  local result

  if command -v termux-dialog &> /dev/null; then
    result=$(termux-dialog confirm -t "$prompt" | jq -r '.text // .')
    [ "$result" = "yes" ]
  else
    while true; do
      read -p "$prompt (y/n): " yn
      case $yn in
        [Yy]*) return 0;;
        [Nn]*) return 1;;
        *) echo "Please answer yes or no.";;
      esac
    done
  fi
}

# Function to select subtitles
select_subtitles() {
  local subtitle_options="none,all,auto-generated"
  local common_languages="en,es,fr,de,it,pt,ru,ja,ko,zh-CN"

  subtitle_options="$subtitle_options,$common_languages"

  if prompt_confirm "Do you want to download subtitles?"; then
    local subtitle_choice=$(prompt_radio "Subtitle options" "$subtitle_options")

    case "$subtitle_choice" in
      "none") return ;;
      "all") echo "--write-subs --sub-langs all" ;;
      "auto-generated") echo "--write-auto-subs --sub-langs all" ;;
      *) echo "--write-subs --sub-langs $subtitle_choice" ;;
    esac
  fi
}

#download manager

download_manager() {
  local download_options="default,aria2c"
  local  downloadmanager=$(prompt_radio "Download manager?" "$download_options")

  case "$downloadmanager" in
      "default") echo "" ;;
      "aria2c") echo "--external-downloader aria2c" ;;
      *) echo "" ;;
   esac
}

# --------------------[Main script]-------------------
echo "YT-DLP Options Configuration Script"
termux-wake-lock
# Options used when recomended settings are selected for Quick download function
  format="mp4" #format for Quick download
  refdl_dir="/Download/YTQuickdl"
  Qdir="$refdl_dir" #Download directory for Quick download
  format_string="bestvideo[height<=720]+bestaudio/best"
# default options
  Videoformat="mp4"
  Audioformat="mp3"
  sub="--write-subs --sub-langs en"
  sponsorblock=""
  chp="--embed-chapters"
  metadata="--embed-metadata"
  thumbnail=""


  if prompt_confirm "Manually configure yt-dlp"; then

# Audio options
Audioformat=$(prompt_radio "Choose preferred audio extension" "best,aac,flac,mp3,m4a,opus,vorbis,wav")
echo -e "\e[32mAudio format set to $Audioformat\e[0m"

# Video options
Videoformat=$(prompt_radio "Choose preferred video extension" "mp4,webm,flv,ogg,mkv,avi")
echo -e "\e[32mVideo extension set to $Videoformat\e[0m"

# Prompt the user for the download directory
default_download_dir="/Download/YTQuickdl"
refdl_dir=$(prompt_text "Download directory" "$default_download_dir")
echo -e "\e[32mDownload directory set to $refdl_dir\e[0m"

# Choose between audio and video
media_type=$(prompt_radio "Media type for Quick Download" "video,audio")
echo -e "\e[32mMedia type selected for Quick Download: $media_type\e[0m"

if [ "$media_type" = "audio" ]; then
  Audioquality=$(prompt_radio "Audio quality for Quick Download" "0 (best),1,2,3,4,5,6,7,8,9 (worst)")
  format=$(prompt_radio "Choose preferred Quick Download audio extension" "best,aac,flac,mp3,m4a,opus,vorbis,wav")
  echo -e "\e[32mAudio format for quick download set to $format\e[0m"
  Qdir="$refdl_dir/Audio" #QuickDl Audio directory
  echo "$audio_dir"
  
  # Construct the format string for audio
  format_string="bestaudio[ext=$format]/best[ext=$format]/bestaudio/best"
  if [ "$Audioquality" != "0 (best)" ]; then
    audio_quality=${Audioquality%% *}
    format_string="$format_string:asr=44100::abr=${audio_quality}k"
  fi
else
  #Video Options for Quick download
  resolution=$(prompt_radio "Choose preferred video resolution" "best,1440p,1080p,720p,480p,360p,240p,144p")
  format=$(prompt_radio "Choose preferred video extension for Quick Download" "mp4,webm,flv,ogg,mkv,avi")
  echo -e "\e[32mVideo extension for Quick Download set to $format & $resolution \e[0m"
  Qdir="$refdl_dir"
  # Construct the format string for video
  if [ "$resolution" = "best" ]; then
    format_string="bestvideo[ext=$format]+bestaudio[ext=m4a]/best[ext=$format]/best"
  else
    format_string="bestvideo[height<=${resolution%%p*}][ext=$format]+bestaudio[ext=m4a]/best[height<=${resolution%%p*}][ext=$format]/best"
  fi
fi

# Subtitle options
subtitle_options=$(select_subtitles)
sub="$subtitle_options"
echo -e "\e[32mSubtitle options: $sub\e[0m"

# Chapter marks
if prompt_confirm "Do you want to mark chapters?"; then
  chp="--embed-chapters"
else
  chp=""
fi
echo -e "\e[32mchapter embeding:$chp\e[0m"

# Thumbnail embedding
if prompt_confirm "Do you want to embed thumbnails?"; then
  thumbnail="--embed-thumbnail"
else
  thumbnail=""
fi
echo -e "\e[32mthumbnail option:$thumbnail\e[0m"

# SponsorBlock option
if prompt_confirm "Do you want to use SponsorBlock?"; then
  sponsorblock="--sponsorblock-remove all"
else
  sponsorblock=""
fi
echo -e "\e[32mSponsorblock option:$sponsorblock\e[0m"

# Metadata option
if prompt_confirm "Do you want to add metadata?"; then
  metadata="--add-metadata"
else
  metadata=""
fi
echo -e "\e[32m metadata:$metadata\e[0m"

else #when using recommended Options

  #Video Options for Quick download
  resolution=$(prompt_radio "Preffered Video resolution for Quick download" "best,1440p,1080p,720p,480p,360p,240p,144p")
  echo -e "\e[32mVideo extension for Quick Download set to $format & $resolution \e[0m"
  # Construct the format string for video
  if [ "$resolution" = "best" ];  then
    format_string="bestvideo[ext=$format]+bestaudio[ext=m4a]/best[ext=$format]/best"
  else
    format_string="bestvideo[height<=${resolution%%p*}][ext=$format]+bestaudio[ext=m4a]/best[height<=${resolution%%p*}][ext=$format]/best"
 fi

  echo -e "# Options for Quick download function\n$format_string\n$format\n$Qdir\n# default options\n$Videoformat\n$Audioformat\n$sub\n$sponsorblock\n$refdl_dir\n$chp\n$metadata\n$thumbnail"

  fi
termux-wake-unlock
#---------{Writing conifgs}------------

cat > temp.sh << EOF
#!/data/data/com.termux/files/usr/bin/bash

QuickDownload() {
  FORMAT="$format_string"
  recode="$format"
  download_dir="/sdcard$Qdir"
}

# Default Options
recode="$Videoformat"
audiorecode="$Audioformat"
sub="$sub"
metadata="$chp $metadata $thumbnail $sponsorblock"
download_dir="/sdcard$refdl_dir"
EOF

# Append the existing script to the temporary file
cat "$HOME/bin/YTQuickDL.sh" >> temp.sh
# Replace the original script with the temporary file
mv temp.sh "$HOME/bin/YTQuickDL.sh"
chmod +x "$HOME/bin/YTQuickDL.sh"

# configs for termix-url-opener

cat > ~/bin/termux-url-opener << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

download_dir="$refdl_dir/songs"

SPOTDL="/data/data/com.termux/files/usr/bin/spotdl"

if [[ $1 == *"open.spotify.com"* ]]; then
    if [[ ! -d $download_dir ]]; then
        mkdir -p $download_dir
    fi
    cd $download_dir
    $SPOTDL "$1" || echo "Spotdl isn't Installed"
    termux-notification --title "Spotify download complete"
else
    ~/bin/YTQuickDL.sh "$1"
fi
EOF

chmod +x "$HOME/bin/termix-url-opener"

echo -e "\e[32mYTQuickDL configured\e[0m"
echo -e "\e[32mNow you can share a video link to termux and it will download it using yt-dlp\e[0m"
