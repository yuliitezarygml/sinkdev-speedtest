import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speedtest/models.dart';
import 'package:speedtest/speed_test_provider.dart';
import 'package:speedtest/localization.dart';

class ServerSelectionScreen extends StatefulWidget {
  final Server? currentServer;
  final Function(Server) onServerSelected;
  final String currentLocale;

  const ServerSelectionScreen({
    super.key,
    this.currentServer,
    required this.onServerSelected,
    required this.currentLocale,
  });

  @override
  State<ServerSelectionScreen> createState() => _ServerSelectionScreenState();
}

class _ServerSelectionScreenState extends State<ServerSelectionScreen> {
  final SpeedTestProvider _provider = SpeedTestProvider();
  List<Server> _allServers = [];
  List<Server> _filteredServers = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadServers();
    _searchController.addListener(_filterServers);
  }

  Future<void> _loadServers() async {
    final servers = await _provider.fetchServers();
    if (mounted) {
      setState(() {
        _allServers = servers;
        _filteredServers = servers;
        _isLoading = false;
      });
    }
  }

  void _filterServers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredServers = _allServers.where((s) {
        return s.name.toLowerCase().contains(query) ||
               s.sponsor.toLowerCase().contains(query) ||
               s.country.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String t(String key) => Localization.get(widget.currentLocale, key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141526),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(t(AppStrings.serverSelectionTitle), style: GoogleFonts.rubik(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: t(AppStrings.searchHint),
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                filled: true,
                fillColor: const Color(0xFF1E1F33),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF00d1d1)))
                : _filteredServers.isEmpty 
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.wifi_off, color: Colors.grey, size: 64),
                            const SizedBox(height: 16),
                            Text(
                              t(AppStrings.serversNotFound), 
                              style: const TextStyle(color: Colors.grey, fontSize: 16)
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadServers,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00d1d1),
                                foregroundColor: Colors.black,
                              ),
                              child: Text(t(AppStrings.retryButton)),
                            )
                          ],
                        ),
                      )
                    : ListView.builder(
                    itemCount: _filteredServers.length,
                    itemBuilder: (context, index) {
                      final server = _filteredServers[index];
                      final isSelected = widget.currentServer?.url == server.url;
                      
                      return ListTile(
                        onTap: () {
                          widget.onServerSelected(server);
                          Navigator.pop(context);
                        },
                        leading: Icon(
                          Icons.dns,
                          color: isSelected ? const Color(0xFF00d1d1) : Colors.grey,
                        ),
                        title: Text(
                          server.sponsor,
                          style: TextStyle(
                            color: isSelected ? const Color(0xFF00d1d1) : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '${server.name}, ${server.country}',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        trailing: Text(
                          '${server.distance.toStringAsFixed(0)} km',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
