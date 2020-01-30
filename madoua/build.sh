
echo "*******************************************************************************"
echo "Setting up environment..."
echo "*******************************************************************************"

set -o errexit

BASE_PWD=$PWD
PATH=".:./asm/bin/:$PATH"
INROM="madoua.gg"
OUTROM="madoua_en.gg"
WLADX="./wla-dx/binaries/wla-z80"
WLALINK="./wla-dx/binaries/wlalink"

cp "$INROM" "$OUTROM"

mkdir -p out

echo "*******************************************************************************"
echo "Building tools..."
echo "*******************************************************************************"

make blackt
make libsms
make

if [ ! -f $WLADX ]; then
  
  echo "********************************************************************************"
  echo "Building WLA-DX..."
  echo "********************************************************************************"
  
  cd wla-dx
    cmake -G "Unix Makefiles" .
    make
  cd $BASE_PWD
  
fi

echo "*******************************************************************************"
echo "Building font..."
echo "*******************************************************************************"

mkdir -p out/font
vwf_fontbuild rsrc/font_vwf/ out/font/ 0x1

#convert rsrc/title.png -dither None -remap rsrc/orig/title.png PNG32:rsrc/title.png

# echo "*******************************************************************************"
# echo "Building graphics..."
# echo "*******************************************************************************"
# 
# mkdir -p out/precmp
# mkdir -p out/grp
# #grpundmp_gg rsrc/font.png out/precmp/font.bin 0x90
# #grpundmp_gg rsrc/battle_font.png out/grp/battle_font.bin 0x17
# 
# grpundmp_gg rsrc/stageinfo.png out/grp/stageinfo.bin 8
# 
# grpundmp_gg rsrc/unit_moves_left.png out/grp/unit_moves_left.bin 8
# filepatch "$OUTROM" 0x92CF out/grp/unit_moves_left.bin "$OUTROM"
# 
# grpundmp_gg rsrc/resupply_complete.png out/grp/resupply_complete.bin 8
# filepatch "$OUTROM" 0x93CF out/grp/resupply_complete.bin "$OUTROM"
# 
# grpundmp_gg rsrc/completed_1.png out/grp/completed_1.bin 12 -r 4
# grpundmp_gg rsrc/completed_2.png out/grp/completed_2.bin 12 -r 4
# grpundmp_gg rsrc/completed_3.png out/grp/completed_3.bin 12 -r 4
# grpundmp_gg rsrc/completed_4.png out/grp/completed_4.bin 12 -r 4
# filepatch "$OUTROM" 0x3161E out/grp/completed_1.bin "$OUTROM"
# filepatch "$OUTROM" 0x3179E out/grp/completed_2.bin "$OUTROM"
# filepatch "$OUTROM" 0x3191E out/grp/completed_3.bin "$OUTROM"
# filepatch "$OUTROM" 0x31A9E out/grp/completed_4.bin "$OUTROM"
# 
# grpundmp_gg rsrc/congratulations_continued_1.png out/grp/congratulations_continued_1.bin 6 -r 3
# grpundmp_gg rsrc/congratulations_continued_2.png out/grp/congratulations_continued_2.bin 6 -r 3
# filepatch "$OUTROM" 0x69AF3 out/grp/congratulations_continued_1.bin "$OUTROM"
# filepatch "$OUTROM" 0x69BB3 out/grp/congratulations_continued_2.bin "$OUTROM"
# 
# grpundmp_gg rsrc/compendium_menulabel.png out/grp/compendium_menulabel.bin 9
# 
# grpundmp_gg rsrc/font_credits.png out/grp/font_credits.bin 0x50
 
echo "*******************************************************************************"
echo "Building tilemaps..."
echo "*******************************************************************************"

mkdir -p out/maps
mkdir -p out/grp

