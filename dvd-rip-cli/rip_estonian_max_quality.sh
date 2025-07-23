#!/bin/bash

# Kontrolli vajalike programmide olemasolu ja paigalda kui puudu
REQUIRED_INSTALL_CMDS=("handbrake-cli" "dvdbackup" "awk" "bash")
REQUIRED_NAMES_CMDS=("HandBrakeCLI" "dvdbackup" "awk" "bash")

# Kontrolli, et mõlemad massiivid on sama pikkusega
if [ ${#REQUIRED_INSTALL_CMDS[@]} -ne ${#REQUIRED_NAMES_CMDS[@]} ]; then
    echo "❌ Viga: REQUIRED_INSTALL_CMDS ja REQUIRED_NAMES_CMDS massiivid ei ole sama pikkusega"
    exit 1
fi

# Töötle mõlemat massiivi
for i in "${!REQUIRED_INSTALL_CMDS[@]}"; do
    install_cmd="${REQUIRED_INSTALL_CMDS[$i]}"
    check_cmd="${REQUIRED_NAMES_CMDS[$i]}"
    
    if ! command -v "$check_cmd" &> /dev/null; then
        echo "❌ Vajalik tarkvara puudub: $check_cmd"
        echo "Proovin paigaldada: sudo apt install $install_cmd -y"
        sudo apt install "$install_cmd" -y
        
        # Kontrolli uuesti, kas programm on nüüd olemas
        if ! command -v "$check_cmd" &> /dev/null; then
            echo "❌ Paigaldamine ebaõnnestus: $check_cmd"
            exit 1
        fi
    fi
done

# Linuxis on DVD seade tavaliselt /dev/sr0
DEV="/dev/sr0"

# Kontrolli, kas DVD seade on olemas
if [ ! -e "$DEV" ]; then
    echo "❌ DVD seade $DEV ei ole olemas"
    echo "Kontrolli, kas DVD on seadmes ja kas seade on õiges asukohas"
    exit 1
fi

echo "DVD seade $DEV leitud"

echo ""
echo "Vali rippimise meetod:"
echo "1. Rippida kogu DVD-si dvdbackup-ga (VOB failid)"
   echo "   * VOB failid on DVD-i põhifailid"
   echo "   * Saad valida eesti keelset põhifilmi VOB failidest"
   echo "   * VOB failid on suured, kuid kvaliteet on kõrge"
   echo "   * VOB failid saab hiljem teisendada näiteks MP4-ks"
echo "2. Rippida kogu DVD-si HandBrakeCLI-ga (MP4 fail)"
   echo "   * Teisendab DVD-i kohe MP4-ks"
   echo "   * MP4 fail on väiksem, kuid kvaliteet võib olla madalam"
   echo "   * MP4 fail on kohe mängitav mitmes playeris"
read -p "Vali meetod (1/2): " METHOD

if [ -z "$METHOD" ]; then
    echo "❌ Meetod puudub"
    exit 1
fi

echo ""
echo "Kontrollime DVD sisu..."

# Loome väljundkataloogi nimeks kasutame ajatempli
OUTPUT_DIR="$dvd_rip_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTPUT_DIR"

echo "Väljundkataloog: $OUTPUT_DIR"

if [ "$METHOD" = "1" ]; then
    echo ""
    echo "Rippime kogu DVD-si dvdbackup-ga..."
    
    # Lisame -M flag'i põhjalikule DVD backup'ile
    dvdbackup -M -i "$DEV" -o "$OUTPUT_DIR"
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "Rippimine valmis! VOB failid asuvad: $OUTPUT_DIR/"
        echo ""
        echo "Nüüd võid kätte võtta väljundkataloogist VOB failid ja"
        echo "vali seal eesti keelne põhifilm."
        echo ""
        echo "VOB failide sisu saad vaata näiteks mediaplayeriga."
        exit 0
    else
        echo "Viga DVD rippimisel dvdbackup-ga"
        exit 1
    fi
elif [ "$METHOD" = "2" ]; then
    echo ""
    echo "Rippime kogu DVD-si HandBrakeCLI-ga..."
    
    # Kasutame ajatempli MP4 faili nimeks
    HandBrakeCLI \
      -i "$DEV" \
      -o "$OUTPUT_DIR/dvd_rip_$(date +%Y%m%d_%H%M%S).mp4" \
      --preset="Normal" \
      --optimize \
      --markers
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "Rippimine valmis! MP4 fail asub: $OUTPUT_DIR/dvd_rip_$(date +%Y%m%d_%H%M%S).mp4"
        echo ""
        echo "MP4 faili sisu saad vaata näiteks mediaplayeriga."
        exit 0
    else
        echo "Viga DVD rippimisel HandBrakeCLI-ga"
        exit 1
    fi
else
    echo "❌ Vale valik"
    exit 1
fi
