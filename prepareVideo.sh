set -e
# Get a carriage return into `cr`
cr=`echo $'\n.'`
cr=${cr%.}


# Find out whether ffmpeg or avconv is installed on the system
FFMPEG=ffmpeg
command -v $FFMPEG >/dev/null 2>&1 || {
  FFMPEG=avconv
  command -v $FFMPEG >/dev/null 2>&1 || {
    echo >&2 "This script requires either ffmpeg or avconv installed.  Aborting."; exit 1;
  }
}

if [ "$#" -le 1 ]; then
   echo "Usage: ./stylizeVideo <path_to_video> <name> <w:h>"
   exit 1
fi

# Parse arguments
resolution=$3
filename=$(basename "$1")
video_name=$2
extension="${filename##*.}"
filename="videos/${video_name//[%]/x}/$resolution"

# Create output folder
echo "mkdir -p $filename"
mkdir -p $filename

if [ ! -f "${filename}/frame_0001.ppm" ]; then
    # Save frames of the video as individual image files
    if [ -z $resolution ]; then
      echo "Converting video to individual frames in ppm format"
      echo "$FFMPEG -i $1 ${filename}/frame_%04d.ppm"
      $FFMPEG -i $1 ${filename}/frame_%04d.ppm
      resolution=default
    else
        echo "Converting video to individual frames in ppm format"
        echo "$FFMPEG -i $1 -vf scale=$resolution ${filename}/frame_%04d.ppm"
        $FFMPEG -i $1 -vf scale=$resolution ${filename}/frame_%04d.ppm
    fi
fi

echo ""
echo "Computing optical flow. This may take a while..."
bash makeOptFlow.sh ./${filename}/frame_%04d.ppm ./${filename}/opticalflow
