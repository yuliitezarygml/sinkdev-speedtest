import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:speedtest/history_repository.dart';
import 'package:speedtest/models.dart';
import 'package:speedtest/localization.dart';

class HistoryScreen extends StatefulWidget {
  final String currentLocale;

  const HistoryScreen({
    super.key, 
    required this.currentLocale,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryRepository _repository = HistoryRepository();
  List<TestResult> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await _repository.getHistory();
    if (mounted) {
      setState(() {
        _history = history;
        _isLoading = false;
      });
    }
  }

  Future<void> _clearHistory() async {
    await _repository.clearHistory();
    _loadHistory();
  }

  String t(String key) => Localization.get(widget.currentLocale, key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141526),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(t(AppStrings.historyTitle), style: GoogleFonts.rubik(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF1E1F33),
                  title: Text(t(AppStrings.clearHistoryTitle), style: const TextStyle(color: Colors.white)),
                  content: Text(t(AppStrings.clearHistoryConfirm), style: const TextStyle(color: Colors.grey)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(t(AppStrings.cancelButton), style: const TextStyle(color: Colors.grey)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _clearHistory();
                      },
                      child: Text(t(AppStrings.clearButton), style: const TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00d1d1)))
          : _history.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.history, color: Colors.grey, size: 64),
                      const SizedBox(height: 16),
                      Text(
                        t(AppStrings.historyEmpty),
                        style: GoogleFonts.rubik(color: Colors.grey, fontSize: 18),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final item = _history[index];
                    return _buildHistoryItem(item);
                  },
                ),
    );
  }

  Widget _buildHistoryItem(TestResult item) {
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1F33),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateFormat.format(item.timestamp),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Row(
                children: [
                  const Icon(Icons.wifi, color: Colors.grey, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    item.userIsp.isNotEmpty ? item.userIsp : 'Unknown ISP',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              if (item.rating != null && item.rating! > 0)
                Row(
                  children: List.generate(5, (index) => Icon(
                    Icons.star, 
                    size: 12, 
                    color: index < item.rating! ? const Color(0xFF00d1d1) : Colors.grey[800],
                  )),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSpeedColumn(t(AppStrings.downloadLabel), item.downloadSpeed, const Color(0xFF00d1d1), Icons.arrow_downward),
              Container(width: 1, height: 40, color: Colors.white10),
              _buildSpeedColumn(t(AppStrings.uploadLabel), item.uploadSpeed, const Color(0xFF8d34e6), Icons.arrow_upward),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white10),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoRow(Icons.dns, item.serverName),
              _buildInfoRow(Icons.place, item.serverCountry),
              _buildInfoRow(Icons.speed, '${item.ping} ms'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedColumn(String label, double speed, Color color, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          speed.toStringAsFixed(1),
          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const Text('Mbps', style: TextStyle(color: Colors.grey, fontSize: 10)),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 14),
        const SizedBox(width: 6),
        Container(
          constraints: const BoxConstraints(maxWidth: 100),
          child: Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
