# NetAnalyzer — Architecture Document

> Technical structure, folder layout, widget hierarchy, data flow, and patterns used throughout the project.

---

## 1. High-Level Architecture

```
┌─────────────────────────────────────────────────┐
│                    UI Layer                      │
│   (Riverpod-powered Flutter widgets)            │
├─────────────────────────────────────────────────┤
│               Feature Modules                   │
│   subnet_calculator  ip_lookup  dns_lookup      │
│   ping  port_scanner  speed_test  wifi_info     │
│   traffic_monitor  device_discovery             │
│   switch_calculator  virtual_switch_calc        │
├─────────────────────────────────────────────────┤
│                Service Layer                    │
│   (API clients, process runners, socket ops)    │
├─────────────────────────────────────────────────┤
│                 Core Layer                      │
│   routing  theme  utils  shared widgets         │
├─────────────────────────────────────────────────┤
│               Platform / Dart                   │
│   dart:io  dart:isolate  Android SDK            │
└─────────────────────────────────────────────────┘
```

- **UI Layer** — Pure widgets, only reads providers via `ref.watch` / `ref.listen`
- **Feature Modules** — Self-contained directory per feature (model, provider, service, view)
- **Service Layer** — Stateless classes that make API calls, run processes, open sockets
- **Core Layer** — Theme, routing, utility functions, reusable widgets

---

## 2. Folder Structure

```
lib/
├── main.dart                      # Entry point: ProviderScope + runApp
├── app.dart                       # MaterialApp.router configuration
│
├── core/
│   ├── router/
│   │   ├── app_router.dart        # GoRouter routes definition
│   │   └── route_names.dart       # Named route constants
│   ├── theme/
│   │   ├── app_theme.dart         # Material 3 theme (light/dark)
│   │   └── app_colors.dart        # Color palette constants
│   └── utils/
│       ├── ip_utils.dart          # IP parsing, CIDR math, subnet calc
│       ├── mac_utils.dart         # MAC address formatting, OUI lookup
│       ├── network_utils.dart     # Network interface helpers
│       └── formatters.dart        # Data formatting helpers
│
├── features/
│   ├── subnet_calculator/
│   │   ├── model/
│   │   │   └── subnet_result.dart
│   │   ├── provider/
│   │   │   └── subnet_calc_provider.dart
│   │   ├── service/
│   │   │   └── subnet_calc_service.dart
│   │   └── view/
│   │       └── subnet_calc_screen.dart
│   │
│   ├── ip_lookup/
│   │   ├── model/
│   │   │   └── ip_info.dart
│   │   ├── provider/
│   │   │   └── ip_lookup_provider.dart
│   │   ├── service/
│   │   │   └── ip_lookup_service.dart
│   │   └── view/
│   │       └── ip_lookup_screen.dart
│   │
│   ├── dns_lookup/
│   │   ├── model/
│   │   │   └── dns_record.dart
│   │   ├── provider/
│   │   │   └── dns_lookup_provider.dart
│   │   ├── service/
│   │   │   └── dns_lookup_service.dart
│   │   └── view/
│   │       └── dns_lookup_screen.dart
│   │
│   ├── ping/
│   │   ├── model/
│   │   │   └── ping_result.dart
│   │   ├── provider/
│   │   │   └── ping_provider.dart
│   │   ├── service/
│   │   │   └── ping_service.dart
│   │   └── view/
│   │       └── ping_screen.dart
│   │
│   ├── port_scanner/
│   │   ├── model/
│   │   │   └── port_scan_result.dart
│   │   ├── provider/
│   │   │   └── port_scanner_provider.dart
│   │   ├── service/
│   │   │   └── port_scanner_service.dart
│   │   └── view/
│   │       └── port_scanner_screen.dart
│   │
│   ├── speed_test/
│   │   ├── model/
│   │   │   └── speed_test_result.dart
│   │   ├── provider/
│   │   │   └── speed_test_provider.dart
│   │   ├── service/
│   │   │   └── speed_test_service.dart
│   │   └── view/
│   │       └── speed_test_screen.dart
│   │
│   ├── wifi_info/
│   │   ├── model/
│   │   │   └── wifi_info.dart
│   │   ├── provider/
│   │   │   └── wifi_info_provider.dart
│   │   ├── service/
│   │   │   └── wifi_info_service.dart
│   │   └── view/
│   │       └── wifi_info_screen.dart
│   │
│   ├── traffic_monitor/
│   │   ├── model/
│   │   │   └── traffic_sample.dart
│   │   ├── provider/
│   │   │   └── traffic_monitor_provider.dart
│   │   ├── service/
│   │   │   └── traffic_monitor_service.dart
│   │   └── view/
│   │       └── traffic_monitor_screen.dart
│   │
│   ├── device_discovery/
│   │   ├── model/
│   │   │   └── device_info.dart
│   │   ├── provider/
│   │   │   └── device_discovery_provider.dart
│   │   ├── service/
│   │   │   └── device_discovery_service.dart
│   │   └── view/
│   │       └── device_discovery_screen.dart
│   │
│   ├── switch_calculator/
│   │   ├── model/
│   │   │   └── switch_calc_result.dart
│   │   ├── provider/
│   │   │   └── switch_calc_provider.dart
│   │   ├── service/
│   │   │   └── switch_calc_service.dart
│   │   └── view/
│   │       └── switch_calc_screen.dart
│   │
│   └── virtual_switch_calculator/
│       ├── model/
│       │   └── virtual_switch_calc_result.dart
│       ├── provider/
│       │   └── virtual_switch_calc_provider.dart
│       ├── service/
│       │   └── virtual_switch_calc_service.dart
│       └── view/
│           └── virtual_switch_calc_screen.dart
│
├── shared/
│   └── widgets/
│       ├── loading_indicator.dart    # Centered CircularProgressIndicator
│       ├── error_display.dart        # Error message with retry button
│       ├── section_header.dart       # Styled section titles
│       ├── result_card.dart          # Reusable card for results
│       ├── ip_input_field.dart       # Validated IP input widget
│       └── speed_gauge.dart          # Speed dial gauge widget
│
└── l10n/                            # (future) Localization ARB files
```

