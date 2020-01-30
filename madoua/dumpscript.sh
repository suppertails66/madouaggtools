set -o errexit

#mkdir -p script/orig
#make libsms && make madou2_scriptdmp
#./madou2_scriptdmp madou2.gg script/orig/

mkdir -p script/orig
make libsms && make madoua_scriptdmp
./madoua_scriptdmp madoua.gg script/orig/
