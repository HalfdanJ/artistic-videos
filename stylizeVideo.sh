set -e
# Get a carriage return into `cr`
cr=`echo $'\n.'`
cr=${cr%.}

if [ "$#" -le 2 ]; then
   echo "Usage: ./stylizeVideo <name_of_video> <path_to_style_image> <w:h>"
   exit 1
fi


backend="cudnn"

echo ""
read -p "How much do you want to weight the style reconstruction term? \
Default value: 1e2 for a resolution of 450x350. Increase for a higher resolution. \
[1e2] $cr > " style_weight
style_weight=${style_weight:-1e2}

temporal_weight=1e3

echo ""
read -p "Enter the zero-indexed ID of the GPU to use, or -1 for CPU mode (very slow!).\
 [0] $cr > " gpu
gpu=${gpu:-0}



# Parse arguments
resolution=$3
video_name=$1
extension="${filename##*.}"
filename="videos/${video_name//[%]/x}/$resolution"
style_image=$2
style_name=$(basename "$style_image")
style_name="${style_name%.*}"
output_folder=output/$video_name/$style_name
# Create output folder
mkdir -p $output_folder

# Perform style transfer
th artistic_video.lua \
-content_pattern ${filename}/frame_%04d.ppm \
-flow_pattern ${filename}/flow_${resolution}/backward_[%d]_{%d}.flo \
-flowWeight_pattern ${filename}/flow_${resolution}/reliable_[%d]_{%d}.pgm \
-style_weight $style_weight \
-temporal_weight $temporal_weight \
-output_folder $output_folder/ \
-style_image $style_image \
-backend $backend \
-gpu $gpu \
-cudnn_autotune \
-number_format %04d

# Create video from output images.
#$FFMPEG -i ${filename}/out-%04d.png ${filename}-stylized.$extension
