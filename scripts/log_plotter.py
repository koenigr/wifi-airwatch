#!/usr/bin/env python3
"""
log_plotter.py - Visualisiert den Beacon-Frame Anteil über die Zeit
"""
import sys
import matplotlib.pyplot as plt

# Beispieldaten (Später durch echte Log-Daten / CSV ersetzbar)
time_stamps = ["08:00", "09:00", "10:00", "11:00", "12:00", "13:00", "14:00"]
beacon_percentage = [42, 45, 68, 71, 65, 50, 43]  # Prozentualer Beacon-Anteil

plt.figure(figsize=(10, 5))
plt.plot(time_stamps, beacon_percentage, marker='o', color='#e74c3c', linewidth=2, label='Beacon Overhead (%)')

plt.axhline(y=50, color='gray', linestyle='--', label='Kritische Schwelle (50%)')

plt.title('Wi-Fi AirWatch: Beacon Management Overhead per Hour', fontsize=14, fontweight='bold')
plt.xlabel('Uhrzeit (Stunden)', fontsize=11)
plt.ylabel('Beacon-Anteil am Gesamt-Traffic (%)', fontsize=11)
plt.grid(True, linestyle=':', alpha=0.6)
plt.legend()

plt.tight_layout()
plt.savefig('beacon_overhead_chart.png', dpi=300)
print("Diagramm erfolgreich als 'beacon_overhead_chart.png' gespeichert.")