for file in tilemappers/*; do
  tilemapper_gg "$file"
done

echo "*******************************************************************************"
echo "Patching graphics..."
echo "*******************************************************************************"

mkdir -p out/grp

rawgrpconv_gg rsrc/compass_e.png rsrc/compass_structure_generic.txt "out/grp/compass.bin" $((0+(0x20*0))) "out/grp/compass.bin" -p rsrc_raw/pal/main_sprites_distinct.bin
rawgrpconv_gg rsrc/compass_w.png rsrc/compass_structure_generic.txt "out/grp/compass.bin" $((0+(0x20*6))) "out/grp/compass.bin" -p rsrc_raw/pal/main_sprites_distinct.bin
rawgrpconv_gg rsrc/compass_s.png rsrc/compass_structure_generic.txt "out/grp/compass.bin" $((0+(0x20*12))) "out/grp/compass.bin" -p rsrc_raw/pal/main_sprites_distinct.bin
rawgrpconv_gg rsrc/compass_n.png rsrc/compass_structure_generic.txt "out/grp/compass.bin" $((0+(0x20*18))) "out/grp/compass.bin" -p rsrc_raw/pal/main_sprites_distinct.bin

rawgrpconv_gg rsrc/button01.png rsrc/button_structure_generic.txt "out/grp/buttons_map.bin" $((0+(0x20*0))) "out/grp/buttons_map.bin" -p rsrc_raw/pal/main_bg_distinct.bin

rawgrpconv_gg rsrc/button02.png rsrc/button_structure_generic.txt "out/grp/buttons_save.bin" $((0+(0x20*0))) "out/grp/buttons_save.bin" -p rsrc_raw/pal/main_bg_distinct.bin

rawgrpconv_gg rsrc/button03.png rsrc/button_structure_generic.txt "out/grp/buttons_magic_item.bin" $((0+(0x20*0))) "out/grp/buttons_magic_item.bin" -p rsrc_raw/pal/main_bg_distinct.bin
rawgrpconv_gg rsrc/button04.png rsrc/button_structure_generic.txt "out/grp/buttons_magic_item.bin" $((0+(0x20*6))) "out/grp/buttons_magic_item.bin" -p rsrc_raw/pal/main_bg_distinct.bin

rawgrpconv_gg rsrc/button05.png rsrc/button_structure_generic.txt "out/grp/buttons_flee_lipemco.bin" $((0+(0x20*0))) "out/grp/buttons_flee_lipemco.bin" -p rsrc_raw/pal/main_bg_distinct.bin
rawgrpconv_gg rsrc/button06.png rsrc/button_structure_generic.txt "out/grp/buttons_flee_lipemco.bin" $((0+(0x20*6))) "out/grp/buttons_flee_lipemco.bin" -p rsrc_raw/pal/main_bg_distinct.bin

rawgrpconv_gg rsrc/button07.png rsrc/button_structure_generic.txt "out/grp/buttons_file.bin" $((0+(0x20*0))) "out/grp/buttons_file.bin" -p rsrc_raw/pal/main_bg_distinct.bin
rawgrpconv_gg rsrc/button08.png rsrc/button_structure_generic.txt "out/grp/buttons_file.bin" $((0+(0x20*6))) "out/grp/buttons_file.bin" -p rsrc_raw/pal/main_bg_distinct.bin
rawgrpconv_gg rsrc/button09.png rsrc/button_structure_generic.txt "out/grp/buttons_file.bin" $((0+(0x20*12))) "out/grp/buttons_file.bin" -p rsrc_raw/pal/main_bg_distinct.bin
rawgrpconv_gg rsrc/button10.png rsrc/button_structure_generic.txt "out/grp/buttons_file.bin" $((0+(0x20*18))) "out/grp/buttons_file.bin" -p rsrc_raw/pal/main_bg_distinct.bin

rawgrpconv_gg rsrc/button11.png rsrc/button_structure_generic.txt "out/grp/buttons_yes_no.bin" $((0+(0x20*0))) "out/grp/buttons_yes_no.bin" -p rsrc_raw/pal/main_bg_distinct.bin
rawgrpconv_gg rsrc/button12.png rsrc/button_structure_generic.txt "out/grp/buttons_yes_no.bin" $((0+(0x20*6))) "out/grp/buttons_yes_no.bin" -p rsrc_raw/pal/main_bg_distinct.bin

rawgrpconv_gg rsrc/button14.png rsrc/button_structure_generic.txt "out/grp/buttons_buy_sell_leave.bin" $((0+(0x20*0))) "out/grp/buttons_buy_sell_leave.bin" -p rsrc_raw/pal/main_bg_distinct.bin
rawgrpconv_gg rsrc/button13.png rsrc/button_structure_generic.txt "out/grp/buttons_buy_sell_leave.bin" $((0+(0x20*6))) "out/grp/buttons_buy_sell_leave.bin" -p rsrc_raw/pal/main_bg_distinct.bin
rawgrpconv_gg rsrc/button15.png rsrc/button_structure_generic.txt "out/grp/buttons_buy_sell_leave.bin" $((0+(0x20*12))) "out/grp/buttons_buy_sell_leave.bin" -p rsrc_raw/pal/main_bg_distinct.bin

rawgrpconv_gg rsrc/title_button01.png rsrc/button_structure_generic.txt "out/grp/buttons_title.bin" $((0+(0x20*0))) "out/grp/buttons_title.bin" -p rsrc_raw/pal/main_bg_distinct.bin
rawgrpconv_gg rsrc/title_button02.png rsrc/button_structure_generic.txt "out/grp/buttons_title.bin" $((0+(0x20*6))) "out/grp/buttons_title.bin" -p rsrc_raw/pal/main_bg_distinct.bin

# cp rsrc_raw/grp/kero2_entrance.bin "out/grp/kero2_entrance.bin"
# rawgrpconv_gg rsrc/kero2_sign.png rsrc/kero2_sign.txt "out/grp/kero2_entrance.bin" $((0+(0x20*1))) "out/grp/kero2_entrance.bin" -p rsrc_raw/pal/main_bg_distinct.bin
# 
# # 
# cmp1bpp_gg rsrc/gold_sign.png out/gold_sign.bin 1
# filepatch $OUTROM $((0x1F515+(0xA*8))) "out/gold_sign.bin" $OUTROM

echo "*******************************************************************************"
echo "Building script..."
echo "*******************************************************************************"

mkdir -p out/script

madoua_scriptbuild script/ table/madoua_en.tbl out/script/

echo "********************************************************************************"
echo "Applying ASM patches..."
echo "********************************************************************************"

mkdir -p "out/asm"
cp "$OUTROM" "asm/madoua.gg"

cd asm
  # apply hacks
  ../$WLADX -I ".." -o "main.o" "main.s"
  ../$WLALINK -s -v linkfile madoua_patched.gg
  
  mv -f "madoua_patched.gg" "madoua.gg"
  
  # update region code in header (WLA-DX forces it to 4,
  # for "export SMS", when the .smstag directive is used
  # -- we want 7, for "international GG")
  ../$WLADX -o "main2.o" "main2.s"
  ../$WLALINK -v linkfile2 madoua_patched.gg
cd "$BASE_PWD"

mv -f "asm/madoua_patched.gg" "$OUTROM"
mv -f "asm/madoua_patched.sym" "$(basename $OUTROM .gg).sym"
rm "asm/madoua.gg"
rm "asm/main.o"
rm "asm/main2.o"

echo "*******************************************************************************"
echo "Success!"
echo "Output file:" $OUTROM
echo "*******************************************************************************"
