# Protect start.lua
cp avi-studio/data/core/start.lua /tmp/start.lua.backup

# Sync core (only changes)
rsync -av --delete \
  --exclude=start.lua \
  data/core/ avi-studio/data/core/

# Restore protected file
mv /tmp/start.lua.backup avi-studio/data/core/start.lua

# Sync plugins (only changes)
rsync -av --delete \
  data/plugins/ avi-studio/data/plugins/


cd ./avi-studio
./avi-studio.com