---

## 3. Widget Tree (per screen)

### SubnetCalculatorScreen
```
SubnetCalcScreen
├── AppBar (title: "Subnet Calculator")
├── Form
│   ├── TextFormField (IP address)
│   ├── Slider / DropdownButton (CIDR)
│   └── ElevatedButton ("Calculate")
└── SubnetResultCard (expandable)
    ├── Text (Network Address)
    ├── Text (Broadcast Address)
    ├── Text (First / Last Usable)
    ├── Text (Total / Usable Hosts)
    └── Text (Subnet Mask)
```

### IPLookupScreen
```
IPLookupScreen
├── AppBar (title: "IP Lookup")
├── TextFormField (IP address)
├── ElevatedButton ("Lookup")
└── AsyncValueWidget<IPInfo>
    ├── [loading] CircularProgressIndicator
    ├── [error] ErrorDisplay (retry button)
    └── [data] IPInfoCard
        ├── Text (IP)
        ├── Text (Country, Region, City)
        ├── Text (ISP, Org)
        ├── Text (Coordinates)
        └── Text (Timezone)
```

### PingScreen
```
PingScreen
├── AppBar (title: "Ping")
├── TextFormField (host)
├── ElevatedButton ("Ping")
└── AsyncValueWidget<PingResult>
    ├── [loading] Row × 4 (progress per packet)
    ├── [error] ErrorDisplay
    └── [data] PingResultCard
        ├── Table (sent / received / loss)
        ├── Table (min / avg / max RTT)
        └── ListTile per packet (RTT, TTL)
```

