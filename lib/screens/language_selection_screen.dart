import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speedtest/localization.dart';

class LanguageSelectionScreen extends StatelessWidget {
  final String currentLanguageCode;
  final Function(String) onLanguageSelected;

  const LanguageSelectionScreen({
    super.key,
    required this.currentLanguageCode,
    required this.onLanguageSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Sort languages: Selected first, then alphabetical
    final sortedKeys = Localization.languages.keys.toList()
      ..sort((a, b) {
        if (a == currentLanguageCode) return -1;
        if (b == currentLanguageCode) return 1;
        return Localization.languages[a]!.compareTo(Localization.languages[b]!);
      });

    return Scaffold(
      backgroundColor: const Color(0xFF141526),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          Localization.get(currentLanguageCode, AppStrings.languageLabel), 
          style: GoogleFonts.rubik(color: Colors.white)
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.separated(
        itemCount: sortedKeys.length,
        separatorBuilder: (ctx, i) => const Divider(color: Colors.white10, height: 1),
        itemBuilder: (context, index) {
          final code = sortedKeys[index];
          final name = Localization.languages[code]!;
          final isSelected = code == currentLanguageCode;

          return ListTile(
            onTap: () {
              onLanguageSelected(code);
              Navigator.pop(context);
            },
            title: Text(
              name,
              style: TextStyle(
                color: isSelected ? const Color(0xFF00d1d1) : Colors.white,
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            trailing: isSelected 
              ? const Icon(Icons.check_circle, color: Color(0xFF00d1d1))
              : null,
          );
        },
      ),
    );
  }
}
