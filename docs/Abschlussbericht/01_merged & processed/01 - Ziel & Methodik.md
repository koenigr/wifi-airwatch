# 01 - Ziel & Methodik

Dieses Kapitel beschreibt die Ausgangslage, die Zielsetzung sowie die systematische Untersuchungs- und Messmethodik des Projekts zur Analyse und Stabilisierung des Schulnetzwerks.

---

## 1. Ausgangslage & Problemstellung (Zustand Anfangsphase)

In der Anfangsphase des Projekts wurden aus dem laufenden Schulbetrieb wiederholt gravierende Leistungseinbußen und Verbindungsstörungen gemeldet. Die Symptome traten insbesondere während der Vormittags-Stoßzeiten (10:00 bis 12:00 Uhr) auf, wenn eine hohe Anzahl an Schüler- und Lehrer-iPads gleichzeitig im Unterricht eingesetzt wurde.

Die Berichte und initialen Fehleranalysen zeigten folgendes Lagebild:

* **Flächendeckendes Fehlerbild:** Die Rückmeldungen beschränkten sich nicht auf einen einzelnen Gebäudeteil oder den UniFi-versorgten Testflur. Störungen wurden aus verschiedenen Räumen und Geschossen gemeldet (u. a. Raum 205, Raum 121). Es handelte sich somit eindeutig um ein netzweites Infrastrukturproblem und nicht um einen lokal begrenzten Hardwaredefekt.
* **Beeinträchtigung der Präsentationstechnik:** Bei der Nutzung von AirPlay-Streams von iPads auf die rund 30 AirServer-Kioske kam es zu fehlerhaftem oder stark verzögertem Auffinden der Empfangsgeräte. Bereits aufgebaute Streams brachen regelmäßig mit der Fehlermeldung `NetworkInterrupted` ab.
* **Subjektive WLAN-Einbußen & Audio-Probleme:** Lehrkräfte und Schüler berichteten über träge Webseitenaufrufe, verzögerte Reaktionen interaktiver Anwendungen und insbesondere über störendes Ton-Ruckeln sowie Audio-Aussetzer bei der Medienwiedergabe.
* **Widerspruch zu Signalwerten:** Die Verbindungsprobleme traten auf, obwohl die Endgeräte volle WLAN-Signalstärke (RSSI) anzeigten und die Grundlast in leeren Gebäuden unauffällig war.

---

## 2. Projektziel

Das Hauptziel dieses Projekts ist die empirische Ursachenanalyse und nachhaltige Beseitigung der Störungen im Schulnetzwerk unter Reallastbedingungen.

Die konkreten Teilziele umfassen:

1. **Empirische Ursachenisolation:** Trennung von Vermutungen und nachgewiesenen Fakten durch objektive Paketmitschnitte und Systemmessungen im regulären Unterrichtsbetrieb.
2. **Hypothesenverifikation:** Überprüfung der ursprünglichen Hauptvermutung einer reinen mDNS-/Bonjour-Flut sowie die Untersuchung weiterer Einflussfaktoren wie WLAN-AirTime-Sättigung, Multi-SSID-Overhead, Multicast-Handling auf Switches/Firewalls und Hypervisor-Leistung.
3. **Validierung von Abhilfemaßnahmen:** Überprüfung der Wirksamkeit bereits umgesetzter Optimierungen (z. B. Bereinigung der AirServer-Schnittstellen, pfBlockerNG-Pass-Regeln für UDP 5353, Avahi-Reflector-Anpassungen) und Erarbeitung langfristiger Empfehlungen.

---

## 3. Methodik & Messarchitektur

Um eine lückenlose und nachvollziehbare Nachweisführung zu gewährleisten, wurde das Gesamtprojekt in strukturierte Untersuchungs- und Messbereiche unterteilt. Jedes Unterkapitel deckt eine spezifische Ebene der Netzwerkarchitektur ab:

* **AP Capture & Wireless Capture:** Mitschneiden von Funkpaketen direkt an den Access Points und auf der Luftschnittstelle zur Analyse von 802.11 Management-Frames, Retransmission-Raten (Packet Retries), Signal-Rausch-Verhältnissen und Roaming-Verhalten.
* **SSID-Beacon Capture:** Quantitative Erfassung des Beacon-Frame-Overheads, der durch die parallele Ausstrahlung mehrerer SSIDs auf den Netgear- und UniFi-Access-Points entsteht, sowie Bewertung der dadurch gebundenen WLAN-AirTime.
* **Network AirCapture Probe (Raspberry Pi `wifi-airwatch`):** Einsatz einer autonomen Kali-Linux-Messsonde im Monitor-Mode (u. a. Kanal 36/44/48). Die Sonde zeichnet per zeitgesteuertem Cronjob (täglich um 10:00 Uhr) während des Unterrichts autark WLAN-Header im Ringpuffer auf.
* **Capture auf pfSense & Uplink - mDNS - Capture:** Mitschneiden des Datenverkehrs an den Trunk-Ports und VLAN-Schnittstellen der zentralen pfSense-Firewall zur Messung von UDP-5353-Multicast-Bursts und Inter-VLAN-Traffic.
* **Ping Messungen & Port-Auslastung:** Ermittlung von Paketlaufzeiten, Jitter und Schnittstellenbandbreiten unter synthetischer sowie realer Belastung.
* **pfSense & Hypervisor-Performance:** Auswertung der CPU-Single-Core-Auslastung, Speicherbelegung und Virtualisierungs-Performance der pfSense-VM auf dem ESXi-Server während hoher Gleichzeitigkeit.
* **Configurations, WLAN-Controller Dashboard & Ruslans-Skript:** Systematischer Abgleich der aktiven Konfigurationen (Netgear, UniFi, pfSense) mit Best-Practice-Empfehlungen, Auswertung der Controller-Metriken und Dokumentation spezifischer Skripte sowie harter System-Crashes (**konkreter Crash**).
* **Systematische Abgrenzung (Port-Wackler etc.):** Dokumentation aller geprüften physischen und logischen Komponenten zur sauberen Abgrenzung unauffälliger oder entkräfteter Fehlerquellen.
