import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service/lookup_service.dart';
import '../model/lookup_models.dart';

final lookupServiceProvider = Provider<LookupService>((ref) => LookupService());

final dnsLookupProvider = FutureProvider.family<DNSResult, String>((ref, domain) {
  return ref.read(lookupServiceProvider).lookupDNS(domain);
});

final whoisLookupProvider = FutureProvider.family<WhoisInfo, String>((ref, ip) {
  return ref.read(lookupServiceProvider).lookupWhois(ip);
});

final macLookupProvider = FutureProvider.family<MACVendorResult, String>((ref, mac) {
  return ref.read(lookupServiceProvider).lookupMAC(mac);
});
