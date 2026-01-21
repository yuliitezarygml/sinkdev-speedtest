import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speedtest/models.dart';

class HistoryRepository {
  static const String _keyHistory = 'speed_test_history';

  Future<void> saveResult(TestResult result) async {
    final prefs = await SharedPreferences.getInstance();
    List<TestResult> history = await getHistory();
    history.insert(0, result); // Add new result to the top
    
    // Limit history size to prevent indefinite growth (e.g., 50 items)
    if (history.length > 50) {
      history = history.sublist(0, 50);
    }

    final String jsonString = jsonEncode(history.map((e) => e.toJson()).toList());
    await prefs.setString(_keyHistory, jsonString);
  }

  Future<List<TestResult>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_keyHistory);
    
    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((e) => TestResult.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> updateRating(DateTime timestamp, int rating) async {
    final prefs = await SharedPreferences.getInstance();
    List<TestResult> history = await getHistory();
    
    final index = history.indexWhere((element) => element.timestamp.isAtSameMomentAs(timestamp));
    if (index != -1) {
      final old = history[index];
      history[index] = TestResult(
        downloadSpeed: old.downloadSpeed,
        uploadSpeed: old.uploadSpeed,
        ping: old.ping,
        jitter: old.jitter,
        serverName: old.serverName,
        serverCountry: old.serverCountry,
        userIp: old.userIp,
        userIsp: old.userIsp,
        timestamp: old.timestamp,
        rating: rating,
      );
      
      final String jsonString = jsonEncode(history.map((e) => e.toJson()).toList());
      await prefs.setString(_keyHistory, jsonString);
    }
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHistory);
  }
}
