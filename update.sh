cp pragtical/data/core/start.lua /tmp/start.lua.backup

rm -rf pragtical/data/core
cp -r data/core pragtical/data

mv /tmp/start.lua.backup pragtical/data/core/start.lua

rm -rf pragtical/data/plugins
cp -r data/plugins pragtical/data


cd ./pragtical
./pragtical.com