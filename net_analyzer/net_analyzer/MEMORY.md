# NetAnalyzer — Memory Document

> Design decisions, package choices, data models, and context for future development sessions.

---

## 1. Project Overview

| Field | Value |
|---|---|
| **Project name** | `net_analyzer` |
| **Package** | `com.netanalyzer.app` |
| **Platform** | Android (minimum SDK: 24) |
| **Framework** | Flutter 3.44+ / Dart 3.12+ |
| **State management** | Riverpod (v2) |
| **Navigation** | GoRouter (declarative, deep-linkable) |

---

## 2. State Management — Riverpod

### Why Riverpod

- Compile-safe providers — no runtime `ProviderNotFoundException`
- Each network tool is an isolated provider — independent lifecycle
- `FutureProvider` for one-shot lookups (IP/DNS), `StreamProvider` for live data (traffic, speed test)
- `ref.invalidate()` for explicit refresh after scans
- No `BuildContext` needed for providers — testable in isolation

### Provider Pattern Used

```dart
// One-shot lookup
final ipLookupProvider = FutureProvider.family<IPInfo, String>((ref, ip) {
  return IPLookupService().lookup(ip);
});

// Stream of live data
final speedTestProvider = StreamProvider<SpeedTestResult>((ref) {
  return SpeedTestService().runTest();
});

// Stateful notifier for user interaction
final subnetCalcProvider = StateNotifierProvider<SubnetCalcNotifier, SubnetCalcState>((ref) {
  return SubnetCalcNotifier();
});
```

---

## 3. Package Decisions

| Feature | Package | Version (approx) | Rationale |
|---|---|---|---|
| **WiFi info** | `network_info_plus` ^6.0 | Stable, cross-platform, maintained by Flutter Community |
| **HTTP client** | `http` ^1.2 | Lightweight, no native dependencies |
| **DNS (advanced)** | `dart:io` `InternetAddress` | Built-in, no extra package needed for A/AAAA |
| **Ping** | `dart:io` `Process.run` | Shell out to OS `ping` — simplest cross-platform approach |
| **Port scanning** | `dart:io` `Socket.connect` | Raw TCP sockets in an isolate — no dependencies |
| **Device discovery** | `ping_discover_network` ^0.4 | ICMP-based LAN device detection |
| **MAC OUI lookup** | Local OUI database (CSV) or `macvendors.co` API | No maintained Flutter package; custom implementation |
| **Speed test** | Manual HTTP download/upload | Custom implementation using `http` + Stopwatch |
| **Charts** | `fl_chart` ^0.69 | Lightweight, pure Dart, good customization |
| **Navigation** | `go_router` ^14.x | Declarative, deep-link support, docs-backed |
| **State management** | `flutter_riverpod` ^2.5 + `riverpod_annotation` | As above |
| **Location (WiFi scan)** | `geolocator` ^12.x / `permission_handler` ^11.x | Runtime permission requests |
| **Hooks (optional)** | `flutter_hooks` ^0.20 | Reduces boilerplate in StatefulWidget (optional) |

### Dependencies NOT used and why

| Package | Reason excluded |
|---|---|
| `dio` | Overkill for simple REST calls; `http` suffices |
| `bloc` | More boilerplate than Riverpod for this use case |
| `nmap` Flutter wrappers | Unstable, unreliable on mobile |
| `tracert` / `traceroute` | Requires root on Android; documented limitation |

---

## 4. Data Models

### `SubnetResult`

```dart
class SubnetResult {
  final String ipAddress;
  final int cidr;
  final String networkAddress;
  final String broadcastAddress;
  final String subnetMask;
  final String firstUsable;
  final String lastUsable;
  final int totalHosts;
  final int usableHosts;
}
```

### `IPInfo`

```dart
class IPInfo {
  final String ip;
  final String country;
  final String region;
  final String city;
  final double lat;
  final double lon;
  final String isp;
  final String org;
  final String timezone;
}
```

### `DNSRecord`

```dart
class DNSRecord {
  final String name;
  final String type;     // A, AAAA, MX, NS, TXT, CNAME
  final String value;
  final int ttl;
}
```

### `PingResult`

```dart
class PingResult {
  final String host;
  final List<int> rtts;       // ms per packet
  final int sent;
  final int received;
  final double packetLoss;    // 0.0 - 100.0
  final int minRtt;
  final int avgRtt;
  final int maxRtt;
}
```

### `PortScanResult`

```dart
class PortScanResult {
  final int port;
  final bool open;
  final String service;   // HTTP, SSH, FTP, etc.
  final int? responseTimeMs;
}
```

### `DeviceInfo`

```dart
class DeviceInfo {
  final String ip;
  final String? mac;
  final String? hostname;
  final DeviceType type;  // printer, scanner, pc, laptop, mobile, switch, server, unknown
  final List<int> openPorts;
  final int rttMs;
}
```

### `SpeedTestResult`

```dart
class SpeedTestResult {
  final double downloadMbps;
  final double uploadMbps;
  final double latencyMs;
  final double jitterMs;
  final DateTime timestamp;
}
```

### `SwitchCalcResult`

```dart
class SwitchCalcResult {
  final int deviceCount;
  final int portsPerSwitch;
  final int switchesNeeded;
  final int totalPorts;
  final int portsRemaining;
}
```

### `VirtualSwitchCalcResult`