### PortScannerScreen
```
PortScannerScreen
├── AppBar (title: "Port Scanner")
├── TextFormField (IP address)
├── Row
│   ├── DropdownButton (port range preset)
│   └── TextFormField (custom range)
├── ElevatedButton ("Scan")
├── LinearProgressIndicator (scan progress)
└── ListView.builder<PortScanResult>
    ├── PortTile (open — green highlight)
    ├── PortTile (closed — dimmed)
    └── PortTile (filtered — yellow)
```

### DeviceDiscoveryScreen
```
DeviceDiscoveryScreen
├── AppBar (title: "Device Discovery")
├── Row
│   ├── ElevatedButton ("Scan Network")
│   └── IconButton (filter by type)
├── [scanning] LinearProgressIndicator + "Scanning..."
└── TabBarView
    ├── Tab "All Devices"
    │   └── ListView.builder<DeviceInfo>
    │       ├── DeviceTile (icon per type)
    │       ├── IP, MAC, Hostname subtitle
    │       └── Tap → bottom sheet details
    └── Tab "Analysis"
        ├── PieChart (device type distribution)
        └── SummaryRow (counts per type)
```

### HomeScreen (launchpad)
```
HomeScreen
├── AppBar (title: "NetAnalyzer")
└── GridView (2 columns)
    ├── FeatureTile ("Subnet Calculator")     → /subnet-calculator
    ├── FeatureTile ("IP Lookup")             → /ip-lookup
    ├── FeatureTile ("DNS Lookup")            → /dns-lookup
    ├── FeatureTile ("Ping")                  → /ping
    ├── FeatureTile ("Port Scanner")          → /port-scanner
    ├── FeatureTile ("Speed Test")            → /speed-test
    ├── FeatureTile ("WiFi Info")             → /wifi-info
    ├── FeatureTile ("Traffic Monitor")       → /traffic-monitor
    ├── FeatureTile ("Device Discovery")      → /device-discovery
    ├── FeatureTile ("Switch Calculator")     → /switch-calculator
    └── FeatureTile ("Virtual Switch Calc")   → /virtual-switch-calc
```

---

## 4. Data Flow Pattern

Each feature follows the same unidirectional data flow:

```
User Action (tap button / enter text)
       │
       ▼
Widget calls ref.read(provider.notifier).doSomething()
       │
       ▼
Provider / Notifier
       │
       ├── Updates state to loading
       │
       ▼
Service class (async)
       │
       ├── HTTP request / Process.run / Socket connect
       │
       ▼
Raw data returned
       │
       ▼
Provider / Notifier
       │
       ├── Maps raw data to model
       ├── Updates state to data / error
       │
       ▼
Widget rebuilds via ref.watch(provider)
       │
       ▼
New UI rendered
```

### Example: IP Lookup Flow

```
User enters "8.8.8.8" and taps Lookup
       │
       ▼
ref.read(ipLookupProvider("8.8.8.8"))
       │
       ▼
IPLookupService.lookup("8.8.8.8")
       │
       ├── GET http://ip-api.com/json/8.8.8.8
       │
       ▼
JSON response parsed into IPInfo model
       │
       ▼
Widget rebuilds with IPInfo data
```

---

## 5. Navigation (GoRouter)

```dart
final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => HomeScreen()),
    GoRoute(path: '/subnet-calculator', builder: (_, __) => SubnetCalcScreen()),
    GoRoute(path: '/ip-lookup', builder: (_, __) => IPLookupScreen()),
    GoRoute(path: '/dns-lookup', builder: (_, __) => DNSLookupScreen()),
    GoRoute(path: '/ping', builder: (_, __) => PingScreen()),
    GoRoute(path: '/port-scanner', builder: (_, __) => PortScannerScreen()),
    GoRoute(path: '/speed-test', builder: (_, __) => SpeedTestScreen()),
    GoRoute(path: '/wifi-info', builder: (_, __) => WiFiInfoScreen()),
    GoRoute(path: '/traffic-monitor', builder: (_, __) => TrafficMonitorScreen()),
    GoRoute(path: '/device-discovery', builder: (_, __) => DeviceDiscoveryScreen()),
    GoRoute(path: '/switch-calculator', builder: (_, __) => SwitchCalcScreen()),
    GoRoute(path: '/virtual-switch-calc', builder: (_, __) => VirtualSwitchCalcScreen()),
  ],
);
```

