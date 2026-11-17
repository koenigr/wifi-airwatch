#!/bin/bash
# autostart_airwatch.sh - Automatische Aktivierung von Monitor-Mode & Capture beim Booten

# 1. Konfiguration
CHANNEL=36                          # Ziel-Kanal (z. B. 36 für 5GHz oder 6 für 2.4GHz)
CAP_DIR="/home/kali/captures"
LOG_FILE="/home/kali/autostart.log"

mkdir -p "$CAP_DIR"
echo "=== Boot-Vorgang: $(date) ===" >> "$LOG_FILE"

# 2. Störende WLAN-Dienste beenden & Monitor Mode aktivieren
airmon-ng check kill >> "$LOG_FILE" 2>&1
airmon-ng start wlan0 >> "$LOG_FILE" 2>&1

# Kurz warten, bis Interface wlan0mon bereit ist
sleep 3

# 3. Ziel-Kanal setzen
iw dev wlan0mon set channel $CHANNEL >> "$LOG_FILE" 2>&1
echo "Interface wlan0mon auf Kanal $CHANNEL gesetzt." >> "$LOG_FILE"

# 4. Automatisches Capture mit Ringpuffer starten
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
echo "Starte Capture..." >> "$LOG_FILE"

tcpdump -i wlan0mon -s 128 -C 200 -W 20 -w "$CAP_DIR/beacon_${TIMESTAMP}.pcap" >> "$LOG_FILE" 2>&1 &

echo "Capture erfolgreich im Hintergrund gestartet." >> "$LOG_FILE"
