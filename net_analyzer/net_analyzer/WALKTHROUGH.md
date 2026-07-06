# NetAnalyzer — Walkthrough Guide

## Overview

NetAnalyzer is a Flutter-based Android mobile app for network administrators. It provides tools for subnet calculation, network monitoring, device discovery, and diagnostics — all in one portable interface.

## Prerequisites

| Tool | Version | Purpose |
|---|---|---|
| Flutter SDK | 3.x+ | Cross-platform framework |
| Android Studio | Hedgehog+ | IDE & Android toolchain |
| JDK | 17+ | Java compiler for Android |
| Android SDK | 34+ | Platform & build tools |
| Git | Any | Version control |

### Installation

```bash
# Verify Flutter installation
flutter doctor

# Ensure Android licenses are accepted
flutter doctor --android-licenses
```

## Getting Started

### Clone & Run

```bash
git clone <repo-url> net_analyzer
cd net_analyzer
flutter pub get
flutter run
```

> **Note**: Connect an Android device via USB with USB debugging enabled, or launch an Android emulator from Android Studio.

### Build APK

```bash
# Debug APK
flutter build apk --debug

# Release APK (requires signing)
flutter build apk --release

# App Bundle (for Play Store)
flutter build appbundle --release
```

## Feature Walkthrough

### 1. Subnet Calculator

**Purpose**: Calculate network address, broadcast address, usable host range, and total hosts from an IP/CIDR.

**How to use**:
1. Tap **Subnet Calculator** from the home screen
2. Enter an IPv4 address (e.g., `192.168.1.0`)
3. Enter or adjust the CIDR prefix (e.g., `24`)
4. Results display instantly:
   - Network Address
   - Broadcast Address
   - First / Last Usable Host
   - Total Hosts
   - Subnet Mask

**Technical note**: All calculations are done locally in Dart — no network calls.

---

### 2. IP Lookup

**Purpose**: Look up geolocation, ISP, and organization data for any public IP address.

**How to use**:
1. Tap **IP Lookup**
2. Your public IP is fetched automatically on load
3. Enter any IP address to look up:
   - Country, region, city
   - ISP & organization
   - Coordinates (lat/lon)
   - Timezone

**API**: Uses `ip-api.com` (free, no key required, 45 req/min limit).

---

### 3. DNS Lookup

**Purpose**: Resolve domain names to IP addresses (A, AAAA, MX, NS, TXT records).

**How to use**:
1. Tap **DNS Lookup**
2. Enter a domain (e.g., `example.com`)
3. Select record type (A, AAAA, MX, NS, TXT, CNAME)
4. Tap **Lookup**

**Technical note**: Uses `dart:io` `InternetAddress.lookup` for A/AAAA on-device, plus `dns.google` API for advanced record types.

---

### 4. Ping

**Purpose**: Check reachability and measure round-trip time to a host.

**How to use**:
1. Tap **Ping**
2. Enter an IP address or domain name
3. Tap **Ping** (sends 4 ICMP echo requests)
4. Results show:
   - Response time (ms) per packet
   - Packet loss percentage
   - Min / Avg / Max RTT

**Technical note**: Uses `dart:io` `Process.run` to shell out to the platform `ping` command. Requires `INTERNET` permission.

---

### 5. Port Scanner

**Purpose**: Scan common ports on a target IP to discover open services.

**How to use**:
1. Tap **Port Scanner**
2. Enter target IP address
3. Select port range (common: 1-1024, or custom)
4. Tap **Scan**
5. Results show open/closed/filtered ports with common service names (HTTP, SSH, FTP, etc.)

**Technical note**: Attempts TCP socket connections with configurable timeout. Runs on a background isolate to avoid blocking UI.

---

### 6. Speed Test

**Purpose**: Measure download and upload speed of the current network connection.

**How to use**:
1. Tap **Speed Test**
2. Tap **Start Test**
3. App downloads a test payload (multi-phase) to measure:
   - Download speed (Mbps)
   - Upload speed (Mbps)
   - Latency (ping)
   - Jitter
4. Results display with a history chart

**Technical note**: Downloads/upload chunks from a configurable endpoint. Default uses public speed test payloads (approx 10MB). Results are approximate, not production-grade.

---

### 7. WiFi Sender & Receiver Info

**Purpose**: Display WiFi connection details: SSID, BSSID, signal strength (RSSI), IP address, frequency band, link speed.