---

## 6. Error Handling Strategy

| Error Type | Handling | UI Feedback |
|---|---|---|
| Network timeout | Retry with exponential backoff (max 3) | ErrorDisplay widget with retry button |
| Invalid input (IP, domain) | Validate in service, return `Failure` | Inline form validation error |
| API rate limit | Cache results, defer next request | Toast: "Rate limit hit, waiting..." |
| Process error (ping) | Parse stderr, return typed error | ErrorDisplay with parsed message |
| Permission denied | Catch exception, prompt settings | Dialog: "Open Settings?" |
| Unknown / crash | Catch all in provider, log | Generic error card |

### MVVM-style result type:

```dart
sealed class AsyncState<T> {
  const AsyncState();
}

class AsyncInitial<T> extends AsyncState<T> {
  const AsyncInitial();
}

class AsyncLoading<T> extends AsyncState<T> {
  const AsyncLoading();
}

class AsyncData<T> extends AsyncState<T> {
  final T data;
  const AsyncData(this.data);
}

class AsyncError<T> extends AsyncState<T> {
  final String message;
  final Object? exception;
  const AsyncError(this.message, {this.exception});
}
```

---

## 7. Testing Strategy

| Level | Tool | What to test |
|---|---|---|
| **Unit** | `flutter_test` | Service classes (IP calc, CIDR math, API parsing) |
| **Unit** | `flutter_test` + `riverpod_test` | Providers (state transitions, error handling) |
| **Widget** | `flutter_test` | Each screen (loading, data, error states) |
| **Integration** | `integration_test` | Full flow: Home → Feature → Back |
| **Golden** | `flutter_test` | Visual regression of result cards |

### Mock strategy

```dart
// Override providers in tests
final mockIpLookupService = MockIPLookupService();
final container = ProviderContainer(
  overrides: [
    ipLookupServiceProvider.overrideWithValue(mockIpLookupService),
  ],
);
```

---

## 8. Build Configuration

| Setting | Value |
|---|---|
| **compileSdk** | 34 |
| **minSdk** | 24 (Android 7.0) |
| **targetSdk** | 34 |
| **Kotlin** | 1.9.x (bundled with Flutter) |
| **AGP** | 8.x (bundled with Flutter) |
| **Gradle** | 8.x wrapper |
| **NDK** | Not required (no native code) |
| **R8 / ProGuard** | `minifyEnabled true` for release — keep rules for reflection |

---

## 9. Performance Considerations

| Concern | Mitigation |
|---|---|
| **Port scanner blocks UI** | Run in `Isolate.spawn` or use `compute()` |
| **Speed test UI jank** | StreamProvider with throttled UI updates (500ms sampling) |
| **Device discovery slow** | Parallel ping sweep (configurable concurrency) |
| **Large device list** | `ListView.builder` (lazy rendering) |
| **Traffic monitor overhead** | Poll at 1s intervals, not <1s |
| **Memory — OUI DB** | Lazy load, compressed JSON, not at startup |

---

## 10. Dependency Injection

- **Riverpod** itself acts as the DI container
- Services are exposed via `Provider<ServiceClass>` (not Family, not auto-disposed)
- Override services in tests via `ProviderContainer.overrides`

```dart
// service provider (singleton)
final ipLookupServiceProvider = Provider<IPLookupService>((ref) {
  return IPLookupService();
});

// feature provider (auto-disposed when screen leaves)
final ipLookupProvider = FutureProvider.family.autoDispose<IPInfo, String>((ref, ip) {
  final service = ref.watch(ipLookupServiceProvider);
  return service.lookup(ip);
});
```
