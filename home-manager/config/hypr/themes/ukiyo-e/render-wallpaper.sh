#!/bin/sh
# Render the ukiyo-e wallpaper at a given resolution with headless Chromium.
#   ./render-wallpaper.sh 2560 1600 ukiyo-e.png        (laptop panel)
#   ./render-wallpaper.sh 3440 1440 ukiyo-e-wide.png   (ultrawides)
#
# The page exports its canvas as a PNG data URL; a screenshot would crop the
# bottom, because headless Chromium's viewport is shorter than its window.
set -eu

W=${1:?width}
H=${2:?height}
OUT=${3:?output.png}
DIR=$(cd "$(dirname "$0")" && pwd)

chromium --headless=new --no-sandbox --disable-gpu \
  --virtual-time-budget=20000 --dump-dom \
  "file://$DIR/wallpaper.html?w=$W&h=$H" 2>/dev/null |
  python3 -c '
import base64, re, sys
m = re.search(r"data:image/png;base64,([A-Za-z0-9+/=]+)", sys.stdin.read())
if not m:
    sys.exit("wallpaper.html did not produce an image")
open(sys.argv[1], "wb").write(base64.b64decode(m.group(1)))
' "$OUT"
