#!/bin/bash

# Linuxis on DVD seade tavaliselt /dev/sr0
DEV="/dev/sr0"

# Näita kõik pealkirjad koos numbritega
echo "Saadaval pealkirjad:"
HandBrakeCLI -i "$DEV" --scan 2>&1 | \
  awk '
    /\+ title [0-9]+:/ {title=$3}
    /duration: [0-9]+:[0-9]+:[0-9]+/ {split($2,t,":"); kestus=sprintf("%02d:%02d:%02d",t[1],t[2],t[3]);}
    /size: [0-9]+x[0-9]+/ {
      split($2,xy,"x");
      w=xy[1]; h=xy[2];
      pixels=w*h;
      if (title && kestus && w && h) {
        print title ": Kestus " kestus ", Resolutsioon " w "x" h ", Pikslid " pixels;
      }
      title=""; kestus=""; w=""; h="";
    }
  '

echo ""
read -p "Sisesta pealkirja number, mida soovid rippida: " TITLE
[[ -z "$TITLE" ]] && echo "❌ Pealkirja number puudub." && exit 1

# Kasuta timestampi faili nimeks
DISC_LABEL="dvd_$(date +%Y%m%d_%H%M%S)"
OUTPUT_FILE="${PWD}/${DISC_LABEL// /_}.mp4"

echo "🎬 Rippin '$DISC_LABEL', title $TITLE -> $OUTPUT_FILE"

HandBrakeCLI \
  -i "$DEV" \
  -o "$OUTPUT_FILE" \
  --title "$TITLE" \
  -f mp4 \
  -e x264 \
  -q 0 \
  --encoder-preset slow \
  -B 192 \
  --audio-lang-list est \
  --all-audio \
  --subtitle-lang-list est \
  --all-subtitles \
  --markers \
  --optimize

echo "✅ Valmis: $OUTPUT_FILE"
