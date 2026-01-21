class Server {
  final String url;
  final String host;
  final String name;
  final String country;
  final String sponsor;
  final double lat;
  final double lon;
  final double distance;
  int latency;

  Server({
    required this.url,
    required this.host,
    required this.name,
    required this.country,
    required this.sponsor,
    required this.lat,
    required this.lon,
    required this.distance,
    this.latency = 9999,
  });

  factory Server.fromJson(Map<String, dynamic> json) {
    return Server(
      url: json['url'] ?? '',
      host: json['host'] ?? '',
      name: json['name'] ?? '',
      country: json['country'] ?? '',
      sponsor: json['sponsor'] ?? '',
      lat: double.tryParse(json['lat'].toString()) ?? 0.0,
      lon: double.tryParse(json['lon'].toString()) ?? 0.0,
      distance: double.tryParse(json['distance'].toString()) ?? 0.0,
    );
  }
}

class UserSettings {
  final String ip;
  final String isp;

  UserSettings({required this.ip, required this.isp});

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      ip: json['query'] ?? 'Unknown',
      isp: json['isp'] ?? 'Unknown',
    );
  }
}

class TestResult {
  final double downloadSpeed;
  final double uploadSpeed;
  final int ping;
  final int jitter;
  final String serverName;
  final String serverCountry;
  final String userIp;
  final String userIsp;
  final DateTime timestamp;
  final int? rating; // 1-5

  TestResult({
    required this.downloadSpeed,
    required this.uploadSpeed,
    required this.ping,
    required this.jitter,
    required this.serverName,
    required this.serverCountry,
    required this.userIp,
    required this.userIsp,
    required this.timestamp,
    this.rating,
  });

  Map<String, dynamic> toJson() {
    return {
      'downloadSpeed': downloadSpeed,
      'uploadSpeed': uploadSpeed,
      'ping': ping,
      'jitter': jitter,
      'serverName': serverName,
      'serverCountry': serverCountry,
      'userIp': userIp,
      'userIsp': userIsp,
      'timestamp': timestamp.toIso8601String(),
      'rating': rating,
    };
  }

  factory TestResult.fromJson(Map<String, dynamic> json) {
    return TestResult(
      downloadSpeed: json['downloadSpeed'] ?? 0.0,
      uploadSpeed: json['uploadSpeed'] ?? 0.0,
      ping: json['ping'] ?? 0,
      jitter: json['jitter'] ?? 0,
      serverName: json['serverName'] ?? 'Unknown',
      serverCountry: json['serverCountry'] ?? 'Unknown',
      userIp: json['userIp'] ?? '',
      userIsp: json['userIsp'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      rating: json['rating'],
    );
  }
}