**How to use**:
1. Tap **WiFi Info**
2. Current network info displays automatically:
   - SSID (network name)
   - BSSID (router MAC)
   - Signal strength (dBm)
   - Frequency (2.4GHz / 5GHz / 6GHz)
   - Link speed (Mbps)
   - Local IP address
3. Tap **Refresh** to update

**Technical note**: Uses `network_info_plus` and `wifi_info_plus` packages. Requires `ACCESS_FINE_LOCATION` on Android 10+.

---

### 8. Network Traffic Monitor

**Purpose**: Real-time view of data received/sent on the device's network interface.

**How to use**:
1. Tap **Traffic Monitor**
2. Live stats display:
   - Current download speed (KB/s)
   - Current upload speed (KB/s)
   - Total data received (today)
   - Total data sent (today)
3. Tap **Start/Stop** monitoring

**Technical note**: Reads `/proc/net/dev` (Android) or uses `ConnectivityManager` APIs. Polls every 1 second.

---

### 9. Device Discovery

**Purpose**: Find all active devices on the local network — identify printers, scanners, PCs, laptops, and other hosts.

**How to use**:
1. Tap **Device Discovery**
2. Tap **Scan Network**
3. Results populate with:
   - IP address
   - MAC address
   - Hostname (if available)
   - Device type classification (printer, PC, laptop, scanner, mobile, switch, unknown)
   - Open ports (light scan on common ports)
4. Tap any device for details

**Technical note**: Uses ARP table inspection + ping sweep. Device type is inferred from open ports, MAC OUI lookup, and hostname patterns.

---

### 10. Switch Calculator

**Purpose**: Calculate how many switches are needed for a given number of devices, factoring in port density.

**How to use**:
1. Tap **Switch Calculator**
2. Enter:
   - Total number of devices
   - Ports per switch (24, 48, custom)
   - Uplink ports reserved
3. Results: number of switches, total available ports, ports remaining

---

### 11. Virtual Switch Calculator

**Purpose**: Plan VLAN trunking — calculate required switch ports accounting for VLAN trunks, port channels, and redundancy.

**How to use**:
1. Tap **Virtual Switch Calculator**
2. Enter:
   - Number of VLANs
   - Access ports per VLAN
   - Trunk ports
   - Redundancy factor (1 for none, 2 for HA)
3. Results: total physical ports needed, switches required, recommended port density

---

### 12. Device Name & Process Analysis

**Purpose**: Categorize and count device types on the network — "how many printers, scanners, PCs, laptops are connected?"

**How to use**:
1. Run **Device Discovery** first
2. Tap **Device Analysis** (or a tab on the results screen)
3. View:
   - Pie chart by device type
   - Count per category
   - List filtered by type
   - Export summary as text

---

## Android Permissions

The following permissions are declared in `AndroidManifest.xml`:

| Permission | Purpose | Required |
|---|---|---|
| `INTERNET` | API calls, ping, DNS | Yes |
| `ACCESS_NETWORK_STATE` | Detect connection status | Yes |
| `ACCESS_WIFI_STATE` | Read WiFi SSID, BSSID | Yes |
| `ACCESS_FINE_LOCATION` | WiFi scan results (Android 10+) | Conditional |
| `CHANGE_WIFI_STATE` | Future features | No |

## Troubleshooting

| Issue | Solution |
|---|---|
| `flutter doctor` shows missing Android SDK | Install via Android Studio SDK Manager |
| Location permission denied | Enable GPS/WiFi scanning in device settings |
| Build fails on Gradle | Update `gradle-wrapper.properties` distribution URL |
| Ping returns "permission denied" | Ensure `INTERNET` permission is in manifest |
| IP Lookup times out | Check internet connectivity; retry after 1 second |

## Building for Release

1. Generate a signing key:
   ```bash
   keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. Create `android/key.properties` with keystore path, passwords, alias.
3. Run `flutter build apk --release` or `flutter build appbundle --release`.

---

## Project Structure (Quick Reference)

```
net_analyzer/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   │   ├── theme/
│   │   ├── router/
│   │   └── utils/
│   └── features/
│       ├── subnet_calculator/
│       ├── ip_lookup/
│       ├── dns_lookup/
│       ├── ping/
│       ├── port_scanner/
│       ├── speed_test/
│       ├── wifi_info/
│       ├── traffic_monitor/
│       ├── device_discovery/
│       ├── switch_calculator/
│       └── virtual_switch_calculator/
├── android/
├── test/
└── pubspec.yaml
```
