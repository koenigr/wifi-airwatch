#!/bin/bash
# ==============================================================================
# TShark & Wireshark Filter Cheatsheet / Helper Script für Raspi & Laptop
# ==============================================================================
# Verwendung:
#   chmod +x filter_cheatsheet.sh
#   ./filter_cheatsheet.sh <pfad_zur_pcap_datei>
# ==============================================================================

PCAP_FILE="$1"

if [ -z "$PCAP_FILE" ]; then
    echo "======================================================================"
    echo "  Wireshark & TShark Spickzettel & Analyse-Helfer"
    echo "======================================================================"
    echo "Syntax: $0 <pcap_datei>"
    echo ""
    echo "--- Häufige Wireshark Display-Filter (zum Kopieren in die GUI) ---"
    echo " 1. Nur WLAN Beacons:           wlan.fc.type_subtype == 0x0008"
    echo " 2. Alle Management Frames:    wlan.fc.type == 0"
    echo " 3. Nach SSID filtern:         wlan.ssid == \"FCS_Paed\""
    echo " 4. Wiederholte Datenpakete:   wlan.fc.retry == 1 && wlan.fc.type == 2"
    echo " 5. mDNS Traffic (UDP 5353):    udp.port == 5353"
    echo " 6. AirPlay Discovery Services: dns.resp.name contains \"_airplay._tcp\""
    echo " 7. Bestimmte AP-BSSID:        wlan.bssid == xx:xx:xx:xx:xx:xx"
    echo " 8. Bestimmte Client-MAC:      wlan.addr == xx:xx:xx:xx:xx:xx"
    echo "======================================================================"
    exit 1
fi

if [ ! -f "$PCAP_FILE" ]; then
    echo "Fehler: Datei '$PCAP_FILE' nicht gefunden!"
    exit 1
fi

echo "======================================================================"
echo "  Schnell-Analyse für: $PCAP_FILE"
echo "======================================================================"
echo ""

echo "--- 1. Beacons pro SSID / BSSID Zählung ---"
tshark -r "$PCAP_FILE" -Y "wlan.fc.type_subtype == 8" -T fields -e wlan.bssid -e wlan.ssid 2>/dev/null | sort | uniq -c | sort -nr | head -n 20
echo ""

echo "--- 2. Retransmission-Statistik (QoS Data Frames) ---"
TOTAL_DATA=$(tshark -r "$PCAP_FILE" -Y "wlan.fc.type == 2" 2>/dev/null | wc -l)
RETRY_DATA=$(tshark -r "$PCAP_FILE" -Y "wlan.fc.type == 2 && wlan.fc.retry == 1" 2>/dev/null | wc -l)

if [ "$TOTAL_DATA" -gt 0 ]; then
    PERCENT=$(awk "BEGIN {printf \"%.2f\", ($RETRY_DATA / $TOTAL_DATA) * 100}")
    echo "Gesamt Data-Frames:    $TOTAL_DATA"
    echo "Wiederholte Frames:   $RETRY_DATA"
    echo "Retransmission-Rate:  $PERCENT %"
else
    echo "Keine Datenframes im Capture enthalten."
fi
echo ""

echo "--- 3. mDNS (UDP Port 5353) Übersicht ---"
MDNS_COUNT=$(tshark -r "$PCAP_FILE" -Y "udp.port == 5353" 2>/dev/null | wc -l)
echo "Anzahl mDNS-Pakete: $MDNS_COUNT"
echo "Top mDNS Sende-IPs:"
tshark -r "$PCAP_FILE" -Y "udp.port == 5353" -T fields -e ip.src 2>/dev/null | sort | uniq -c | sort -nr | head -n 10
echo ""

echo "======================================================================"
echo "  Analyse abgeschlossen."
echo "======================================================================"
