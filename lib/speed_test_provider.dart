import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:speedtest/models.dart';

import 'package:speedtest/history_repository.dart';

enum TestType { download, upload }

class SpeedTestProvider {
  bool _isCancelled = false;
  final HistoryRepository _historyRepo = HistoryRepository();
  
  void cancel() {
    _isCancelled = true;
  }

  Future<void> saveTestResult({
    required double downloadSpeed,
    required double uploadSpeed,
    required int ping,
    required int jitter,
    required Server server,
    required UserSettings userSettings,
    DateTime? timestamp,
  }) async {
    final result = TestResult(
      downloadSpeed: downloadSpeed,
      uploadSpeed: uploadSpeed,
      ping: ping,
      jitter: jitter,
      serverName: server.sponsor,
      serverCountry: '${server.name}, ${server.country}',
      userIp: userSettings.ip,
      userIsp: userSettings.isp,
      timestamp: timestamp ?? DateTime.now(),
    );
    await _historyRepo.saveResult(result);
  }

  // --- Server & User Info ---

  Future<UserSettings?> fetchUserInfo() async {
    try {
      final response = await http.get(Uri.parse('http://ip-api.com/json')).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return UserSettings.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print('Error fetching user info: $e');
    }
    return null;
  }

  Future<List<Server>> fetchServers() async {
    try {
      // Fetch nearby servers from Ookla's API
      final response = await http.get(
        Uri.parse('https://www.speedtest.net/api/js/servers?engine=js'),
        headers: {
          "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
        }
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final servers = data.map((json) => Server.fromJson(json)).toList();
        if (servers.isNotEmpty) {
          return servers;
        }
      }
    } catch (e) {
      print('Error fetching servers: $e');
    }
    
    // Return fallback servers if API fails or returns empty list
    return _getFallbackServers();
  }

