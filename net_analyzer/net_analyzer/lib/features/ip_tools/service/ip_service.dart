import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../model/ip_info_model.dart';

class IPService {
  static const _ipApiUrl = 'http://ip-api.com/json';

  /// Case-insensitive fragments used to identify virtual / non-physical adapters.
  static const _virtualPatterns = [
    'hyper-v',
    'virtualbox',
    'vmware',
    'vethernet',
    'default switch',
    'host-only',
    'vmnet',
    'wsl',
    'loopback',
    'bluetooth',
    'tunnel',
    'pseudo',
    'isatap',
    'ppp',
    'ndis',
  ];

  Future<IPInfo> getMyPublicIP() async {
    try {
      final response = await http
          .get(Uri.parse(_ipApiUrl))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return IPInfo.fromJson(json.decode(response.body) as Map<String, dynamic>);
      }
      return IPInfo(ip: 'Failed to fetch');
    } catch (_) {
      return IPInfo(ip: 'Unavailable');
    }
  }

  Future<IPInfo> lookupIP(String ip) async {
    try {
      final response = await http
          .get(Uri.parse('$_ipApiUrl/$ip'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data['status'] == 'success') {
          return IPInfo.fromJson(data);
        }
        return IPInfo(ip: ip, country: 'Invalid / Private IP');
      }
      return IPInfo(ip: ip, country: 'Lookup failed');
    } catch (_) {
      return IPInfo(ip: ip, country: 'Request failed');
    }
  }

  /// Returns true if [name] contains a known virtual-adapter pattern.
  bool _isVirtual(String name) {
    final lower = name.toLowerCase();
    return _virtualPatterns.any((p) => lower.contains(p));
  }

  Future<LocalIPInfo> getLocalIP() async {
    try {
      final interfaces = await NetworkInterface.list(includeLoopback: false);

      debugPrint('=== NetworkInterface.list() — all interfaces ===');
      for (final iface in interfaces) {
        final addrs = iface.addresses
            .where((a) => a.type == InternetAddressType.IPv4)
            .map((a) => a.address)
            .join(', ');
        debugPrint('  [${iface.name}] IPv4=[$addrs]  virtual=${_isVirtual(iface.name)}');
      }
      debugPrint('===============================================');

      // Filter: IPv4 private address AND non-virtual adapter name.
      final candidates = interfaces.where((iface) {
        final hasPrivateV4 = iface.addresses.any((a) =>
            a.type == InternetAddressType.IPv4 && _isPrivateV4(a.address));
        return hasPrivateV4 && !_isVirtual(iface.name);
      }).toList();

      debugPrint('getLocalIP: ${candidates.length} candidate(s) after virtual filter');
      for (final c in candidates) {
        final addrs = c.addresses
            .where((a) => a.type == InternetAddressType.IPv4)
            .map((a) => a.address)
            .join(', ');
        debugPrint('  ${c.name} — $addrs');
      }

      if (candidates.isEmpty) {
        debugPrint('getLocalIP: no candidates — falling back to first IPv4');
        return const LocalIPInfo(ip: '127.0.0.1');
      }

      // Prefer a Wi-Fi interface over Ethernet.
      NetworkInterface selected = candidates.first;
      for (final iface in candidates) {
        final name = iface.name.toLowerCase();
        if (name.contains('wi-fi') || name.contains('wlan') || name.contains('wireless')) {
          selected = iface;
          debugPrint('getLocalIP: selected Wi-Fi adapter: ${iface.name}');
          break;
        }
      }

      if (selected == candidates.first) {
        debugPrint('getLocalIP: no Wi-Fi found, using: ${selected.name}');
      }

      final ipv4 = selected.addresses.firstWhere(
        (a) => a.type == InternetAddressType.IPv4 && _isPrivateV4(a.address),
      );

      final nameLower = selected.name.toLowerCase();
      final isWiFi = nameLower.contains('wi-fi') ||
          nameLower.contains('wlan') ||
          nameLower.contains('wireless');

      // Cross-check with connectivity_plus on supported platforms.
      bool connectivityPlusWifi = isWiFi;
      try {
        final result = await Connectivity().checkConnectivity();
        connectivityPlusWifi = result.contains(ConnectivityResult.wifi);
      } catch (_) {
        // connectivity_plus may not be supported on all desktop platforms.
      }

      debugPrint('getLocalIP: result — ip=${ipv4.address}, '
          'iface=${selected.name}, isWiFi(native)=$isWiFi, isWiFi(connectivity_plus)=$connectivityPlusWifi');

      return LocalIPInfo(
        ip: ipv4.address,
        interfaceName: selected.name,
        isWiFi: isWiFi || connectivityPlusWifi,
      );
    } catch (e) {
      debugPrint('getLocalIP: error — $e');
      return const LocalIPInfo(ip: 'Unavailable');
    }
  }

  bool _isPrivateV4(String addr) {
    return addr.startsWith('192.') || addr.startsWith('10.') || addr.startsWith('172.');
  }

  Future<ReverseDNSResult> reverseDNS(String ip) async {
    try {
      final addr = await InternetAddress.lookup(ip);
      if (addr.isNotEmpty && addr.first.host != ip) {
        return ReverseDNSResult(
          ip: ip,
          hostname: addr.first.host,
          hasReverse: true,
        );
      }
      return ReverseDNSResult(ip: ip, hasReverse: false);
    } catch (_) {
      return ReverseDNSResult(ip: ip, hasReverse: false);
    }
  }
}
