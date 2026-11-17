#!/bin/bash
# analyze_beacons.sh - Wertet PCAP-Dateien auf Beacon-Anteil und SSIDs aus

CAP_DIR="${1:-/home/kali/captures}"

if [ ! -d "$CAP_DIR" ]; then
    echo "Fehler: Ordner $CAP_DIR existiert nicht."
    exit 1
fi

echo "=================================================="
echo "  Wi-Fi AirWatch - Beacon Overhead Analyse"
echo "=================================================="
echo "Analyse-Ordner: $CAP_DIR"
echo ""

TOTAL_FRAMES=0
TOTAL_BEACONS=0

for pcap in "$CAP_DIR"/*.pcap; do
    [ -e "$pcap" ] || continue
    FNAME=$(basename "$pcap")
    
    # Gesamtzahl Frames im Capture
    FRAMES=$(tshark -r "$pcap" 2>/dev/null | wc -l)
    
    # Beacon Frames (Subtype 0x0008)
    BEACONS=$(tshark -r "$pcap" -Y "wlan.fc.type_subtype == 0x0008" 2>/dev/null | wc -l)
    
    TOTAL_FRAMES=$((TOTAL_FRAMES + FRAMES))
    TOTAL_BEACONS=$((TOTAL_BEACONS + BEACONS))
    
    if [ "$FRAMES" -gt 0 ]; then
        PERCENT=$((BEACONS * 100 / FRAMES))
        echo "Datei: $FNAME | Frames: $FRAMES | Beacons: $BEACONS ($PERCENT%)"
    fi
done

echo "--------------------------------------------------"
if [ "$TOTAL_FRAMES" -gt 0 ]; then
    OVERALL_PERCENT=$((TOTAL_BEACONS * 100 / TOTAL_FRAMES))
    echo "GESAMT-ERGEBNIS:"
    echo "  Total Frames : $TOTAL_FRAMES"
    echo "  Total Beacons: $TOTAL_BEACONS"
    echo "  Beacon-Anteil: $OVERALL_PERCENT %"
else
    echo "Keine Aufzeichnungen in $CAP_DIR gefunden."
fi
echo "=================================================="

echo ""
echo "Erkannte SSIDs im Funkfeld:"
tshark -r "$CAP_DIR"/*.pcap -Y "wlan.fc.type_subtype == 0x0008" -T fields -e wlan.ssid 2>/dev/null | sort -u | grep -v '^$'