  List<Server> _getFallbackServers() {
    return [
      // --- MOLDOVA (Priority) ---
      Server(url: 'http://speedtest.moldtelecom.md:8080/speedtest/upload.php', host: 'speedtest.moldtelecom.md:8080', name: 'Chisinau', country: 'Moldova', sponsor: 'Moldtelecom', lat: 47.0, lon: 28.9, distance: 0),
      Server(url: 'http://speedtest.orange.md:8080/speedtest/upload.php', host: 'speedtest.orange.md:8080', name: 'Chisinau', country: 'Moldova', sponsor: 'Orange Moldova', lat: 47.01, lon: 28.86, distance: 0),
      Server(url: 'http://speedtest100.moldcell.md:8080/speedtest/upload.php', host: 'speedtest100.moldcell.md:8080', name: 'Chisinau', country: 'Moldova', sponsor: 'Moldcell', lat: 47.0, lon: 28.91, distance: 0),
      Server(url: 'http://netprobe.starnet.md:8080/speedtest/upload.php', host: 'netprobe.starnet.md:8080', name: 'Chisinau', country: 'Moldova', sponsor: 'StarNet', lat: 47.00, lon: 28.85, distance: 0),

      Server(url: 'http://speedtest.ihost.md:8080/speedtest/upload.php', host: 'speedtest.ihost.md:8080', name: 'Chisinau', country: 'Moldova', sponsor: 'iHost', lat: 47.00, lon: 28.85, distance: 0),
      
      // --- EUROPE ---
      Server(url: 'http://speedtest.tele2.net/upload.php', host: 'speedtest.tele2.net:80', name: 'Stockholm', country: 'Sweden', sponsor: 'Tele2', lat: 59.3, lon: 18.0, distance: 0),
      Server(url: 'http://speedtest.london.linode.com/speedtest/upload.php', host: 'speedtest.london.linode.com:80', name: 'London', country: 'UK', sponsor: 'Linode', lat: 51.5, lon: -0.1, distance: 0),
      Server(url: 'http://speedtest.frankfurt.linode.com/speedtest/upload.php', host: 'speedtest.frankfurt.linode.com:80', name: 'Frankfurt', country: 'Germany', sponsor: 'Linode', lat: 50.1, lon: 8.6, distance: 0),
      Server(url: 'http://speedtest.par.scaleway.com/speedtest/upload.php', host: 'speedtest.par.scaleway.com:80', name: 'Paris', country: 'France', sponsor: 'Scaleway', lat: 48.8, lon: 2.3, distance: 0),
      Server(url: 'http://speedtest-mil.vodafone.it/speedtest/upload.php', host: 'speedtest-mil.vodafone.it:80', name: 'Milan', country: 'Italy', sponsor: 'Vodafone', lat: 45.4, lon: 9.1, distance: 0),
      Server(url: 'http://speedtest.rd.rt.ru/speedtest/upload.php', host: 'speedtest.rd.rt.ru:80', name: 'Moscow', country: 'Russia', sponsor: 'Rostelecom', lat: 55.7, lon: 37.6, distance: 0),
      Server(url: 'http://kiev.volia.net/speedtest/upload.php', host: 'kiev.volia.net:80', name: 'Kyiv', country: 'Ukraine', sponsor: 'Volia', lat: 50.4, lon: 30.5, distance: 0),
      Server(url: 'http://speedtest.orange.pl/speedtest/upload.php', host: 'speedtest.orange.pl:80', name: 'Warsaw', country: 'Poland', sponsor: 'Orange PL', lat: 52.2, lon: 21.0, distance: 0),

      // --- NORTH AMERICA ---
      Server(url: 'http://speedtest.googlefiber.net/speedtest/upload.php', host: 'speedtest.googlefiber.net:80', name: 'Kansas City', country: 'USA', sponsor: 'Google Fiber', lat: 39.0, lon: -94.0, distance: 0),
      Server(url: 'http://speedtest-ny.turnkeyinternet.net/speedtest/upload.php', host: 'speedtest-ny.turnkeyinternet.net:80', name: 'New York', country: 'USA', sponsor: 'TurnKey Internet', lat: 40.7, lon: -74.0, distance: 0),
      Server(url: 'http://speedtest.sjc1.softlayer.com/speedtest/upload.php', host: 'speedtest.sjc1.softlayer.com:80', name: 'San Jose', country: 'USA', sponsor: 'SoftLayer', lat: 37.3, lon: -121.8, distance: 0),
      Server(url: 'http://speedtest.toronto.linode.com/speedtest/upload.php', host: 'speedtest.toronto.linode.com:80', name: 'Toronto', country: 'Canada', sponsor: 'Linode', lat: 43.6, lon: -79.3, distance: 0),

      // --- ASIA ---
      Server(url: 'http://speedtest.tokyo2.linode.com/speedtest/upload.php', host: 'speedtest.tokyo2.linode.com:80', name: 'Tokyo', country: 'Japan', sponsor: 'Linode', lat: 35.6, lon: 139.7, distance: 0),
      Server(url: 'http://speedtest.singapore.linode.com/speedtest/upload.php', host: 'speedtest.singapore.linode.com:80', name: 'Singapore', country: 'Singapore', sponsor: 'Linode', lat: 1.3, lon: 103.8, distance: 0),
      Server(url: 'http://sp1.hkg.hkbn.net/speedtest/upload.php', host: 'sp1.hkg.hkbn.net:80', name: 'Hong Kong', country: 'Hong Kong', sponsor: 'HKBN', lat: 22.3, lon: 114.1, distance: 0),
      Server(url: 'http://speedtest.mumbai.linode.com/speedtest/upload.php', host: 'speedtest.mumbai.linode.com:80', name: 'Mumbai', country: 'India', sponsor: 'Linode', lat: 19.0, lon: 72.8, distance: 0),

      // --- OCEANIA ---
      Server(url: 'http://speedtest.syd.optusnet.com.au/speedtest/upload.php', host: 'speedtest.syd.optusnet.com.au:80', name: 'Sydney', country: 'Australia', sponsor: 'Optus', lat: -33.8, lon: 151.2, distance: 0),
      Server(url: 'http://speedtest.spark.co.nz/speedtest/upload.php', host: 'speedtest.spark.co.nz:80', name: 'Auckland', country: 'New Zealand', sponsor: 'Spark', lat: -36.8, lon: 174.7, distance: 0),

      // --- SOUTH AMERICA ---
      Server(url: 'http://speedtest.saopaulo.linode.com/speedtest/upload.php', host: 'speedtest.saopaulo.linode.com:80', name: 'Sao Paulo', country: 'Brazil', sponsor: 'Linode', lat: -23.5, lon: -46.6, distance: 0),
      Server(url: 'http://speedtest.santiago.entel.cl/speedtest/upload.php', host: 'speedtest.santiago.entel.cl:80', name: 'Santiago', country: 'Chile', sponsor: 'Entel', lat: -33.4, lon: -70.6, distance: 0),

      // --- AFRICA ---
      Server(url: 'http://speedtest.jhb.vodacom.co.za/speedtest/upload.php', host: 'speedtest.jhb.vodacom.co.za:80', name: 'Johannesburg', country: 'South Africa', sponsor: 'Vodacom', lat: -26.2, lon: 28.0, distance: 0),
      Server(url: 'http://speedtest.cairo.etisalat.com.eg/speedtest/upload.php', host: 'speedtest.cairo.etisalat.com.eg:80', name: 'Cairo', country: 'Egypt', sponsor: 'Etisalat', lat: 30.0, lon: 31.2, distance: 0),
    ];
  }

