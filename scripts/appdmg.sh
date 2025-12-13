#!/bin/bash
set -ex

if [ ! -e "src/api/api.h" ]; then
  echo "Please run this script from the root directory of Avi Studio."
  exit 1
fi

cat > avi-studio-dmg.json << EOF
{
  "title": "Avi Studio",
  "icon": "$(pwd)/resources/icons/icon.icns",
  "background": "$(pwd)/resources/macos/appdmg.png",
  "window": {
    "position": {
      "x": 360,
      "y": 360
    },
    "size": {
      "width": 480,
      "height": 360
    }
  },
  "contents": [
    { "x": 144, "y": 248, "type": "file", "path": "$(pwd)/Avi Studio.app" },
    { "x": 336, "y": 248, "type": "link", "path": "/Applications" }
  ]
}
EOF
~/node_modules/appdmg/bin/appdmg.js avi-studio-dmg.json "$(pwd)/$1.dmg"
