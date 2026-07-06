class DNSRecord {
  final String name;
  final String type;
  final String value;
  final int ttl;

  const DNSRecord({
    required this.name,
    required this.type,
    required this.value,
    required this.ttl,
  });
}

class DNSResult {
  final String domain;
  final List<DNSRecord> records;

  const DNSResult({required this.domain, this.records = const []});
}

class WhoisInfo {
  final String query;
  final String? orgName;
  final String? country;
  final String? city;
  final String? address;
  final String? netRange;
  final String? netName;
  final String? regDate;
  final String? updatedDate;

  const WhoisInfo({
    required this.query,
    this.orgName,
    this.country,
    this.city,
    this.address,
    this.netRange,
    this.netName,
    this.regDate,
    this.updatedDate,
  });
}

class MACVendorResult {
  final String mac;
  final String? vendor;
  final bool found;

  const MACVendorResult({required this.mac, this.vendor, this.found = false});
}
