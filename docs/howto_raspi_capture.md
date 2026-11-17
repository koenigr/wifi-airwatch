# How-To: Raspberry Pi Wi-Fi AirWatch Capture Probe

**Datum der Erstverwendung:** 14.10.  
**Ziel:** Automatisierte Erfassung von 802.11 Management-Frames (Beacons) im Monitor Mode via Cronjob.

---

## 1. Vorbereitung & Netzwerk-Zugriff
1. Raspberry Pi per **LAN-Kabel** an das Schulnetzwerk anschließen.
2. IP-Adresse in der pfSense (Mainrouter) ermitteln:
   * **Pfad:** `Status` → `DHCP Leases` → Suche nach Hostname `"rasp"`
   * **IP merken:** `XX.XX.XX.XX`
3. Per SSH auf den Raspberry Pi verbinden:
   ```bash
   ssh kali@XX.XX.XX.XX
   ```

---

## 2. Monitor Mode & Kanal-Einstellung
1. Störende Netzwerk-Dienste beenden & WLAN-Interface in den Monitor Mode versetzen:
   ```bash
   sudo airmon-ng check kill
   sudo airmon-ng start wlan0
   ```
2. Ziel-Kanal für den jeweiligen Raum (z. B. Raum YY → Kanal ZZ) einstellen und überprüfen:
   ```bash
   sudo iw dev wlan0mon set channel ZZ
   iw dev wlan0mon info
   ```

---

## 3. Erfassungs-Skript & Cronjob einrichten

### A) Erfassungs-Skript (`/home/kali/beacon_capture.sh`)
Das Skript nutzt einen schonenden Ringpuffer, um die SD-Karte nicht zu überlasten:
```bash
#!/bin/bash
# Wi-Fi Beacon Capture mit Ringpuffer (20 Dateien à 200 MB, Snaplen 128 Byte)
mkdir -p /home/kali/captures
tcpdump -i wlan0mon -s 128 -C 200 -W 20 -w /home/kali/captures/beacon-\$(date +%Y%m%d_%H%M).pcap
```

### B) Cronjob zur automatischen Aufzeichnung aktivieren
```bash
sudo crontab -e
```
Zeile einfügen (z. B. Start um 13:30 Uhr am gewählten Mess-Tag):
```cron
30 13 * * 4 /home/kali/beacon_capture.sh >> /home/kali/capture.log 2>&1
```
*(Hinweis Wochentag: `4` = Donnerstag, `5` = Freitag).*

Einrichtung überprüfen:
```bash
sudo crontab -l
```

---

## 4. Beenden & Daten-Export

1. **Cronjob stoppen:**
   ```bash
   sudo crontab -e
   # Zeile auskommentieren (# am Anfang einfügen) oder löschen
   ```
2. **Laufenden Capture-Prozess beenden (falls aktiv):**
   ```bash
   sudo killall tcpdump
   ```
3. **Capture-Dateien auf den eigenen Laptop kopieren (vom Laptop aus ausführen):**
   ```bash
   # Logfile kopieren
   scp kali@XX.XX.XX.XX:/home/kali/capture.log ./
   
   # Alle pcap-Dateien kopieren
   scp -r kali@XX.XX.XX.XX:/home/kali/captures/ ./
   ```
