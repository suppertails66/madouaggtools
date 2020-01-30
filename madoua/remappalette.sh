
set -o errexit

#convert "rsrc/grp/$1" -dither None -remap "rsrc/orig/grp/$1" "PNG32:rsrc/grp/$1"

function outlineSolidPixelsWhite() {
  convert "$1" \( +clone -channel A -morphology EdgeOut Diamond -negate -threshold 0 -negate +channel +level-colors white \) -compose DstOver -composite "$2"
}

function outlineSolidPixelsBlack() {
  convert "$1" \( +clone -channel A -morphology EdgeOut Diamond -negate -threshold 0 -negate +channel +level-colors black \) -compose DstOver -composite "$2"
}

# for file in {rsrc/button*.png,rsrc/title_button*.png}; do
#   echo $file
#   convert "$file" -dither None -remap "rsrc_raw/button_remap_palette.png" "PNG32:$file"
# done;
# 
# for file in rsrc/compass*.png; do
#   echo $file
#   convert "$file" -dither None -remap "rsrc_raw/compass_remap_palette.png" "PNG32:$file"
# done;
# 
# convert "redraws.png" -dither None -remap "redraws_pal.png" "PNG32:redraws_remap.png"

# outlineSolidPixelsWhite "subtitle.png" "subtitle_remap.png"
# outlineSolidPixelsBlack "subtitle_remap.png" "subtitle_remap.png"

# convert "rsrc/title_logo_back.png" -dither none -remap "rsrc/title_logo_back_pal.png" "PNG32:rsrc/title_logo_back_remap.png"

convert "rsrc/ending1_explosion3.png" -dither None -remap "rsrc/orig/ending1_explosion3.png" "PNG32:rsrc/ending1_explosion3.png"
convert "rsrc/compile_logo2.png" -dither None -remap "rsrc/orig/compile_logo2.png" "PNG32:rsrc/compile_logo2.png"
