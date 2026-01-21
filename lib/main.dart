import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add import
import 'package:speedtest/models.dart';
import 'package:speedtest/speed_test_provider.dart';
import 'package:speedtest/screens/history_screen.dart';
import 'package:speedtest/screens/settings_screen.dart';
import 'package:speedtest/screens/server_selection_screen.dart';
import 'package:speedtest/localization.dart';
import 'dart:math' as math;

import 'package:speedtest/history_repository.dart'; // Add import

void main() {
  runApp(const SpeedTestApp());
}

class SpeedTestApp extends StatefulWidget {
  const SpeedTestApp({super.key});

  @override
  State<SpeedTestApp> createState() => _SpeedTestAppState();
}

class _SpeedTestAppState extends State<SpeedTestApp> {
  String _currentLocale = 'ru';

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLocale = prefs.getString('app_language') ?? 'ru';
    });
  }

  void _changeLocale(String newLocale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', newLocale);
    
    setState(() {
      _currentLocale = newLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speed Test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF141526),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00d1d1), // Cyan
          secondary: Color(0xFF8d34e6), // Purple
          surface: Color(0xFF1E1F33),
        ),
        textTheme: GoogleFonts.rubikTextTheme(ThemeData.dark().textTheme),
      ),
      home: SpeedTestScreen(
        currentLocale: _currentLocale,
        onLocaleChanged: _changeLocale,
      ),
    );
  }
}

class SpeedTestScreen extends StatefulWidget {
  final String currentLocale;
  final Function(String) onLocaleChanged;

  const SpeedTestScreen({
    super.key,
    required this.currentLocale,
    required this.onLocaleChanged,
  });

  @override
  State<SpeedTestScreen> createState() => _SpeedTestScreenState();
}

class _SpeedTestScreenState extends State<SpeedTestScreen> with TickerProviderStateMixin {
  final SpeedTestProvider _speedTest = SpeedTestProvider();
  
  // Data
  Server? _currentServer;
  UserSettings? _userSettings;
  bool _isLoading = true;
  String? _loadingError;
  String _currentUnit = 'Mbps';
  TestResult? _lastResult; // To store previous test

  
  // Test State
  double _downloadRate = 0;
  double _uploadRate = 0;
  int _ping = 0;
  int _jitter = 0;
  
  bool _isTesting = false;
  String _statusKey = AppStrings.idleStatus; // Store key instead of text
  
  // Settings
  bool _isMultiConnection = true;
  
  // Rating
  int _currentRating = 0;
  DateTime? _lastTestTimestamp;

