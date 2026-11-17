# wifi-airwatch

**wifi-airwatch** is a lightweight, Raspberry Pi-based wireless network telemetry probe. Utilizing 802.11 monitor mode, it captures raw radio-frequency (RF) frames to monitor beacon frequencies, channel occupancy, neighbor network interference, and frame retransmissions in high-density Wi-Fi environments.

### Key Capabilities
* **802.11 Frame Analysis:** Captures and evaluates raw management and control frames in real-time.
* **AirTime & Overhead Metrics:** Measures beacon frame density, SSID management overhead, and retransmission rates.
* **Telemetry & SNMP Integration:** Exposes real-time signal and performance metrics via a custom enterprise Management Information Base (MIB) with dedicated OIDs and proactive SNMP Traps for instant alerting.
