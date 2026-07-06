import 'dart:io';
import 'dart:math';
import '../model/network_models.dart';

class NetworkService {
  Future<PingResult> ping(String host, {int count = 4}) async {
    final rtts = <int>[];
    int sent = 0;
    int received = 0;

    for (int i = 0; i < count; i++) {
      sent++;
      try {
        final stopwatch = Stopwatch()..start();
        final result = await Process.run(
          Platform.isWindows ? 'ping' : 'ping',
          Platform.isWindows ? ['-n', '1', host] : ['-c', '1', '-W', '3', host],
        );
        stopwatch.stop();

        if (result.exitCode == 0) {
          received++;
          rtts.add(stopwatch.elapsedMilliseconds);
        }
      } catch (_) {
        // timeout or error
      }
    }

    if (rtts.isEmpty) {
      return PingResult(
        host: host,
        sent: sent,
        received: received,
        packetLossPercent: 100,
      );
    }

    return PingResult(
      host: host,
      rttsMs: rtts,
      sent: sent,
      received: received,
      packetLossPercent: ((sent - received) / sent * 100),
      minRtt: rtts.reduce(min),
      avgRtt: rtts.reduce((a, b) => a + b) ~/ rtts.length,
      maxRtt: rtts.reduce(max),
    );
  }

  Future<TracerouteResult> traceroute(String target) async {
    final hops = <TracerouteHop>[];
    try {
      final result = await Process.run(
        Platform.isWindows ? 'tracert' : 'traceroute',
        Platform.isWindows ? ['-d', '-h', '15', target] : ['-n', '-m', '15', target],
      );

      if (result.exitCode == 0) {
        final lines = (result.stdout as String).split('\n');
        for (final line in lines) {
          final hopMatch = RegExp(
            r'^\s*(\d+)\s+<?(\d+)\s+ms\s+<?(\d+)\s+ms\s+<?(\d+)\s+ms\s+([\d.]+)',
          ).firstMatch(line);
          if (hopMatch != null) {
            hops.add(TracerouteHop(
              hop: int.parse(hopMatch.group(1)!),
              ip: hopMatch.group(5)!,
              rttMs: int.parse(hopMatch.group(2)!),
            ));
          }
        }
      }
    } catch (_) {}

    return TracerouteResult(target: target, hops: hops);
  }

  Future<PortScanResult> checkPort(String host, int port) async {
    final service = commonPorts[port];
    try {
      final stopwatch = Stopwatch()..start();
      final socket = await Socket.connect(
        host,
        port,
        timeout: const Duration(seconds: 2),
      );
      stopwatch.stop();
      await socket.close();
      return PortScanResult(
        port: port,
        open: true,
        service: service,
        responseTimeMs: stopwatch.elapsedMilliseconds,
      );
    } catch (_) {
      return PortScanResult(
        port: port,
        open: false,
        service: service,
      );
    }
  }

  Future<PortScanSummary> scanPorts(
    String host, {
    List<int> ports = const [
      21, 22, 23, 25, 53, 80, 110, 143, 443, 445,
      993, 995, 1433, 1521, 3306, 3389, 5432, 5900,
      6379, 8080, 8443, 27017,
    ],
  }) async {
    final results = <PortScanResult>[];
    for (final port in ports) {
      final result = await checkPort(host, port);
      results.add(result);
    }
    return PortScanSummary(
      target: host,
      results: results,
      openCount: results.where((r) => r.open).length,
      closedCount: results.where((r) => !r.open).length,
    );
  }
}
