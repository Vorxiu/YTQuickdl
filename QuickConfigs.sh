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
    result=$(termux-dialog radio -t "$title" -v "$options" | jq -r '.text // .')
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

# Function to prompt download manager choice
prompt_download_manager() {
  local choice
  choice=$(termux-dialog radio -t "Choose Download Manager" -v "Default,aria2c" | jq -r '.text')

  case "$choice" in
    "aria2c")
      echo "--external-downloader aria2c --external-downloader-args \"-x 16 -s 16 -k 1M\""
      ;;
    *)
      echo ""
      ;;
  esac
}

# Function to select subtitles
select_subtitles() {
  local subtitle_options="none,all,auto-generated"
  local common_languages="en,es,fr,de,it,pt,ru,ja,ko,zh-CN"

  subtitle_options="$subtitle_options,$common_languages"

  if prompt_confirm "Do you want to download subtitles?"; then
    local subtitle_choice=$(prompt_radio "Choose subtitle option" "$subtitle_options")

    case "$subtitle_choice" in
      "none") return ;;
      "all") echo "--write-subs --sub-langs all" ;;
      "auto-generated") echo "--write-auto-subs --sub-langs all" ;;
      *) echo "--write-subs --sub-langs $subtitle_choice" ;;
    esac
  fi
}

# Main script starts here
echo "YT-DLP Options Configuration Script"

# Audio options
Audioformat=$(prompt_radio "Choose preferred audio extension" "best,aac,flac,mp3,m4a,opus,vorbis,wav")
echo -e "\e[32mAudio format set to $Audioformat\e[0m"

# Video options
Videoformat=$(prompt_radio "Choose preferred video extension" "mp4,webm,flv,ogg,mkv,avi")
echo -e "\e[32mVideo extension set to $Videoformat\e[0m"
# Prompt the user for the download directory

default_download_dir="/Download/YTQuickDL"
refdl_dir=$(prompt_text "Enter the download directory" "$default_download_dir")
echo -e "\e[32mDownload directory set to $refdl_dir\e[0m"


# Choose between audio and video
media_type=$(prompt_radio "Choose media type for Quick Download" "audio,video")
echo -e "\e[32mMedia type selected for Quick Download: $media_type\e[0m"

if [ "$media_type" = "audio" ]; then
  Audioquality=$(prompt_radio "Choose audio quality for Quick Download" "0 (best),1,2,3,4,5,6,7,8,9 (worst)")
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
  resolution=$(prompt_radio "Choose preferred video resolution" "best,4320p,2160p,1440p,1080p,720p,480p,360p,240p,144p")
  format=$(prompt_radio "Choose preferred video extension for Quick Download" "mp4,webm,flv,ogg,mkv,avi")
  echo -e "\e[32mVideo extension for Quick Download set to $format\e[0m"
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

# Thumbnail embedding
if prompt_confirm "Do you want to embed thumbnails?"; then
  thumbnail="--embed-thumbnail"
else
  thumbnail=""
fi
echo -e "\e[32m$thumbnail\e[0m"

# SponsorBlock option
if prompt_confirm "Do you want to use SponsorBlock?"; then
  sponsorblock="--sponsorblock-remove all"
else
  sponsorblock=""
fi
echo -e "\e[32m$sponsorblock\e[0m"

# Metadata option
if prompt_confirm "Do you want to add metadata?"; then
  metadata="--add-metadata"
else
  metadata=""
fi
echo -e "\e[32m$metadata\e[0m"

# Download Manager
#download_manager=$(prompt_download_manager)

# Create the output script with the function definition
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
metadata="$metadata $thumbnail $sponsorblock"
download_dir="/sdcard$refdl_dir"

EOF

# Append the existing script to the temporary file
cat YTQuickDL.sh >> temp.sh
# Replace the original script with the temporary file
mv temp.sh YTQuickDL.sh
chmod +x YTQuickDL.sh

echo "Final download dir $download_dir"
echo -e "\e[32mYTQuickDL configured\e[0m"