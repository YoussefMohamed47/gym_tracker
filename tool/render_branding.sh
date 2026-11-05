#!/usr/bin/env bash
# Renders the native splash images from frame 35 of the splash Lottie (the
# still tile + bolt the Flutter splash starts from) and the app icon images.
#
# Usage (from the project root, needs Google Chrome):
#   bash tool/render_branding.sh
# Then:
#   dart run flutter_native_splash:create
#   dart run flutter_launcher_icons
set -euo pipefail

OUT="assets/branding"
WORK="$(mktemp -d)"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
LOTTIE_JSON="$(cat assets/animations/splash_logo.json)"
BOLT="M14,-70 L-42,8 L-5,8 L-17,70 L42,-11 L5,-11 Z"
mkdir -p "$OUT"

shot() { # name size transparent(0/1) html-file
  local bg=()
  if [ "$3" = 1 ]; then bg=(--default-background-color=00000000); fi
  # ${bg[@]+...}: macOS bash 3.2 treats an empty array as unset under set -u.
  "$CHROME" --headless=new --disable-gpu --hide-scrollbars ${bg[@]+"${bg[@]}"} \
    --window-size="$2,$2" --virtual-time-budget=5000 \
    --screenshot="$PWD/$OUT/$1.png" "file://$4" 2>/dev/null
}

splash() { # name canvas logo: the logo frame centred on a transparent canvas
  local name=$1 canvas=$2 logo=$3
  local off=$(( (canvas - logo) / 2 ))
  cat > "$WORK/$name.html" <<EOF
<!doctype html><html><head><meta charset="utf-8"><style>
html,body{margin:0;width:${canvas}px;height:${canvas}px;background:transparent;overflow:hidden}
#a{position:absolute;left:${off}px;top:${off}px;width:${logo}px;height:${logo}px}</style>
<script src="https://cdnjs.cloudflare.com/ajax/libs/lottie-web/5.12.2/lottie.min.js"></script>
</head><body><div id="a"></div><script>
const an=lottie.loadAnimation({container:document.getElementById("a"),renderer:"svg",
  loop:false,autoplay:false,animationData:${LOTTIE_JSON}});
an.addEventListener("DOMLoaded",()=>an.goToAndStop(35,true));
</script></body></html>
EOF
  shot "$name" "$canvas" 1 "$WORK/$name.html"
}

# 880 px = the Flutter splash's 220 dp Lottie box at 4x (xxxhdpi).
splash splash_logo 880 880
# Android 12+: 1152 px canvas (288 dp at 4x), same 880 px logo in the middle.
splash splash_logo_android12 1152 880

# iOS / legacy icon: lime square with the dark bolt.
cat > "$WORK/icon.html" <<EOF
<!doctype html><html><body style="margin:0;background:#C7F476">
<svg width="1024" height="1024" viewBox="-160 -160 320 320">
<rect x="-160" y="-160" width="320" height="320" fill="#C7F476"/>
<path d="$BOLT" transform="scale(1.19)" fill="#090E12"/></svg></body></html>
EOF
shot app_icon 1024 0 "$WORK/icon.html"

# Android adaptive foreground: bolt inside the centre safe zone.
cat > "$WORK/fg.html" <<EOF
<!doctype html><html><body style="margin:0;background:transparent">
<svg width="1024" height="1024" viewBox="-160 -160 320 320">
<path d="$BOLT" transform="scale(0.78)" fill="#090E12"/></svg></body></html>
EOF
shot app_icon_foreground 1024 1 "$WORK/fg.html"

echo "Rendered into $OUT:"
ls -1 "$OUT"
