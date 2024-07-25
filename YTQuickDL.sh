#!/data/data/com.termux/files/usr/bin/bash

QuickDownload() {
        FORMAT="bestvideo[height<=720][ext=mp4]+bestaudio[ext=m4a]/best[height<=720][ext=mp4]/best"
}
#------Deafault Options------
recode="--recode-video mp4"
sub="--write-subs --sub-langs en"
metadata="  --sponsorblock-remove all"
download_dir="/sdcard"
downloader="--external-downloader termux-download"


#Function to handle termux dialog and bash fallback
show_dialog() {
    local title="$1"
    local options="$2"
    local result

    if command -v termux-dialog &> /dev/null; then
        result=$(termux-dialog sheet -t "$title" -v "$options")
        exit_code=$?

        if [ $exit_code -ne 0 ]; then
            echo "Termux-dialog failed with exit code $exit_code" >&2
            echo "Falling back to Bash dialog" >&2
        else
            echo "$result"
            return 0
        fi
    else
        echo "Termux-dialog not available" >&2
        echo "Using Bash dialog" >&2
    fi

    # Fallback to Bash dialog
    echo "$title" >&2
    IFS=',' read -ra opts <<< "$options"
    select choice in "${opts[@]}"; do
        if [[ -n $choice ]]; then
            echo "{\"code\": 0, \"text\": \"$choice\"}"
            return 0
        fi
    done
}

# Function to print colored output
print() {
    local color=$1
    local text=$2
    case $color in
        red) echo -e "\033[0;31m$text\033[0m" ;;
        green) echo -e "\033[0;32m$text\033[0m" ;;
        yellow) echo -e "\033[0;33m$text\033[0m" ;;
        *) echo "$text" ;;
    esac
}

# Function in case a error occurs
error_check() {
	termux-toast -g top  -b red -c black "unexpected error ಠ⁠ ⁠ل͟⁠ ⁠ಠ"||print red "Something went wrong" 
	termux-wake-unlock || echo "error occured"
}
#trap error_check ERR

#>---------------------[Main Script]---------------------------<
download_dir="/sdcard/Download/YTQuickDL"

# Get the shared URL
URL="$1"
termux-wake-lock || echo "couldn't get wake lock,continuing"
print green "Starting..."

#---Fallback Options---
format="bestvideo+bestaudio/best"

#----Quality & Download type-----

# Ask user for download type
TYPE_RESPONSE=$(show_dialog "Download As" "Video,Audio,QuickDownload,Music")
TYPE=$(echo $TYPE_RESPONSE | jq -r .text)

#----Quality Selection----
echo "Quality selection"
if [ "$TYPE" = "Video" ]; then
	# Ask user for quality
	QUALITY_RESPONSE=$(show_dialog "Select Video Quality" "Best Quality,144p,240p,360p,480p,720p,1080p")
	QUALITY=$(echo $QUALITY_RESPONSE | jq  -r .text)
	# Set yt-dlp options based on user choice
    case $QUALITY in
        "Best Quality") FORMAT="bestvideo[ext=mp4]+bestaudio[ext=flac]/best" ;;
	"1080p") FORMAT="bestvideo[height<=1080][ext=mp4]+bestaudio/best[height<=1080]" ;;
        "720p") FORMAT="bestvideo[height<=720][ext=mp4]+bestaudio/best[height<=720]" ;;
        "480p") FORMAT="bestvideo[height<=480][ext=mp4]+bestaudio/best[height<=480]" ;;
        "360p") FORMAT="bestvideo[height<=360][ext=mp4]+bestaudio/best[height<=360]" ;;
        "240p") FORMAT="bestvideo[height<=240][ext=mp4]+bestaudio/best[height<=240]" ;;
	"144p") FORMAT="bestvideo[height<=150][ext=mp4]+bestaudio/best[height<=150]" ;;
    esac
elif [ "$TYPE" = "Audio" ]; then
	#Ask user for audio Quality
	QUALITY_RESPONSE=$(show_dialog "Select audio Quality" "Best,High,medium,low,lowest")
        QUALITY=$(echo $QUALITY_RESPONSE | jq -r .text)
	#Error handling if format isnt supported
	format="bestaudio/best"
	#subtitle handling
	sub="--no-write-sub"
	#Setting destination folder for audio files
	download_dir="$download_dir/Audio"
	recode="--recode-video mp3"
	#set yt-dlp based on user choice
     case $QUALITY in
	 "Best") FORMAT="bestaudio/best[ext=flac]/best" && recode="--recode-video flac";;
	 "High") FORMAT="bestaudio[abr>=192]/best" ;;
         "medium") FORMAT="bestaudio[abr>=128]/best" ;;
         "low") FORMAT="bestaudio[abr<128]/best" ;;
	"lowest")FORMAT="worstaudio/worst" ;;
esac

 elif [ "$TYPE" = "QuickDownload" ]; then
	QuickDownload || { print red "quick download not confiqgured properly";}
   else
  FORMAT="bestaudio[ext=flac]/bestaudio[ext=m4a]/bestaudio[ext=mp3]"
  recode="--recode-video flac"
  format="bestaudio"
  sub="--no-write-sub"
  metadata=""
  download_dir="$download_dir/Music"
  fi
  echo  "Quality selection complete $QUALITY \n Using directory $download_dir"
  mkdir -p "$download_dir"

#--------------
echo "$Quality Final download directory $download_dir $metadata $FORMAT $recode  $PLAYLIST  $URL"
# --download started message--
termux-toast -s  -g top -c gray -b black "$TYPE download Started..." || print green "$TYPE download Started..."
#Backgroud text
print green "Download will continue in background"
#-------Main Yt-dl Command-------------
yt-dlp $sub  $metadata -f "$FORMAT" $recode "$downloader"  -o "$download_dir/%(title)s.%(ext)s" "$URL" && \
termux-toast -g bottom -b black -c green "$TYPE download complete $QUALITY $plyt" && \
termux-toast -g bottom -b black -c green -s "$download_dir" || \
{ termux-toast -g top -b amber -c black "Something went wrong with yt-dlp";
  yt-dlp -U && \
  yt-dlp $sub $metadata -f "$format" $recode -o "$download_dir/%(title)s.%(ext)s" "$URL"; }

print green "Downloaded into $download_dir"
echo "Downloaded into $download_dir"
#removing wake-lock
termux-wake-unlock || print green "Done"
