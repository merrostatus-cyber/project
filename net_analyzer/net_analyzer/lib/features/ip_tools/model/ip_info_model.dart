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

  const IPInfo({
    required this.ip,
    this.country = '',
    this.region = '',
    this.city = '',
    this.lat = 0,
    this.lon = 0,
    this.isp = '',
    this.org = '',
    this.timezone = '',
  });

  factory IPInfo.fromJson(Map<String, dynamic> json) {
    return IPInfo(
      ip: json['query'] as String? ?? json['ip'] as String? ?? '',
      country: json['country'] as String? ?? '',
      region: json['regionName'] as String? ?? json['region'] as String? ?? '',
      city: json['city'] as String? ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0,
      lon: (json['lon'] as num?)?.toDouble() ?? 0,
      isp: json['isp'] as String? ?? '',
      org: json['org'] as String? ?? '',
      timezone: json['timezone'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'ip': ip,
    'country': country,
    'region': region,
    'city': city,
    'lat': lat,
    'lon': lon,
    'isp': isp,
    'org': org,
    'timezone': timezone,
  };
}

class LocalIPInfo {
  final String ip;
  final String interfaceName;
  final bool isWiFi;

  const LocalIPInfo({
    required this.ip,
    this.interfaceName = '',
    this.isWiFi = true,
  });
}

class ReverseDNSResult {
  final String ip;
  final String? hostname;
  final bool hasReverse;

  const ReverseDNSResult({
    required this.ip,
    this.hostname,
    this.hasReverse = false,
  });
}
