import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service/ip_service.dart';
import '../model/ip_info_model.dart';

final ipServiceProvider = Provider<IPService>((ref) => IPService());

final myPublicIPProvider = FutureProvider<IPInfo>((ref) {
  return ref.read(ipServiceProvider).getMyPublicIP();
});

final localIPProvider = FutureProvider<LocalIPInfo>((ref) {
  return ref.read(ipServiceProvider).getLocalIP();
});

final ipLookupProvider = FutureProvider.family<IPInfo, String>((ref, ip) {
  return ref.read(ipServiceProvider).lookupIP(ip);
});

final reverseDNSProvider = FutureProvider.family<ReverseDNSResult, String>((ref, ip) {
  return ref.read(ipServiceProvider).reverseDNS(ip);
});