```dart
class VirtualSwitchCalcResult {
  final int vlanCount;
  final int accessPorts;
  final int trunkPorts;
  final int redundancyFactor;
  final int totalPhysicalPorts;
  final int switchesNeeded;
  final String recommendedDensity; // "24-port" / "48-port"
}
```

### `TrafficSample`

```dart
class TrafficSample {
  final DateTime timestamp;
  final int bytesReceived;   // delta since last sample
  final int bytesSent;       // delta since last sample
  final double downloadSpeedKbps;
  final double uploadSpeedKbps;
}
```

---

## 5. API Contracts

### IP Lookup: ip-api.com

| Method | Endpoint | Notes |
|---|---|---|
| `GET` | `http://ip-api.com/json/{ip}` | Free tier: 45 req/min, no API key |
| `GET` | `http://ip-api.com/json/` | Your own IP |

**Response** (truncated):
```json
{
  "status": "success",
  "country": "United States",
  "regionName": "California",
  "city": "Mountain View",
  "lat": 37.4056,
  "lon": -122.0775,
  "isp": "Google LLC",
  "org": "Google LLC",
  "as": "AS15169 Google LLC",
  "timezone": "America/Los_Angeles"
}
```

### DNS Lookup: dns.google

| Method | Endpoint | Notes |
|---|---|---|
| `GET` | `https://dns.google/resolve?name={domain}&type={type}` | JSON API, no key required |

**Response**:
```json
{
  "Status": 0,
  "Answer": [
    { "name": "example.com", "type": 1, "TTL": 3600, "data": "93.184.216.34" }
  ]
}
```

### Speed Test Payload

| Purpose | Endpoint | Size |
|---|---|---|
| Download | Configurable URL (e.g., CDN file) | ~10 MB |
| Upload | Echo server POST | ~5 MB |

> **Note**: Speed test endpoints should be configurable by the admin. Defaults may change.

---

## 6. Android Permissions

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.CHANGE_WIFI_STATE"/>
```

| Permission | When requested | Notes |
|---|---|---|
| `INTERNET` | Install time (auto) | Manifest only, no runtime prompt |
| `ACCESS_FINE_LOCATION` | On first WiFi info screen visit (Android 10+) | Required to read SSID/BSSID |
| `ACCESS_NETWORK_STATE` | Install time (auto) | No runtime prompt |

---

## 7. Known Limitations

| Limitation | Details | Future workaround |
|---|---|---|
| **Ping reliability** | `Process.run('ping')` output parsing varies by Android vendor | Use raw ICMP socket (requires NDK) |
| **Background scanning** | Android 10+ limits background WiFi scans | Foreground service + notification |
| **Root required** | Raw socket operations (traceroute, SYN scan) | Unlikely to support; document as limitation |
| **Speed test accuracy** | Mobile CPU throttling, radio state affect results | Multi-sample average, warmup phase |
| **Device discovery** | ARP table only shows recently active devices | Periodic scanning + persistent database |
| **IP Lookup rate limit** | 45 requests/min from ip-api.com | Caching, queue, or switch to paid tier |
| **Port scanner** | Sequential TCP connect is slow; parallel may trigger IDS | Add configurable concurrency (1-50 threads) |
| **MAC OUI database** | Large file (~20k entries), needs bundling or API | Ship compressed OUI DB or use remote API |

---

## 8. Future Improvements

- [ ] **Dark mode** — follow system theme (Material 3)
- [ ] **Export reports** — share scan results as text/CSV/PDF
- [ ] **Network topology map** — visual graph from device discovery
- [ ] **WiFi channel analyzer** — channel utilization, overlap detection
- [ ] **SNMP polling** — query managed switches/routers
- [ ] **History & logging** — Persist ping/scan results in SQLite (drift)
- [ ] **Multiple language support** — l10n via ARB files
- [ ] **Desktop support** — Expand to Windows/macOS for IT pros

---

## 9. Key Files Reference

| File | Purpose |
|---|---|
| `lib/main.dart` | Entry point, ProviderScope, runApp |
| `lib/app.dart` | MaterialApp.router with GoRouter |
| `lib/core/router/app_router.dart` | All routes defined |
| `lib/core/theme/app_theme.dart` | Material 3 theme |
| `lib/core/utils/ip_utils.dart` | IP parsing, CIDR math |
| `lib/features/*/service/*.dart` | Business logic / API calls |
| `lib/features/*/provider/*.dart` | Riverpod providers |
| `lib/features/*/view/*.dart` | UI screens |
| `lib/features/*/model/*.dart` | Data classes |
| `lib/shared/widgets/*.dart` | Reusable UI components |
| `test/` | Unit & widget tests mirroring lib/ structure |
| `android/app/src/main/AndroidManifest.xml` | Permissions |
| `pubspec.yaml` | Dependencies |

---

## 10. Environment / Build Config

| Config file | Key values |
|---|---|
| `pubspec.yaml` | `name: net_analyzer`, `version: 1.0.0+1` |
| `android/app/build.gradle` | `minSdk 24`, `targetSdk 34`, `compileSdk 34` |
| `android/app/build.gradle` | `applicationId "com.netanalyzer.app"` |
| `android/settings.gradle` | Enable `agp` version matching Flutter's bundled |
| `analysis_options.yaml` | Riverpod lint rules (`riverpod_lint`) |
