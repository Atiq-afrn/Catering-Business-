import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_company_viewmodel.dart';
import '../../views/settings/language_selection_screen.dart';

class LanguageSelector extends StatelessWidget {
  final bool darkBackground;

  const LanguageSelector({super.key, this.darkBackground = true});

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthCompanyViewModel>();
    final currentLang = authVM.currentLanguage;

    final langLabels = {
      'en': 'EN',
      'hi': 'हिन्दी',
      'mr': 'मराठी',
      'gu': 'ગુજરાતી',
    };

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LanguageSelectionScreen()),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: darkBackground ? Colors.white.withAlpha(20) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: darkBackground ? Colors.white.withAlpha(30) : const Color(0xFFCBD5E1),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.language_rounded,
              size: 14,
              color: darkBackground ? Colors.white : const Color(0xFF1E293B),
            ),
            const SizedBox(width: 4),
            Text(
              langLabels[currentLang] ?? 'EN',
              style: TextStyle(
                color: darkBackground ? Colors.white : const Color(0xFF1E293B),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.chevron_right_rounded,
              size: 14,
              color: darkBackground ? Colors.white70 : const Color(0xFF64748B),
            ),
          ],
        ),
      ),
    );
  }
}
