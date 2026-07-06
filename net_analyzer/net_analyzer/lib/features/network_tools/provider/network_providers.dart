import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service/network_service.dart';
import '../model/network_models.dart';

final networkServiceProvider = Provider<NetworkService>((ref) => NetworkService());

final pingProvider = FutureProvider.family<PingResult, String>((ref, host) {
  return ref.read(networkServiceProvider).ping(host);
});

final tracerouteProvider = FutureProvider.family<TracerouteResult, String>((ref, target) {
  return ref.read(networkServiceProvider).traceroute(target);
});

final portScanProvider = FutureProvider.family<PortScanSummary, String>((ref, host) {
  return ref.read(networkServiceProvider).scanPorts(host);
});
