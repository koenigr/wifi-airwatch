#!/usr/bin/env python3
"""
pcap_analyzer.py - Wi-Fi AirWatch PCAP & Beacon Overhead Analyzer

Analyzes 802.11 capture files to compute beacon frame percentage,
unique SSIDs, and frame distribution using tshark.
"""

import sys
import json
import argparse
import subprocess
from pathlib import Path


def run_cmd(cmd):
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, check=True)
        return result.stdout.strip()
    except subprocess.CalledProcessError:
        return ""


def analyze_pcap(pcap_path):
    print(f"[*] Analyzing: {pcap_path.name}")
    
    # Count total frames
    total_str = run_cmd(f"tshark -r '{pcap_path}' 2>/dev/null | wc -l")
    total_frames = int(total_str) if total_str.isdigit() else 0
    
    # Count beacon frames (Subtype 0x0008)
    beacon_str = run_cmd(f"tshark -r '{pcap_path}' -Y 'wlan.fc.type_subtype == 0x0008' 2>/dev/null | wc -l")
    beacon_frames = int(beacon_str) if beacon_str.isdigit() else 0
    
    # Extract unique SSIDs
    ssids_raw = run_cmd(f"tshark -r '{pcap_path}' -Y 'wlan.fc.type_subtype == 0x0008' -T fields -e wlan.ssid 2>/dev/null")
    ssids = sorted(list(set(s for s in ssids_raw.splitlines() if s)))
    
    pct = (beacon_frames / total_frames * 100) if total_frames > 0 else 0.0
    
    return {
        "file": pcap_path.name,
        "total_frames": total_frames,
        "beacon_frames": beacon_frames,
        "beacon_percentage": round(pct, 2),
        "detected_ssids": ssids
    }


def main():
    parser = argparse.ArgumentParser(description="Wi-Fi AirWatch PCAP Analyzer")
    parser.add_argument("path", help="Path to PCAP file or directory containing PCAP files")
    parser.add_argument("--json", action="store_true", help="Output results in JSON format")
    args = parser.parse_args()
    
    target = Path(args.path)
    if not target.exists():
        print(f"Error: Path '{target}' does not exist.", file=sys.stderr)
        sys.exit(1)
        
    pcaps = [target] if target.is_file() else list(target.glob("*.pcap"))
    if not pcaps:
        print("No .pcap files found.", file=sys.stderr)
        sys.exit(1)
        
    results = [analyze_pcap(p) for p in pcaps]
    
    if args.json:
        print(json.dumps(results, indent=2))
    else:
        print("\n" + "=" * 55)
        print("  Wi-Fi AirWatch - PCAP Analysis Summary")
        print("=" * 55)
        for r in results:
            print(f"File         : {r['file']}")
            print(f"Total Frames : {r['total_frames']}")
            print(f"Beacons      : {r['beacon_frames']} ({r['beacon_percentage']}%)")
            print(f"SSIDs ({len(r['detected_ssids'])})   : {', '.join(r['detected_ssids']) or 'None'}")
            print("-" * 55)


if __name__ == "__main__":
    main()
