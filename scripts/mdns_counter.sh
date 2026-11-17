#!/bin/sh
# mdns_counter.sh - pfSense mDNS Packet & Interface Logger
# Aufruf via Cron (z. B. alle 5 Minuten)

LOG_FILE="/var/log/mdns_counter.log"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# Ordner erstellen, falls nicht vorhanden
mkdir -p $(dirname "$LOG_FILE")

# Zu überwachende Interfaces (z. B. em0, em1 oder VLANs wie em0.10)
INTERFACES="em0 em1"

echo "=== $TIMESTAMP ===" >> "$LOG_FILE"

# 1. Paket- und Byte-Zähler der Schnittstellen auslesen
echo "--- Interface Counters ---" >> "$LOG_FILE"
netstat -i -b -n | grep -E "Name|em[0-9]" >> "$LOG_FILE"

# 2. Kurzes mDNS-Sampling (5 Sekunden mDNS / UDP 5353 aufzeichnen & zählen)
echo "--- mDNS Traffic Sample (5s) ---" >> "$LOG_FILE"
for IFACE in $INTERFACES; do
    COUNT=$(timeout 5 tcpdump -i "$IFACE" -n -c 500 "udp port 5353" 2>/dev/null | wc -l)
    echo "Interface $IFACE - mDNS Packets in 5s: $COUNT" >> "$LOG_FILE"
done

echo "" >> "$LOG_FILE"