  // Animation
  late AnimationController _rippleController;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _initData();
  }

  Future<void> _initData() async {
    setState(() {
      _isLoading = true;
      _loadingError = null;
    });

    try {
      _userSettings = await _speedTest.fetchUserInfo();

      if (_currentServer == null) {
        final bestServer = await _speedTest.getBestServer();
        if (mounted) {
          setState(() {
            _currentServer = bestServer;
          });
        }
      }
      
      if (mounted) {
        // Load last result from history
        final history = await HistoryRepository().getHistory();
        if (history.isNotEmpty) {
          _lastResult = history.first;
        }

        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
       if (mounted) {
         setState(() {
           _isLoading = false;
           _loadingError = AppStrings.errorConnection;
         });
       }
    }
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          currentUnit: _currentUnit,
          currentLocale: widget.currentLocale,
          onUnitChanged: (unit) {
            setState(() {
              _currentUnit = unit;
            });
          },
          onLocaleChanged: widget.onLocaleChanged,
        ),
      ),
    );
  }

  void _openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryScreen(currentLocale: widget.currentLocale),
      ),
    );
  }

  void _openServerSelection() async {
    if (_isTesting) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServerSelectionScreen(
          currentServer: _currentServer,
          currentLocale: widget.currentLocale,
          onServerSelected: (server) {
            setState(() {
              _currentServer = server;
            });
          },
        ),
      ),
    );
  }

  void _startTest() async {
    if (_isTesting) return;
    if (_currentServer == null) {
      await _initData();
      if (_currentServer == null) return;
    }

    setState(() {
      _isTesting = true;
      _downloadRate = 0;
      _uploadRate = 0;
      _ping = 0;
      _jitter = 0;
      _currentRating = 0; // Reset rating
      _statusKey = AppStrings.pingStatus;
    });
    
    final pingVal = await _speedTest.measurePing(testServer: _currentServer!.url);
    final jitterVal = await _speedTest.measureJitter(testServer: _currentServer!.url);
    
    if (!mounted) return;
    setState(() {
      _ping = pingVal == 9999 ? 0 : pingVal;
      _jitter = jitterVal;
      _statusKey = AppStrings.downloadStatus;
    });

    _speedTest.startDownload(
      server: _currentServer!,
      multiConnection: _isMultiConnection,
      onDone: (double transferRate) {
        if (!mounted) return;
        setState(() {
          _downloadRate = transferRate;
          _statusKey = AppStrings.uploadStatus;
        });
        _startUpload();
      },
      onProgress: (double percent, double transferRate) {
        if (!mounted) return;
        setState(() {
          _downloadRate = transferRate;
        });
      },
      onError: (String errorMessage) {
        if (!mounted) return;
        _resetState(error: "Download Error");
      },
    );
  }

  void _startUpload() {
    _speedTest.startUpload(
      server: _currentServer!,
      multiConnection: _isMultiConnection,
      onDone: (double transferRate) async {
        if (!mounted) return;
        setState(() {
          _uploadRate = transferRate;
          _statusKey = 'FINISHED'; // Special internal state
          _isTesting = false;
        });
        
        if (_currentServer != null && _userSettings != null) {
          final now = DateTime.now();
          _lastTestTimestamp = now;
          await _speedTest.saveTestResult(
            downloadSpeed: _downloadRate,
            uploadSpeed: _uploadRate,
            ping: _ping,
            jitter: _jitter,
            server: _currentServer!,
            userSettings: _userSettings!,
            timestamp: now,
          );
        }
      },
      onProgress: (double percent, double transferRate) {
        if (!mounted) return;
        setState(() {
          _uploadRate = transferRate;
        });
      },
      onError: (String errorMessage) {
        if (!mounted) return;
        _resetState(error: "Upload Error");
      },
    );
  }

  void _rateProvider(int rating) async {
    if (_lastTestTimestamp == null) return;
    
    setState(() {
      _currentRating = rating;
    });
    
    final repo = HistoryRepository();
    await repo.updateRating(_lastTestTimestamp!, rating);
  }

  void _resetState({String? error}) {
    setState(() {
      _isTesting = false;
      _statusKey = AppStrings.idleStatus;
    });
  }

  double _convertSpeed(double speedMbps) {
    switch (_currentUnit) {
      case 'MB/s':
        return speedMbps / 8;
      case 'Kbps':
        return speedMbps * 1000;
      default: // Mbps
        return speedMbps;
    }
  }

  @override
  void dispose() {
    _speedTest.cancel();
    _rippleController.dispose();
    super.dispose();
  }

  String t(String key) => Localization.get(widget.currentLocale, key);

  @override
  Widget build(BuildContext context) {
    final Color downloadColor = const Color(0xFF00d1d1); // Cyan
    final Color uploadColor = const Color(0xFF8d34e6);   // Purple
    final Color bgColor = const Color(0xFF141526);       // Dark Blue

    // 1. RESULT SCREEN (After test is finished)
    if (!_isTesting && _statusKey == 'FINISHED') {
      return Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(icon: const Icon(Icons.history, color: Colors.grey), onPressed: _openHistory),
                    Text("SPEEDTEST", style: GoogleFonts.audiowide(color: Colors.white, fontSize: 18)),
                    IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () {
                      setState(() { _statusKey = AppStrings.idleStatus; }); // Back to idle
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              
              // Results Numbers
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildResultHeaderItem(t(AppStrings.downloadLabel), _downloadRate, downloadColor, Icons.arrow_circle_down),
                  _buildResultHeaderItem(t(AppStrings.uploadLabel), _uploadRate, uploadColor, Icons.arrow_circle_up),
                ],
              ),
              const SizedBox(height: 20),
              
              // Ping/Jitter
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStatItemSmall(t(AppStrings.pingLabel), '$_ping', 'ms', Icons.speed, const Color(0xFFc0eb75)),
                    const SizedBox(width: 40),
                    _buildStatItemSmall(t(AppStrings.jitterLabel), '$_jitter', 'ms', Icons.graphic_eq, Colors.orangeAccent),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              
              // Capabilities Icons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCapabilityIcon(Icons.web, 'Web', _downloadRate > 5 && _ping < 100),
                    _buildCapabilityIcon(Icons.gamepad, 'Gaming', _ping < 50 && _jitter < 10),
                    _buildCapabilityIcon(Icons.play_circle_fill, 'Video', _downloadRate > 25),
                    _buildCapabilityIcon(Icons.video_call, 'Call', _uploadRate > 5 && _ping < 100),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              // Line
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: LinearGradient(colors: [downloadColor, uploadColor]),
                ),
              ),

              const Spacer(),

              // Rate provider stub
              Text(t(AppStrings.rateProvider), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(_userSettings?.isp ?? t(AppStrings.providerLabel), style: TextStyle(color: Colors.grey[400], fontSize: 14)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                   return GestureDetector(
                     onTap: () => _rateProvider(index + 1),
                     child: Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 4.0),
                       child: Icon(
                         Icons.star, 
                         color: (index < _currentRating) ? const Color(0xFF00d1d1) : Colors.grey[700],
                         size: 32,
                       ),
                     ),
                   );
                }),
              ),
              
              const SizedBox(height: 30),

              // GO Button (Small / Restart)
              GestureDetector(
                onTap: () {
                  setState(() { _statusKey = AppStrings.idleStatus; });
                },
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: downloadColor.withOpacity(0.5), width: 2),
                  ),
                  child: Center(
                    child: Text('GO', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      );
    }

    // 2. MAIN SCREEN (Idle & Testing)
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.history, color: Colors.grey),
                    onPressed: _openHistory,
                  ),
                  Text("SPEEDTEST", style: GoogleFonts.audiowide(color: Colors.white, fontSize: 18)),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, color: Colors.grey),
                    onPressed: _openSettings,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),

            // If Testing: Show Gauge + Stats
            if (_isTesting) ...[
               Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(t(_statusKey),
                        style: TextStyle(
                          color: (_statusKey == AppStrings.uploadStatus) ? uploadColor : downloadColor, 
                          fontSize: 16, 
                          letterSpacing: 1.2
                        ),
                      ),
                      const SizedBox(height: 20),
                      GaugeWidget(
                        speed: (_statusKey == AppStrings.uploadStatus) ? _uploadRate : _downloadRate,
                        unit: _currentUnit,
                        mode: (_statusKey == AppStrings.uploadStatus) ? TestMode.upload : TestMode.download,
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStatItemSmall(t(AppStrings.pingLabel), '$_ping', 'ms', Icons.speed, Colors.white70),
                          const SizedBox(width: 40),
                          _buildStatItemSmall(t(AppStrings.jitterLabel), '$_jitter', 'ms', Icons.graphic_eq, Colors.white70),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // IDLE STATE: Show Stats PLACEHOLDERS as in screenshot
              const SizedBox(height: 20),
              
              // Last Test Label
              if (_lastResult != null)
                 Text(t(AppStrings.lastTestLabel), style: TextStyle(color: Colors.grey[600], fontSize: 12, letterSpacing: 1.2)),
                 
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildResultHeaderItem(
                    t(AppStrings.downloadLabel), 
                    _lastResult?.downloadSpeed ?? 0, 
                    downloadColor, 
                    Icons.arrow_circle_down, 
                    isPlaceholder: _lastResult == null
                  ),
                  _buildResultHeaderItem(
                    t(AppStrings.uploadLabel), 
                    _lastResult?.uploadSpeed ?? 0, 
                    uploadColor, 
                    Icons.arrow_circle_up, 
                    isPlaceholder: _lastResult == null
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItemSmall(
                      t(AppStrings.pingLabel), 
                      _lastResult != null ? '${_lastResult!.ping}' : '0', 
                      'ms', 
                      Icons.speed, 
                      const Color(0xFFc0eb75)
                    ),
                    _buildStatItemSmall(
                      t(AppStrings.jitterLabel), 
                      _lastResult != null ? '${_lastResult!.jitter}' : '0', 
                      'ms', 
                      Icons.graphic_eq, 
                      Colors.orangeAccent
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Start Button
              Center(
                child: GestureDetector(
                  onTap: _startTest,
                  child: CustomPaint(
                    painter: RipplePainter(_rippleController, downloadColor),
                    child: Container(
                      width: 180,
                      height: 180,
                      alignment: Alignment.center,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: downloadColor, width: 2),
                          color: Colors.transparent,
                          boxShadow: [
                            BoxShadow(color: downloadColor.withOpacity(0.1), blurRadius: 20, spreadRadius: 5),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            t(AppStrings.startButton),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
            ],

            // --- BOTTOM INFO (Always visible) ---
            _buildFooterInfo(downloadColor),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterInfo(Color highlightColor) {
    // Layout matching [Image 2] specifically
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      color: const Color(0xFF0F101E),
      child: Column(
        children: [
          // ISP Info
          Row(
            children: [
              const Icon(Icons.person_outline, color: Colors.grey, size: 28),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userSettings?.isp ?? t(AppStrings.providerLabel), 
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _userSettings?.ip ?? "...", 
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Server Info
          GestureDetector(
            onTap: _openServerSelection,
            child: Row(
              children: [
                const Icon(Icons.dns, color: Colors.grey, size: 28), // Changed icon to dns like screenshot
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentServer?.sponsor ?? (_isLoading ? t(AppStrings.loadingText) : t(AppStrings.serverLabel)), 
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _currentServer != null ? "${_currentServer!.name}" : (_loadingError != null ? t(AppStrings.errorConnection) : t(AppStrings.locationLabel)), 
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (!_isTesting)
                  Icon(Icons.change_circle, color: highlightColor, size: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultHeaderItem(String label, double value, Color color, IconData icon, {bool isPlaceholder = false}) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 10),
        isPlaceholder 
        ? Row(children: [
            Container(width: 20, height: 4, color: Colors.grey[700]),
            const SizedBox(width: 5),
            Container(width: 20, height: 4, color: Colors.grey[700]),
          ])
        : Text(
            _convertSpeed(value).toStringAsFixed(1),
            style: const TextStyle(color: Colors.white, fontSize: 50, fontWeight: FontWeight.w400),
          ),
        const SizedBox(height: 5),
        const Text("Mbps", style: TextStyle(color: Colors.grey, fontSize: 14)),
      ],
    );
  }

  Widget _buildStatItemSmall(String label, String value, String unit, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text('$label ', style: const TextStyle(color: Colors.grey, fontSize: 16)),
        const SizedBox(width: 5), // Added spacing
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w500)),
        const SizedBox(width: 4),
        Text(unit, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildCapabilityIcon(IconData icon, String label, bool isGood) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
          ),
          child: Icon(icon, color: Colors.white, size: 30),
        ),
        const SizedBox(height: 5),
        Row(
          children: List.generate(5, (index) => Icon(
            Icons.circle, 
            size: 6, 
            color: isGood ? const Color(0xFF00d1d1) : (index < 2 ? Colors.orange : Colors.grey.withOpacity(0.2))
          )),
        )
      ],
    );
  }
}

// Reuse GaugeWidget from before but ensure it's defined
enum TestMode { download, upload }

class GaugeWidget extends StatelessWidget {
  final double speed;
  final String unit;
  final TestMode mode;

  const GaugeWidget({
    super.key,
    required this.speed,
    required this.unit,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      width: 250,
      child: CustomPaint(
        painter: GaugePainter(speed: speed, mode: mode),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Text(
                speed.toStringAsFixed(2),
                style: GoogleFonts.rubik(
                  fontSize: 48, // Reduced from 54 to fit better
                  fontWeight: FontWeight.w300, 
                  color: Colors.white,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: 35), // Increased spacing to push Mbps down (was 5)
              Text(
                unit,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: mode == TestMode.download ? const Color(0xFF00E5FF) : const Color(0xFFBF5AF2), // Matches arc color
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GaugePainter extends CustomPainter {
  final double speed;
  final TestMode mode;

  GaugePainter({required this.speed, required this.mode});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    // Start from bottom-left (135 degrees)
    final startAngle = 135 * (math.pi / 180);
    final sweepAngle = 270 * (math.pi / 180);

    // --- 1. Draw Background Track ---
    final trackPaint = Paint()
      ..color = const Color(0xFF162032)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30
      ..strokeCap = StrokeCap.butt;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 20),
      startAngle,
      sweepAngle,
      false,
      trackPaint,
    );

    // --- 2. Calculate Progress Angle ---
    final double normalized = _normalizeSpeed(speed);
    final double currentSweep = sweepAngle * normalized;

    // --- 3. Draw Progress Arc ---
    final List<Color> colors = mode == TestMode.download 
          ? [const Color(0xFF00E5FF), const Color(0xFF00d1d1)] // Bright Cyan
          : [const Color(0xFFBF5AF2), const Color(0xFF8d34e6)]; // Bright Purple

    final gradient = SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + sweepAngle,
      tileMode: TileMode.repeated,
      colors: colors,
      transform: GradientRotation(startAngle - (math.pi / 20)),
    );

    final progressPaint = Paint()
      ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 20),
      startAngle,
      currentSweep,
      false,
      progressPaint,
    );

    // --- 4. Draw Ticks (Numbers) ---
    _drawTicks(canvas, center, radius - 40, startAngle, sweepAngle); // Moved ticks out (from -60 to -40)

    // --- 5. Draw Needle ---
    _drawNeedle(canvas, center, radius - 20, startAngle + currentSweep);
  }

  // Non-linear mapping to match the image scale: 0, 5, 10, 50, 100, 250, 500, 750, 1000
  double _normalizeSpeed(double s) {
    if (s <= 0) return 0.0;
    if (s >= 1000) return 1.0;

    // Define segments: value -> normalized_position (0.0 to 1.0)
    // 0 -> 0.0
    // 5 -> 0.12
    // 10 -> 0.22
    // 50 -> 0.38
    // 100 -> 0.50 (Top)
    // 250 -> 0.65
    // 500 -> 0.80
    // 750 -> 0.90
    // 1000 -> 1.0
    
    // Simple linear interpolation between segments
    if (s < 5) return _remap(s, 0, 5, 0.0, 0.12);
    if (s < 10) return _remap(s, 5, 10, 0.12, 0.22);
    if (s < 50) return _remap(s, 10, 50, 0.22, 0.38);
    if (s < 100) return _remap(s, 50, 100, 0.38, 0.50);
    if (s < 250) return _remap(s, 100, 250, 0.50, 0.65);
    if (s < 500) return _remap(s, 250, 500, 0.65, 0.80);
    if (s < 750) return _remap(s, 500, 750, 0.80, 0.90);
    return _remap(s, 750, 1000, 0.90, 1.0);
  }

  double _remap(double v, double min1, double max1, double min2, double max2) {
    return min2 + (v - min1) * (max2 - min2) / (max1 - min1);
  }

  void _drawTicks(Canvas canvas, Offset center, double radius, double startAngle, double sweepAngle) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final ticks = [0, 5, 10, 50, 100, 250, 500, 750, 1000];

    for (var val in ticks) {
      final normalized = _normalizeSpeed(val.toDouble());
      final angle = startAngle + sweepAngle * normalized;
      
      // Position text slightly inside scale
      final double textRadius = radius; 
      final double x = center.dx + textRadius * math.cos(angle);
      final double y = center.dy + textRadius * math.sin(angle);

      textPainter.text = TextSpan(
        text: val.toString(),
        style: GoogleFonts.rubik(
          color: Colors.white60,  // Dimmer color (was white70)
          fontSize: 10,           // Smaller font (was 12)
          fontWeight: FontWeight.normal // Less bold (was bold)
        ),
      );
      textPainter.layout();
      
      // Center text at calculated point
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - textPainter.height / 2));
    }
  }

  void _drawNeedle(Canvas canvas, Offset center, double radius, double angle) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    // Needle shape (Gradient triangle fading to transparent at center)
    final needleLength = radius - 10;
    final needleWidth = 10.0; // Width at scale
    
    final path = Path();
    // Tip at scale
    path.moveTo(needleLength, 0); 
    // Wide part near center? No, usually wide at scale, narrow at center or vice versa.
    // Image: Wide transparent tail near center, sharp tip at scale.
    // Actually looks like a beam: wide at center (faded), narrow at tip.
    
    // Let's try: Tip at scale (length), wide base near center
    path.moveTo(needleLength, 0);
    path.lineTo(0, -needleWidth / 2);
    path.lineTo(0, needleWidth / 2);
    path.close();

    // Gradient: Transparent at center -> White at tip
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.transparent, Colors.white],
        stops: [0.0, 1.0],
      ).createShader(Rect.fromLTWH(0, -needleWidth/2, needleLength, needleWidth));

    // Glow effect?
    // Let's make it simple first: White gradient
    canvas.drawPath(path, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant GaugePainter oldDelegate) => 
      oldDelegate.speed != speed || oldDelegate.mode != mode;
}

class RipplePainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  RipplePainter(this.animation, this.color) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color.withOpacity(0.3 * (1.0 - animation.value))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final double currentRadius = (size.width / 2) + (animation.value * 30);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), currentRadius, paint);
    
    final double secondValue = (animation.value + 0.5) % 1.0;
    final Paint secondPaint = Paint()
      ..color = color.withOpacity(0.3 * (1.0 - secondValue))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
      
    final double secondRadius = (size.width / 2) + (secondValue * 30);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), secondRadius, secondPaint);
  }

  @override
  bool shouldRepaint(RipplePainter oldDelegate) => true;
}
