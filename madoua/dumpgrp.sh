mkdir -p rsrc
mkdir -p rsrc/orig
mkdir -p rsrc_raw
mkdir -p rsrc_raw/grp
mkdir -p rsrc_raw/grp_dumped

make libsms && make rawdmp
make libsms && make grpdmp_gg
make libsms && make madou_decmp
make libsms && make grpdmp_8bpp_gg
make libsms && make tilemap_to_vram_gg
make libsms && make tilemapdmp_vram_gg

# ./madou_decmp madou3.gg 0x34795 rsrc_raw/grp/title_bg1.bin
# ./madou_decmp madou3.gg 0x35A15 rsrc_raw/grp/title_bg2.bin
# ./madou_decmp madou3.gg 0x1E9EE rsrc_raw/grp/buttons_base.bin
# ./madou_decmp madou3.gg 0x1EA9E rsrc_raw/grp/buttons_title.bin
# ./madou_decmp madou3.gg 0x1EE4C rsrc_raw/grp/buttons_file.bin
# #./madou_decmp madou3.gg 0x20000 rsrc_raw/grp/windows.bin
# #./madou_decmp madou3.gg 0x2054F rsrc_raw/grp/dungeon1bg.bin
# #./madou_decmp madou3.gg 0x2193D rsrc_raw/grp/dungeon1bg2.bin
# ./madou_decmp madou3.gg 0x229F8 rsrc_raw/grp/compass.bin
# #./madou_decmp madou3.gg 0x1C020 rsrc_raw/grp/face1.bin
# #./madou_decmp madou3.gg 0x1C1C4 rsrc_raw/grp/face2.bin
# #./madou_decmp madou3.gg 0x22326 rsrc_raw/grp/carbuncle1.bin
# ./madou_decmp madou3.gg 0x1EB8F rsrc_raw/grp/buttons_map_save.bin
# ./madou_decmp madou3.gg 0x1EC75 rsrc_raw/grp/buttons_magic_item.bin
# ./madou_decmp madou3.gg 0x1ED7D rsrc_raw/grp/buttons_flee_lipemco.bin
# ./madou_decmp madou3.gg 0x1F000 rsrc_raw/grp/buttons_buy_sell_leave.bin
# ./madou_decmp madou3.gg 0x1EF1E rsrc_raw/grp/buttons_yes_no.bin
# #./madou_decmp madou3.gg 0x1EF1E rsrc_raw/grp/test.bin
# 
# ./madou_decmp madou3.gg 0x30000 rsrc_raw/grp/kero2_entrance.bin

./madou_decmp madoua.gg 0x44b rsrc_raw/grp/compile_logo2.bin
./madou_decmp madoua.gg 0x346 rsrc_raw/grp/compile_logo2_map.bin
./madou_decmp madoua.gg 0x395d8 rsrc_raw/grp/title_logo.bin
./madou_decmp madoua.gg 0x3a4fc rsrc_raw/grp/title_back.bin
./madou_decmp madoua.gg 0x7c015 rsrc_raw/grp/title_pressstart.bin
# dst = 0x38cd -- contains high bytes for title logo tilemap
./madou_decmp madoua.gg 0x3a45a rsrc_raw/grp/title_map0.bin
# dst = 0x3A8D -- contains high bytes for title back tilemap
./madou_decmp madoua.gg 0x3b235 rsrc_raw/grp/title_map1.bin

# dst = 2080
./madou_decmp madoua.gg 0x9526 rsrc_raw/grp/button_cursor.bin
./madou_decmp madoua.gg 0x8C30 rsrc_raw/grp/buttons_map.bin
./madou_decmp madoua.gg 0x8CCA rsrc_raw/grp/buttons_magic_item.bin
./madou_decmp madoua.gg 0x8DD3 rsrc_raw/grp/buttons_save.bin
# dst = 0580
./madou_decmp madoua.gg 0x944d rsrc_raw/grp/buttons_file.bin
# dst = 0580
./madou_decmp madoua.gg 0x9578 rsrc_raw/grp/buttons_yes_no.bin
# dst = 0580
./madou_decmp madoua.gg 0x25cea rsrc_raw/grp/buttons_buy_sell_leave.bin
# dst = 0700
./madou_decmp madoua.gg 0x8e6e rsrc_raw/grp/buttons_flee_lipemco.bin
# dst = 22C0
#./madou_decmp madoua.gg 0x944d rsrc_raw/grp/buttons_file.bin
# dst = 2140
./madou_decmp madoua.gg 0x23d22 rsrc_raw/grp/buttons_title.bin

./madou_decmp madoua.gg 0x2e484 rsrc_raw/grp/ending1_grp.bin
./madou_decmp madoua.gg 0x2f3cb rsrc_raw/grp/ending1_explosion3_map.bin
./tilemapdmp_gg rsrc_raw/grp/ending1_explosion3_map.bin 0x0 full 20 10 rsrc_raw/grp/ending1_grp.bin 0 rsrc/orig/ending1_explosion3.png -p rsrc_raw/pal/ending1.bin