  Future<Server?> getBestServer() async {
    try {
      final servers = await fetchServers();
      // fetchServers now guarantees a non-empty list (API or fallback)
      
      if (servers.length > 1) {
         // Sort by distance first to find closest candidates
         // Fallback servers might have distance 0 or manual values
         servers.sort((a, b) => a.distance.compareTo(b.distance));
      }

      // Take top 5 closest servers
      final candidates = servers.take(5).toList();
      
      // Ping each to find the lowest latency
      for (var server in candidates) {
        try {
          server.latency = await measurePing(testServer: server.url);
        } catch (_) {
          server.latency = 9999;
        }
      }

      // Sort by latency
      candidates.sort((a, b) => a.latency.compareTo(b.latency));
      
      return candidates.isNotEmpty ? candidates.first : servers.first;
    } catch (e) {
       // Should not happen given fetchServers fallback, but safe guard
       return _getFallbackServers().first;
    }
  }

  // --- Testing Logic ---

  Future<int> measurePing({required String testServer}) async {
    final client = http.Client();
    final stopwatch = Stopwatch();
    try {
      stopwatch.start();
      final uri = Uri.parse(testServer);
      // Try HEAD first
      await client.head(uri).timeout(const Duration(seconds: 2));
      stopwatch.stop();
      return stopwatch.elapsedMilliseconds;
    } catch (e) {
      try {
        stopwatch.reset();
        stopwatch.start();
        // Fallback to GET
        await client.get(Uri.parse(testServer)).timeout(const Duration(seconds: 3));
        stopwatch.stop();
        return stopwatch.elapsedMilliseconds;
      } catch (e2) {
        return 9999;
      }
    } finally {
      client.close();
    }
  }

