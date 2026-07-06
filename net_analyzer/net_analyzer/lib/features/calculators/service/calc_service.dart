import '../model/calc_models.dart';

class CalcService {
  static int _ipToInt(String ip) {
    final parts = ip.split('.').map(int.parse).toList();
    return (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8) | parts[3];
  }

  static String _intToIp(int value) {
    return '${(value >> 24) & 0xFF}.${(value >> 16) & 0xFF}.${(value >> 8) & 0xFF}.${value & 0xFF}';
  }

  static String _toBinary(int value) {
    return value.toRadixString(2).padLeft(32, '0');
  }

  static String _formatBinary(String binary) {
    return '${binary.substring(0, 8)}.${binary.substring(8, 16)}.'
        '${binary.substring(16, 24)}.${binary.substring(24, 32)}';
  }

  static String _getIPClass(String ip) {
    final first = int.parse(ip.split('.').first);
    if (first < 128) return 'A';
    if (first < 192) return 'B';
    if (first < 224) return 'C';
    if (first < 240) return 'D';
    return 'E';
  }

  static bool _isPrivate(String ip) {
    final parts = ip.split('.').map(int.parse).toList();
    if (parts[0] == 10) return true;
    if (parts[0] == 172 && parts[1] >= 16 && parts[1] <= 31) return true;
    if (parts[0] == 192 && parts[1] == 168) return true;
    return false;
  }

  SubnetResult calculateSubnet(String ip, int cidr) {
    final ipInt = _ipToInt(ip);
    final maskInt = cidr == 0 ? 0 : (0xFFFFFFFF << (32 - cidr)) & 0xFFFFFFFF;
    final networkInt = ipInt & maskInt;
    final broadcastInt = networkInt | (~maskInt & 0xFFFFFFFF);

    final totalHosts = 1 << (32 - cidr);
    final usableHosts = totalHosts > 2 ? totalHosts - 2 : 0;

    return SubnetResult(
      ipAddress: ip,
      cidr: cidr,
      subnetMask: _intToIp(maskInt),
      networkAddress: _intToIp(networkInt),
      broadcastAddress: _intToIp(broadcastInt),
      firstUsable: cidr < 31
          ? _intToIp(networkInt + 1)
          : (cidr == 31 ? _intToIp(networkInt) : _intToIp(networkInt + 1)),
      lastUsable: cidr < 31
          ? _intToIp(broadcastInt - 1)
          : (cidr == 31 ? _intToIp(broadcastInt) : _intToIp(broadcastInt - 1)),
      totalHosts: totalHosts,
      usableHosts: usableHosts,
      ipClass: _getIPClass(ip),
      binaryIp: _formatBinary(_toBinary(ipInt)),
      binaryMask: _formatBinary(_toBinary(maskInt)),
      isPrivate: _isPrivate(ip),
    );
  }

  IPv4Info analyzeIPv4(String ip) {
    final parts = ip.split('.').map(int.parse).toList();
    final ipInt = _ipToInt(ip);
    final ipClass = _getIPClass(ip);

    String networkType;
    switch (ipClass) {
      case 'A':
        networkType = 'Large networks (0.0.0.0 - 127.255.255.255)';
        break;
      case 'B':
        networkType = 'Medium networks (128.0.0.0 - 191.255.255.255)';
        break;
      case 'C':
        networkType = 'Small networks (192.0.0.0 - 223.255.255.255)';
        break;
      case 'D':
        networkType = 'Multicast (224.0.0.0 - 239.255.255.255)';
        break;
      default:
        networkType = 'Reserved (240.0.0.0 - 255.255.255.255)';
    }

    return IPv4Info(
      ipAddress: ip,
      ipClass: ipClass,
      binary: _formatBinary(_toBinary(ipInt)),
      hex: '0x${ipInt.toRadixString(16).padLeft(8, '0').toUpperCase()}',
      networkType: networkType,
      isPrivate: _isPrivate(ip),
      isLoopback: parts[0] == 127,
      isMulticast: ipClass == 'D',
      decimalValue: ipInt,
    );
  }

  List<int> getValidCIDRs(String ipClass) {
    switch (ipClass) {
      case 'A':
        return List.generate(9, (i) => i + 8);
      case 'B':
        return List.generate(9, (i) => i + 16);
      case 'C':
        return List.generate(9, (i) => i + 24);
      default:
        return List.generate(25, (i) => i + 8);
    }
  }

  bool isValidIP(String ip) {
    final parts = ip.split('.');
    if (parts.length != 4) return false;
    for (final part in parts) {
      final num = int.tryParse(part);
      if (num == null || num < 0 || num > 255) return false;
    }
    return true;
  }

  bool isValidCIDR(int cidr) => cidr >= 0 && cidr <= 32;
}