./madou_decmp madoua.gg 0x92da rsrc_raw/grp/compass.bin

for file in rsrc_raw/grp/*.bin; do
  FILEBASE=$(basename $file .bin)
#  ./grpdmp_gg $file rsrc_raw/grp_dumped/${FILEBASE}.png -p "rsrc_raw/pal/main_bg_distinct.bin"
  ./grpdmp_gg $file rsrc_raw/grp_dumped/${FILEBASE}.png -p "rsrc_raw/pal/main_bg_distinct.bin"
done

./grpdmp_gg "rsrc_raw/grp/compass.bin" "rsrc_raw/grp_dumped/compass.png" -p "rsrc_raw/pal/main_sprites_distinct.bin"

./grpdmp_gg "rsrc_raw/grp/ending1_grp.bin" "rsrc_raw/grp_dumped/ending1_grp.png" -p "rsrc_raw/pal/ending1.bin"

./grpdmp_8bpp_gg madoua.gg rsrc_raw/font.png 0x19AFD 0xA2

# how
# in the fuck
# do you make
# sending a single static title image
# this
# goddamn
# complicated
> "rsrc_raw/grp/title_vram.bin"
./filepatch "rsrc_raw/grp/title_vram.bin" 0x0000 "rsrc_raw/grp/title_logo.bin"  "rsrc_raw/grp/title_vram.bin"
./filepatch "rsrc_raw/grp/title_vram.bin" 0x2000 "rsrc_raw/grp/title_back.bin"  "rsrc_raw/grp/title_vram.bin"
./filepatch "rsrc_raw/grp/title_vram.bin" 0x2FC0 "rsrc_raw/grp/title_pressstart.bin"  "rsrc_raw/grp/title_vram.bin"
# okay, the game actually does this, but it's a mistake.
# they later get decompressed to RAM and are instead sent as every
# other byte only, erasing the garbage these operations leave in VRAM.
# ... okay, it's not a mistake per se, but why are these decompressed
# to VRAM at all?? they're meant to go to memory...
#./filepatch "rsrc_raw/grp/title_vram.bin" 0x38CD "rsrc_raw/grp/title_map0.bin"  "rsrc_raw/grp/title_vram.bin"
#./filepatch "rsrc_raw/grp/title_vram.bin" 0x3A8D "rsrc_raw/grp/title_map1.bin"  "rsrc_raw/grp/title_vram.bin"
./tilemap_to_vram_gg "rsrc_raw/grp/title_vram.bin" "rsrc_raw/grp/title_map0.bin" 0 20 7 0x38CD "rsrc_raw/grp/title_vram.bin" -h
./tilemap_to_vram_gg "rsrc_raw/grp/title_vram.bin" "rsrc_raw/grp/title_map1.bin" 0 20 11 0x3A8D "rsrc_raw/grp/title_vram.bin" -h
./tilemap_to_vram_gg "rsrc_raw/grp/title_vram.bin" "madoua.gg" 0x3a46d 20 18 0x38CC "rsrc_raw/grp/title_vram.bin" -h
./tilemap_to_vram_gg "rsrc_raw/grp/title_vram.bin" "madoua.gg" 0x3b246 20 18 0x3A8C "rsrc_raw/grp/title_vram.bin" -h

#./tilemapdmp_gg madoua.gg 0x3a46d half 20 18 rsrc_raw/grp/title_logo.bin 0 rsrc/orig/title_logo.png -p rsrc_raw/pal/title.bin -h 0x00
./tilemapdmp_vram_gg "rsrc_raw/grp/title_vram.bin" 0x38CC 20 7 rsrc/orig/title_logo.png -p rsrc_raw/pal/title.bin
./tilemapdmp_vram_gg "rsrc_raw/grp/title_vram.bin" 0x3A8C 20 11 rsrc/orig/title_back.png -p rsrc_raw/pal/title.bin

./tilemapdmp_gg "rsrc_raw/grp/compile_logo2_map.bin" 0 full 0x14 0x12 "rsrc_raw/grp/compile_logo2.bin" 0x0 "rsrc/orig/compile_logo2.png" -p "rsrc_raw/pal/compile_logo2.bin"



# mkdir -p rsrc/orig
# ./tilemapdmp_gg madou3.gg 0x35b70 full 20 9 rsrc_raw/grp/title_bg1.bin 0 rsrc/orig/title_logo.png -p rsrc_raw/pal/title.bin
# ./tilemapdmp_gg madou3.gg 0x35CD8 full 20 2 rsrc_raw/grp/title_bg2.bin 0 rsrc/orig/title_logo.png -p rsrc_raw/pal/title.bin


