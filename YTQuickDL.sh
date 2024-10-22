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
        *) echo -e "$text" ;;
    esac
}


complete() {
termux-toast -s -g bottom -b black -c green "$TYPE download complete $QUALITY"
termux-notification -t "Download Complete $video_title $TYPE" --icon "done" --id 1
print green "download complete"
#termux-toast -s -g bottom -s -b black -c green "Downloaded into directory $download_dir" || echo "Downloaded into $download_dir"

}


# Function in case of format error
ytdl_er() {
  termux-toast -g top -b amber -c black "Something went wrong with yt-dlp"
  echo "Something went wrong with (missing formarts?) yt-dlp redownloading"
  pip install --upgrade yt-dlp
  pkg up aria2 -y
  yt-dlp -f "$format" $recode -o "$download_dir/%(title)s.%(ext)s" "$URL" && Complete
}

# Function in case a error occurs
error_check() {
	termux-toast -g top  -b red -c black "unexpected error ಠ⁠ ⁠ل͟⁠ ⁠ಠ"|| print red "Something went wrong"
	termux-wake-unlock || echo "error occured"
	termux-notification -t "Error occured" --icon "close" --id 1 
	echo "Press any key to exit...";read -n 1 -s;
	exit 1
	
}

trap error_check ERR
#>---------------------[Main Script]---------------------------<
# Get the shared URL
URL="$1"
termux-wake-lock || echo "couldn't get wake lock,continuing"
print green "Starting..."
TYPE="QuickDownload"
#----{Quality & Download type}-----
TYPE_RESPONSE=$(show_dialog "Download As" "Video,Audio,QuickDownload,Music") #Ask User for Download type
TYPE=$(echo $TYPE_RESPONSE | jq -r .text)
#----{Quality Selection}------
if [ "$TYPE" = "Video" ]; then
	# Ask user for quality
	QUALITY_RESPONSE=$(show_dialog "Select Video Quality" "Best,240p,360p,480p,720p,1080p,lowest")
	QUALITY=$(echo $QUALITY_RESPONSE | jq  -r .text)
	# Set yt-dlp options based on user choice
    if [ "$QUALITY" = "Best" ] || [ "$QUALITY" = "lowest" ]; then
        case $QUALITY in
         "Best") FORMAT="bestvideo[ext=$recode]+bestaudio/best[ext=$recode]" && format="bestvideo+bestaudio/best" ;;
         "lowest") FORMAT="worstvideo+worstaudio/worst" && format="worstvideo+worstaudio/worst";;
        esac
    else
	 format="bestvideo[height<=${QUALITY%%p*}]+bestaudio/best[height<=${QUALITY%%p*}]"
	 FORMAT="bestvideo[height<=${QUALITY%%p*}][ext=$recode]+bestaudio/best[height<=${QUALITY%%p*}]"
    fi

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
	recode="$Audiorecode"
	#set yt-dlp based on user choice
     case $QUALITY in
	 "Best") FORMAT="bestaudio/best[ext=flac]/best" && recode="flac";;
	 "High") FORMAT="bestaudio[abr>=192]/best" ;;
         "medium") FORMAT="bestaudio[abr>=128]/best" ;;
         "low") FORMAT="bestaudio[abr<128]/best" ;;
	"lowest")FORMAT="worstaudio/worst" format="worstaudio/worst";;
     esac

 elif [ "$TYPE" = "Music" ]; then
  #Music Options
  FORMAT="bestaudio[ext=flac]/bestaudio[ext=m4a]/bestaudio[ext=mp3]/bestaudio/best"
  recode="flac"
  format="bestaudio/best"
  sub="--write-sub en"
  metadata="--embed-metadata --embed-thumbnail"
  download_dir="$download_dir/Music"

else
 QuickDownload #calls the Quick download Function
  fi
echo -e "\033[4;34mDownload will continue in background\033[0m"
echo "Fetching configs data"


termux-notification -t "Starting Download $TYPE"  --alert-once --icon "get_app" --id 1


# Playlist check and retrieve the video_title

playlist_title=$(yt-dlp --flat-playlist --print "%(playlist_title)s" "$URL" 2>/dev/null)

#playlist_title=$(echo "$title" | sed -n '2p')

# Checks if a title was and the title isn't NA
if [ -n "$playlist_title" ] && [[ "$playlist_title" != "NA" ]]; then
    # Setting the directory
    download_dir="$download_dir/$playlist_title"
else
video_title=$(yt-dlp --get-title $URL )

fi


   if [ ! -d "$download_dir" ]; then
  mkdir -p "$download_dir" #Creating the Directory
   fi
recode="--recode-video $recode"
termux-notification -t "Download started $TYPE" --content "$video_title" --icon "get_app" --id 1

#Final variable values useful for debuging
clear
echo -e "\n\033[1;34m╔══════════════════════════════════════════════╗\033[0m"
echo -e "\033[1;34m║            \033[4;35mFinal Variables\033[0m \033[1;34m                  ║\033[0m"
echo -e "\033[1;34m╚══════════════════════════════════════════════╝\033[0m"
echo -e "\033[1;33m• \033[1;32mVideo title:       \033[0m\033[0;92m$video_title\033[0m"
echo -e "\033[1;33m• \033[1;32mQuality:           \033[0m\033[0;92m$QUALITY\033[0m"
echo -e "\033[1;33m• \033[1;32mDownload directory:\033[0m \033[0;92m$download_dir\033[0m"
echo -e "\033[1;33m• \033[1;32mDownload Type:   \033[0m\033[0;92m$TYPE\033[0m"
echo -e "\033[1;33m• \033[1;32mMetadata:          \033[0m\033[0;92m$metadata\033[0m"
echo -e "\033[1;33m• \033[1;32mFormat:            \033[0m\033[0;92m$FORMAT\033[0m"
echo -e "\033[1;33m• \033[1;32mRecoding format:   \033[0m\033[0;92m$recode\033[0m"
echo -e "\033[1;33m• \033[1;32mPlaylist Title:    \033[0m\033[0;92m$playlist_title\033[0m"
echo -e "\033[1;33m• \033[1;32mURL:               \033[0m\033[0;92m$URL\033[0m"
echo -e ""

#-----{download started message}-------
termux-toast -s -g top -c gray -b black "$video_title download Started..." || echo  "$video_title download Started..."
print green "Downloading"

#--------[Main Yt-dl Command]-----------
yt-dlp $sub $metadata -f "$FORMAT" $recode --external-downloader aria2c --external-downloader-args "-x 16 -k 1M" -o "$download_dir/%(title)s.%(ext)s" "$URL" && \
complete || \
{ ytdl_er; }

termux-wake-unlock