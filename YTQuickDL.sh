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

# Function in case of error
ytdl_er() {
  termux-toast -g top -b amber -c black "Something went wrong with yt-dlp"
  echo "Something went wrong with (missing formarts?) yt-dlp redownloading"
  pip install --upgrade yt-dlp
  pkg up aria2 -y
  yt-dlp -f $sub $metadta "$format" --recode-video $recode -o "$download_dir/%(title)s.%(ext)s" "$URL" && termux-toast -g bottom -b black -c yellow "Download competed with some errors"
}

# Function in case a error occurs
error_check() {
	termux-toast -g top  -b red -c black "unexpected error ಠ⁠ ⁠ل͟⁠ ⁠ಠ"|| print red "Something went wrong"
	termux-wake-unlock || echo "error occured"
	exit 1
}

trap error_check ERR

#>---------------------[Main Script]---------------------------<
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
    if [ "$QUALITY" = "Best Quality" ]; then
         FORMAT="bestvideo[ext=$recode]+bestaudio/best[ext=$recode]"
	 format="bestvideo+bestaudio/best"
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
	 "Best") FORMAT="bestaudio/best[ext=flac]/best" && recode="--recode-video flac";;
	 "High") FORMAT="bestaudio[abr>=192]/best" ;;
         "medium") FORMAT="bestaudio[abr>=128]/best" ;;
         "low") FORMAT="bestaudio[abr<128]/best" ;;
	"lowest")FORMAT="worstaudio/worst" ;;
esac

 elif [ "$TYPE" = "QuickDownload" ]; then
	QuickDownload
  else #Music Options
  FORMAT="bestaudio[ext=flac]/bestaudio[ext=m4a]/bestaudio[ext=mp3]/bestaudio/best"
  recode="flac"
  format="bestaudio/best"
  sub="--no-write-sub"
  metadata=""
  download_dir="$download_dir/Music"
  fi

  recode="--recode-video $recode"
  echo "Quality selection complete $QUALITY Using directory $download_dir"
  mkdir -p "$download_dir"
  echo -e "\033[4;34m>   [Final Variables] \033[0m \nQuality:$QUALITY \nDownload directory:$download_dir \nMetadata:$metadata \nFormat:$FORMAT \nRecoding format:$recode \n$PLAYLIST \nURL:$URL"

#-----{download started message}-------
termux-toast -s -g top -c gray -b black "$TYPE download Started..." || echo  "$TYPE download Started..."
echo -e "\033[4;34mDownload will continue in background\033[0m"

#--------[Main Yt-dl Command]-----------
yt-dlp $sub  $metadata $chp -f "$FORMAT" $recode --external-downloader aria2c --external-downloader-args "-x 16 -k 1M" -o "$download_dir/%(title)s.%(ext)s" "$URL" && \
termux-toast -g bottom -b black -c green "$TYPE download complete $QUALITY $plyt" || \
{ termux-toast -g top -b amber -c black "Something went wrong with yt-dlp";
  pip install --upgrade yt-dlp  && \
  yt-dlp -f $sub $metadta $chp "$format" --recode-video $recode -o "$download_dir/%(title)s.%(ext)s" "$URL"; }

termux-toast -g bottom -s -b black -c green "Downloaded into directory $download_dir" || echo "Downloaded into $download_dir"
termux-wake-unlock