  Future<int> measureJitter({required String testServer}) async {
    int prevPing = 0;
    int jitterSum = 0;
    int count = 0;
    
    for (int i = 0; i < 5; i++) {
      if (_isCancelled) break;
      final ping = await measurePing(testServer: testServer);
      if (ping == 9999) continue;
      
      if (i > 0) {
        jitterSum += (ping - prevPing).abs();
        count++;
      }
      prevPing = ping;
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    return count > 0 ? (jitterSum / count).round() : 0;
  }

  Future<void> startDownload({
    required Server server,
    required Function(double percent, double transferRate) onProgress,
    required Function(double transferRate) onDone,
    required Function(String errorMessage) onError,
    bool multiConnection = false,
  }) async {
    _isCancelled = false;
    final stopwatch = Stopwatch();
    int totalBytesReceived = 0;
    
    // Fallback if URL is generic
    String downloadUrl = server.url.replaceAll('upload.php', 'random4000x4000.jpg');
    if (server.name.contains('Tele2')) {
       downloadUrl = 'http://speedtest.tele2.net/100MB.zip';
    }

    try {
      final int threads = multiConnection ? 4 : 1;
      List<Future> futures = [];
      final int totalLength = (30000000 * threads); // Rough estimate

      stopwatch.start();

      for (int i = 0; i < threads; i++) {
        futures.add(_downloadWorker(downloadUrl, (bytes) {
          totalBytesReceived += bytes;
          
          final elapsedSeconds = stopwatch.elapsedMilliseconds / 1000;
          if (elapsedSeconds > 0.1) { 
             final speedBps = (totalBytesReceived * 8) / elapsedSeconds; 
             final speedMbps = speedBps / 1000000;
             
             // Cap progress at 100% just in case
             double progress = (totalBytesReceived / totalLength * 100).clamp(0.0, 100.0);
             onProgress(progress, speedMbps);
          }
        }));
      }

      await Future.wait(futures);
      
      stopwatch.stop();
      final speedBps = (totalBytesReceived * 8) / (stopwatch.elapsedMilliseconds / 1000);
      onDone(speedBps / 1000000);

    } catch (e) {
      onError("Download Error: $e");
    }
  }

  Future<void> _downloadWorker(String url, Function(int) onBytes) async {
    final client = http.Client();
    try {
      final request = http.Request('GET', Uri.parse(url));
      final response = await client.send(request);
      
      await for (final chunk in response.stream) {
        if (_isCancelled) {
          client.close();
          return;
        }
        onBytes(chunk.length);
        
        // Stop individual thread if total cap reached (logic is simplified here)
        // Ideally we check a shared total, but for simplicity we rely on manual cancel or simple loop
      }
    } catch (_) {
      // Ignore individual thread errors if possible or handle gracefully
    } finally {
      client.close();
    }
  }

  Future<void> startUpload({
    required Server server,
    required Function(double percent, double transferRate) onProgress,
    required Function(double transferRate) onDone,
    required Function(String errorMessage) onError,
    bool multiConnection = false,
  }) async {
    _isCancelled = false;
    final stopwatch = Stopwatch();
    
    try {
      stopwatch.start();
      
      int bytesSent = 0;
      final int threads = multiConnection ? 4 : 1;
      final int chunkSize = 512 * 1024; // 512KB
      final int totalChunksPerThread = 10; // 5MB per thread
      final int totalBytesExpected = threads * totalChunksPerThread * chunkSize;

      List<Future> futures = [];

      for (int t = 0; t < threads; t++) {
        futures.add(Future(() async {
           final client = http.Client();
           try {
             for (int i = 0; i < totalChunksPerThread; i++) {
                if (_isCancelled) return;
                
                final chunkData = Uint8List(chunkSize);
                for (int j=0; j<100; j++) chunkData[j] = Random().nextInt(255);

                try {
                  final response = await http.post(
                    Uri.parse(server.url), 
                    body: chunkData
                  ).timeout(const Duration(seconds: 10));
                  
                  if (response.statusCode != 200 && response.statusCode != 201) {
                     // Log but don't fail immediately
                  }
                } catch (e) {
                  // Ignore network errors for individual chunks to allow resilient testing
                }

                bytesSent += chunkSize;
                final elapsedSeconds = stopwatch.elapsedMilliseconds / 1000;
                final speedBps = (bytesSent * 8) / elapsedSeconds;
                final speedMbps = speedBps / 1000000;
                
                onProgress(
                  (bytesSent / totalBytesExpected * 100).clamp(0.0, 100.0),
                  speedMbps
                );
             }
           } finally {
             client.close();
           }
        }));
      }

      await Future.wait(futures);

      stopwatch.stop();
      final speedBps = (bytesSent * 8) / (stopwatch.elapsedMilliseconds / 1000);
      onDone(speedBps / 1000000);

    } catch (e) {
      onError("Upload Error: $e");
    }
  }
}
