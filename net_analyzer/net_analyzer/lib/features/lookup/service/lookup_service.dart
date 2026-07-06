import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/lookup_models.dart';

class LookupService {
  static const _dnsApi = 'https://dns.google/resolve';
  static const _whoisApi = 'https://rdap.arin.net/registry/ip';
  static const _macApi = 'https://api.macvendors.com';

  Future<DNSResult> lookupDNS(String domain) async {
    final records = <DNSRecord>[];
    final types = {'A': 1, 'AAAA': 28, 'MX': 15, 'NS': 2, 'TXT': 16, 'CNAME': 5};

    for (final entry in types.entries) {
      try {
        final uri = Uri.parse('$_dnsApi?name=$domain&type=${entry.value}');
        final response = await http.get(uri).timeout(const Duration(seconds: 8));
        if (response.statusCode == 200) {
          final data = json.decode(response.body) as Map<String, dynamic>;
          final answers = data['Answer'] as List<dynamic>?;
          if (answers != null) {
            for (final ans in answers) {
              records.add(DNSRecord(
                name: ans['name'] as String? ?? domain,
                type: entry.key,
                value: ans['data'] as String? ?? '',
                ttl: ans['TTL'] as int? ?? 0,
              ));
            }
          }
        }
      } catch (_) {}
    }

    return DNSResult(domain: domain, records: records);
  }

  Future<WhoisInfo> lookupWhois(String ip) async {
    try {
      final uri = Uri.parse('$_whoisApi/$ip');
      final response = await http.get(uri, headers: {
        'Accept': 'application/json',
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final entities = data['entities'] as List<dynamic>?;
        final events = data['events'] as List<dynamic>?;

        String? orgName, country, city, address;

        if (entities != null && entities.isNotEmpty) {
          final vcard = entities.first['vcardArray'] as List<dynamic>?;
          if (vcard != null && vcard.length > 1) {
            final items = vcard[1] as List<dynamic>;
            for (final item in items) {
              final parts = item as List<dynamic>;
              if (parts.length > 3) {
                final type = parts[0] as String?;
                final value = parts[3] as String?;
                if (type == 'fn') orgName = value;
                if (type == 'adr') address = value;
                if (type == 'country') country = value;
                if (type == 'locality') city = value;
              }
            }
          }
        }

        String? regDate;
          String? updatedDate;
        if (events != null) {
          for (final event in events) {
            final action = event['eventAction'] as String?;
            final date = event['eventDate'] as String?;
            if (action == 'registration') regDate = date;
            if (action == 'last changed') updatedDate = date;
          }
        }

        return WhoisInfo(
          query: ip,
          orgName: orgName,
          country: country,
          city: city,
          address: address,
          netRange: data.containsKey('startAddress') && data['startAddress'] != null
              ? '${data['startAddress']} - ${data['endAddress']}'
              : null,
          netName: data['name'] as String?,
          regDate: regDate,
          updatedDate: updatedDate,
        );
      }
    } catch (_) {}

    return WhoisInfo(query: ip);
  }

  Future<MACVendorResult> lookupMAC(String mac) async {
    final cleaned = mac.replaceAll(RegExp(r'[-:.\s]'), '');
    if (cleaned.length < 6) {
      return MACVendorResult(mac: mac, found: false);
    }

    try {
      final uri = Uri.parse('$_macApi/$cleaned');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final vendor = response.body.trim();
        return MACVendorResult(mac: mac, vendor: vendor, found: true);
      }
    } catch (_) {}

    return MACVendorResult(mac: mac, found: false);
  }

  bool isValidMAC(String mac) {
    final cleaned = mac.replaceAll(RegExp(r'[-:.\s]'), '');
    return RegExp(r'^[0-9A-Fa-f]{6,12}$').hasMatch(cleaned);
  }
}
