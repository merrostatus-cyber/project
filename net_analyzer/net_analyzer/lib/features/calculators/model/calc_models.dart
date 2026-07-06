class SubnetResult {
  final String ipAddress;
  final int cidr;
  final String subnetMask;
  final String networkAddress;
  final String broadcastAddress;
  final String firstUsable;
  final String lastUsable;
  final int totalHosts;
  final int usableHosts;
  final String ipClass;
  final String binaryIp;
  final String binaryMask;
  final bool isPrivate;

  const SubnetResult({
    required this.ipAddress,
    required this.cidr,
    required this.subnetMask,
    required this.networkAddress,
    required this.broadcastAddress,
    required this.firstUsable,
    required this.lastUsable,
    required this.totalHosts,
    required this.usableHosts,
    required this.ipClass,
    required this.binaryIp,
    required this.binaryMask,
    required this.isPrivate,
  });
}

class IPv4Info {
  final String ipAddress;
  final String ipClass;
  final String binary;
  final String hex;
  final String networkType;
  final bool isPrivate;
  final bool isLoopback;
  final bool isMulticast;
  final int decimalValue;

  const IPv4Info({
    required this.ipAddress,
    required this.ipClass,
    required this.binary,
    required this.hex,
    required this.networkType,
    required this.isPrivate,
    required this.isLoopback,
    required this.isMulticast,
    required this.decimalValue,
  });
}
