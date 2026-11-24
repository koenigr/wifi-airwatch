#!/bin/bash
# ==============================================================================
# Skript: beacon_capture.sh
# Beschreibung: 
#   Aktiviert den Monitor-Mode auf der WLAN-Schnittstelle (wlan0), protokolliert
#   den Schnittstellen-Status und schneidet den 802.11 WLAN-Datenverkehr auf einem
#   definierten 5-GHz-Kanal für genau 1 Stunde (3600 Sekunden) per tcpdump ab.
#
# Ausführung & Hinweise:
#   1. Cronjob-Einrichtung: Das Skript wird automatisch jeden Tag um 10:00 Uhr
#      über den Cronjob des Raspberry Pi ausgeführt (Hauptunterrichtszeit):
#      Aufruf via 'crontab -e':
#      0 10 * * * /home/kali/scripts/beacon_capture.sh
#
#   2. Kanal-Anpassung: Vor dem Einsatz im Klassenzimmer den WLAN-Kanal 
#      (Variable CHANNEL=44) an den exakten Frequenzkanal des Ziel-APs anpassen!
# ==============================================================================

/usr/sbin/airmon-ng check kill
/usr/sbin/airmon-ng start wlan0

/bin/sleep 5

# Status protokollieren
echo "$(/bin/date) Monitor Mode aktiv" >> /home/kali/beacon_capture/beacon_capture.log
/usr/sbin/iw dev >> /home/kali/beacon_capture/beacon_capture.log 2>&1

TIMESTAMP=$(/bin/date +%Y%m%d_%H%M)

# WLAN-Kanal setzen (bei Bedarf auf den Ziel-Kanal anpassen)
CHANNEL=44
/usr/bin/iw dev wlan0mon set channel $CHANNEL

# Eine Stunde (3600s) WLAN-Traffic mitschneiden
/usr/bin/timeout 3600 \
/usr/bin/tcpdump -i wlan0mon -s 0 \
-w /home/kali/beacon_capture/channel${CHANNEL}_${TIMESTAMP}.pcap
