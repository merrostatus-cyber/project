class PingResult {
  final String host;
  final List<int> rttsMs;
  final int sent;
  final int received;
  final double packetLossPercent;
  final int minRtt;
  final int avgRtt;
  final int maxRtt;

  const PingResult({
    required this.host,
    this.rttsMs = const [],
    this.sent = 0,
    this.received = 0,
    this.packetLossPercent = 100,
    this.minRtt = 0,
    this.avgRtt = 0,
    this.maxRtt = 0,
  });
}

class TracerouteHop {
  final int hop;
  final String ip;
  final String? hostname;
  final int rttMs;

  const TracerouteHop({
    required this.hop,
    required this.ip,
    this.hostname,
    this.rttMs = 0,
  });
}

class TracerouteResult {
  final String target;
  final List<TracerouteHop> hops;

  const TracerouteResult({
    required this.target,
    this.hops = const [],
  });
}

class PortScanResult {
  final int port;
  final bool open;
  final String? service;
  final int responseTimeMs;

  const PortScanResult({
    required this.port,
    required this.open,
    this.service,
    this.responseTimeMs = 0,
  });
}

class PortScanSummary {
  final String target;
  final List<PortScanResult> results;
  final int openCount;
  final int closedCount;

  const PortScanSummary({
    required this.target,
    this.results = const [],
    this.openCount = 0,
    this.closedCount = 0,
  });
}

const Map<int, String> commonPorts = {
  20: 'FTP Data',
  21: 'FTP Control',
  22: 'SSH',
  23: 'Telnet',
  25: 'SMTP',
  53: 'DNS',
  80: 'HTTP',
  110: 'POP3',
  143: 'IMAP',
  443: 'HTTPS',
  445: 'SMB',
  993: 'IMAPS',
  995: 'POP3S',
  1433: 'MSSQL',
  1521: 'Oracle DB',
  3306: 'MySQL',
  3389: 'RDP',
  5432: 'PostgreSQL',
  5900: 'VNC',
  6379: 'Redis',
  8080: 'HTTP-Proxy',
  8443: 'HTTPS-Alt',
  27017: 'MongoDB',
};
