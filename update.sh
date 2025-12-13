cp avi-studio/data/core/start.lua /tmp/start.lua.backup

rm -rf avi-studio/data/core
cp -r data/core avi-studio/data

mv /tmp/start.lua.backup avi-studio/data/core/start.lua

rm -rf avi-studio/data/plugins
cp -r data/plugins avi-studio/data


cd ./avi-studio
./avi-studio.com