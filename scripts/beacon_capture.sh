#!/bin/bash
# Wi-Fi Beacon Capture mit Ringpuffer (20 Dateien à 200 MB, Snaplen 128 Byte)
mkdir -p /home/kali/captures
tcpdump -i wlan0mon -s 128 -C 200 -W 20 -w /home/kali/captures/beacon-\$(date +%Y%m%d_%H%M).pcap
