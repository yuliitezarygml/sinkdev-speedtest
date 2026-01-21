import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speedtest/localization.dart';
import 'package:speedtest/screens/language_selection_screen.dart';

class SettingsScreen extends StatefulWidget {
  final Function(String) onUnitChanged;
  final String currentUnit;
  final String currentLocale;
  final Function(String) onLocaleChanged;

  const SettingsScreen({
    super.key,
    required this.onUnitChanged,
    required this.currentUnit,
    required this.currentLocale,
    required this.onLocaleChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String _selectedUnit;

  @override
  void initState() {
    super.initState();
    _selectedUnit = widget.currentUnit;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141526),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(Localization.get(widget.currentLocale, AppStrings.settingsTitle), style: GoogleFonts.rubik(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          _buildSectionHeader(Localization.get(widget.currentLocale, AppStrings.languageLabel)),
          ListTile(
            title: Text(Localization.languages[widget.currentLocale] ?? widget.currentLocale, style: const TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LanguageSelectionScreen(
                    currentLanguageCode: widget.currentLocale,
                    onLanguageSelected: (code) {
                      widget.onLocaleChanged(code);
                    },
                  ),
                ),
              );
            },
          ),
          const Divider(color: Colors.white10),

          _buildSectionHeader(Localization.get(widget.currentLocale, AppStrings.unitsSection)),
          _buildRadioOption('Mbps (Megabit/s)', 'Mbps'),
          _buildRadioOption('MB/s (Megabyte/s)', 'MB/s'),
          _buildRadioOption('Kbps (Kilobit/s)', 'Kbps'),

          const Divider(color: Colors.white10),
          
          _buildSectionHeader(Localization.get(widget.currentLocale, AppStrings.aboutSection)),
          ListTile(
            title: Text(Localization.get(widget.currentLocale, AppStrings.versionLabel), style: const TextStyle(color: Colors.white)),
            subtitle: const Text('1.0.0', style: TextStyle(color: Colors.grey)),
          ),
          ListTile(
            title: Text(Localization.get(widget.currentLocale, AppStrings.developerLabel), style: const TextStyle(color: Colors.white)),
            subtitle: const Text('SinkDev', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.purpleAccent.withOpacity(0.8),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildRadioOption(String title, String value) {
    return RadioListTile<String>(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      value: value,
      groupValue: _selectedUnit,
      activeColor: const Color(0xFF00d1d1),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedUnit = newValue;
          });
          widget.onUnitChanged(newValue);
        }
      },
    );
  }
}
