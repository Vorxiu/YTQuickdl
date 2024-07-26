
#-----Fallback Format-------
format="bestvideo+bestaudio/best"

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

#----{Quality & Download type}-----
TYPE_RESPONSE=$(show_dialog "Download As" "Video,Audio,QuickDownload,Music") #Ask User for Download type
TYPE=$(echo $TYPE_RESPONSE | jq -r .text)

#----{Quality Selection}------
echo "Quality selection"
if [ "$TYPE" = "Video" ]; then
	# Ask user for quality
	QUALITY_RESPONSE=$(show_dialog "Select Video Quality" "Best Quality,144p,240p,360p,480p,720p,1080p")
	QUALITY=$(echo $QUALITY_RESPONSE | jq  -r .text)
	# Set yt-dlp options based on user choice
    case $QUALITY in
        "Best Quality") FORMAT="bestvideo[ext=mp4]+bestaudio[ext=flac]/best" ;;
	"1080p") FORMAT="bestvideo[height<=1080]+bestaudio/best[height<=1080]" ;;
        "720p") FORMAT="bestvideo[height<=720]+bestaudio/best[height<=720]" ;;
        "480p") FORMAT="bestvideo[height<=480]+bestaudio/best[height<=480]" ;;
        "360p") FORMAT="bestvideo[height<=360]+bestaudio/best[height<=360]" ;;
        "240p") FORMAT="bestvideo[height<=240]+bestaudio/best[height<=240]" ;;
	"144p") FORMAT="bestvideo[height<=150]+bestaudio/best[height<=150]" ;;
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
	recode="$Audiorecode"
	#set yt-dlp based on user choice
     case $QUALITY in
	 "Best") FORMAT="bestaudio/best[ext=flac]/best" && recode="--recode-video flac";;
	 "High") FORMAT="bestaudio[abr>=192]/best" ;;
         "medium") FORMAT="bestaudio[abr>=128]/best" ;;
         "low") FORMAT="bestaudio[abr<128]/best" ;;
	"lowest")FORMAT="worstaudio/worst" ;;
esac

 elif [ "$TYPE" = "QuickDownload" ]; then
	QuickDownload

   else
  FORMAT="bestaudio[ext=flac]/bestaudio[ext=m4a]/bestaudio[ext=mp3]/bestaudio"
  recode="--recode-video flac"
  format="bestaudio/best"
  sub="--no-write-sub"
  metadata=""
  download_dir="$download_dir/Music"
  fi
  echo  "Quality selection complete $QUALITY \n Using directory $download_dir"
  mkdir -p "$download_dir"
#-------------------------------------
echo "$Quality Final variables $download_dir $metadata $FORMAT $recode  $PLAYLIST  $URL"

#-----{download started message}-------
termux-toast -s  -g top -c gray -b black "$TYPE download Started..." || print green "$TYPE download Started..."
print green "Download will continue in background"
#--------[Main Yt-dl Command]-----------
yt-dlp $sub  $metadata -f "$FORMAT" --recode-video $recode -o "$download_dir/%(title)s.%(ext)s" "$URL" && \
termux-toast -g bottom -b black -c green "$TYPE download complete $QUALITY $plyt" && \
termux-toast -g bottom -b black -c green -s "$download_dir" || \
{ termux-toast -g top -b amber -c black "Something went wrong with yt-dlp";
  pip install --upgrade yt-dlp  && \
  yt-dlp $sub $metadata -f "$format" -o "$download_dir/%(title)s.%(ext)s" "$URL"; }

echo "Downloaded into $download_dir"
#removing wake-lock
termux-wake-unlock || print green "Done"
