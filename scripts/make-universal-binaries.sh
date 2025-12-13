#!/usr/bin/env bash
set -ex

if [ ! -e "src/api/api.h" ]; then
  echo "Please run this script from the root directory of Avi Studio."
  exit 1
fi

WORKDIR="work"
DMGDIR="$1"

if [[ -z "$DMGDIR" ]]; then
	echo "Please provide a path containing the dmg files."
	exit 1
fi

rm -rf "$WORKDIR"
mkdir -p "$WORKDIR"

for dmg_path in "$DMGDIR"/*.dmg; do
	dmg="${dmg_path##*/}"
	dmg="${dmg%.dmg}"
	hdiutil attach -mountpoint "/Volumes/$dmg" "$dmg_path"
	if [[ ! -d "$WORKDIR/dmg" ]]; then
		ditto "/Volumes/$dmg/Avi Studio.app" "Avi Studio.app"
	fi
	cp "/Volumes/$dmg/Avi Studio.app/Contents/MacOS/avi-studio" "$WORKDIR/$dmg-avi-studio"
	hdiutil detach "/Volumes/$dmg"
done

lipo -create -output "Avi Studio.app/Contents/MacOS/avi-studio" "$WORKDIR/"*-avi-studio

source scripts/appdmg.sh "$2"
