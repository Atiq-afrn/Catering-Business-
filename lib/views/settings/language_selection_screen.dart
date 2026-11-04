import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/localization/app_localizations.dart';
import '../../viewmodels/auth_company_viewmodel.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  static const Color _primary = Color(0xFF203A5F);
  static const Color _background = Color(0xFFF7F8FA);
  static const Color _surface = Colors.white;
  static const Color _textPrimary = Color(0xFF172B3A);
  static const Color _textSecondary = Color(0xFF718096);
  static const Color _border = Color(0xFFE7ECF1);
  static const Color _selectedBackground = Color(0xFFF1F5F9);

  static const List<Map<String, String>> _activeLanguages = [
    {
      'code': 'en',
      'title': 'English',
      'native': 'English',
      'subtitle': 'Primary system language',
      'flag': '🇬🇧',
    },
    {
      'code': 'hi',
      'title': 'हिन्दी',
      'native': 'Hindi',
      'subtitle': 'संपूर्ण ऐप समर्थन उपलब्ध',
      'flag': '🇮🇳',
    },
    {
      'code': 'mr',
      'title': 'मराठी',
      'native': 'Marathi',
      'subtitle': 'संपूर्ण ॲप समर्थन उपलब्ध',
      'flag': '🇮🇳',
    },
    {
      'code': 'gu',
      'title': 'ગુજરાતી',
      'native': 'Gujarati',
      'subtitle': 'સંપૂર્ણ ઍપ સપોર્ટ ઉપલબ્ધ',
      'flag': '🇮🇳',
    },
  ];

  static const List<Map<String, String>> _upcomingLanguages = [
    {
      'title': 'বাংলা',
      'native': 'Bengali',
      'region': 'West Bengal & Tripura',
      'flag': '🇮🇳',
    },
    {
      'title': 'తెలుగు',
      'native': 'Telugu',
      'region': 'Andhra Pradesh & Telangana',
      'flag': '🇮🇳',
    },
    {
      'title': 'தமிழ்',
      'native': 'Tamil',
      'region': 'Tamil Nadu & Puducherry',
      'flag': '🇮🇳',
    },
    {
      'title': 'ಕನ್ನಡ',
      'native': 'Kannada',
      'region': 'Karnataka',
      'flag': '🇮🇳',
    },
    {
      'title': 'മലയാളം',
      'native': 'Malayalam',
      'region': 'Kerala',
      'flag': '🇮🇳',
    },
    {
      'title': 'ਪੰਜਾਬੀ',
      'native': 'Punjabi',
      'region': 'Punjab',
      'flag': '🇮🇳',
    },
    {
      'title': 'ଓଡ଼ିଆ',
      'native': 'Odia',
      'region': 'Odisha',
      'flag': '🇮🇳',
    },
    {
      'title': 'অসমীয়া',
      'native': 'Assamese',
      'region': 'Assam',
      'flag': '🇮🇳',
    },
    {
      'title': 'اردو',
      'native': 'Urdu',
      'region': 'India',
      'flag': '🇮🇳',
    },
    {
      'title': 'भोजपुरी',
      'native': 'Bhojpuri',
      'region': 'Bihar & Eastern Uttar Pradesh',
      'flag': '🇮🇳',
    },
  ];

  void _selectLanguage(
      BuildContext context,
      AuthCompanyViewModel authVM,
      Map<String, String> language,
      ) {
    final code = language['code']!;
    if (authVM.currentLanguage == code) return;

    authVM.changeLanguage(code);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: _primary,
          elevation: 0,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Text(
            'Language changed to ${language['native']}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
  }

  void _showNotAvailableMessage(
      BuildContext context,
      String languageName,
      ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        icon: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _selectedBackground,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.translate_rounded,
            color: _primary,
            size: 23,
          ),
        ),
        title: const Text(
          'Language coming soon',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          '$languageName is not available yet. Support for this language is planned for a future release.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _textSecondary,
            fontSize: 13,
            height: 1.55,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
        actions: [
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Got it',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthCompanyViewModel>();
    final currentLanguage = authVM.currentLanguage;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _surface,
        foregroundColor: _textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 20,
        title: Text(
          context.tr('select_language'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
            color: _textPrimary,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: _border),
        ),
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding =
            constraints.maxWidth < 360 ? 16.0 : 20.0;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                22,
                horizontalPadding,
                32,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildIntro(),
                      const SizedBox(height: 28),
                      _buildSectionHeading(
                        title: 'Available languages',
                        subtitle: 'Select the language you want to use in the app.',
                        count: _activeLanguages.length,
                      ),
                      const SizedBox(height: 12),
                      _buildAvailableLanguages(
                        context,
                        authVM,
                        currentLanguage,
                        constraints.maxWidth,
                      ),
                      const SizedBox(height: 28),
                      _buildSectionHeading(
                        title: 'More languages',
                        subtitle: 'Additional language options planned for upcoming releases.',
                        count: _upcomingLanguages.length,
                      ),
                      const SizedBox(height: 12),
                      _buildUpcomingLanguages(context, constraints.maxWidth),
                      const SizedBox(height: 22),
                      const Center(
                        child: Text(
                          'We’re working to add support for more languages.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _textSecondary,
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildIntro() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _selectedBackground,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.language_rounded,
              color: _primary,
              size: 23,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Make the app yours',
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.15,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Choose a language that feels comfortable to you.',
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeading({
    required String title,
    required String subtitle,
    required int count,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: _textSecondary,
                  fontSize: 11.5,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _border),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              color: _textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvailableLanguages(
      BuildContext context,
      AuthCompanyViewModel authVM,
      String currentLanguage,
      double availableWidth,
      ) {
    final useGrid = availableWidth >= 480;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: useGrid
          ? GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _activeLanguages.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          mainAxisExtent: 88,
        ),
        itemBuilder: (context, index) {
          final language = _activeLanguages[index];
          return _buildLanguageTile(
            context,
            authVM,
            language,
            currentLanguage == language['code'],
          );
        },
      )
          : Column(
        children: List.generate(_activeLanguages.length, (index) {
          final language = _activeLanguages[index];
          return Column(
            children: [
              _buildLanguageTile(
                context,
                authVM,
                language,
                currentLanguage == language['code'],
              ),
              if (index != _activeLanguages.length - 1)
                const SizedBox(height: 8),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildLanguageTile(
      BuildContext context,
      AuthCompanyViewModel authVM,
      Map<String, String> language,
      bool isSelected,
      ) {
    return Material(
      color: isSelected ? _selectedBackground : _surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _selectLanguage(context, authVM, language),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? _primary.withValues(alpha: 0.35) : _border,
              width: isSelected ? 1.2 : 1,
            ),
          ),
          child: Row(
            children: [
              Text(
                language['flag']!,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language['title']!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      language['subtitle']!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _textSecondary,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: isSelected ? _primary : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? _primary : const Color(0xFFCBD5DF),
                    width: 1.3,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 14,
                )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingLanguages(
      BuildContext context,
      double availableWidth,
      ) {
    final useGrid = availableWidth >= 480;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: useGrid
          ? GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _upcomingLanguages.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          mainAxisExtent: 66,
        ),
        itemBuilder: (context, index) =>
            _buildUpcomingLanguageTile(context, _upcomingLanguages[index]),
      )
          : Column(
        children: List.generate(_upcomingLanguages.length, (index) {
          return Column(
            children: [
              _buildUpcomingLanguageTile(
                context,
                _upcomingLanguages[index],
              ),
              if (index != _upcomingLanguages.length - 1)
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: _border,
                  indent: 4,
                  endIndent: 4,
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildUpcomingLanguageTile(
      BuildContext context,
      Map<String, String> language,
      ) {
    return Material(
      color: _surface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () => _showNotAvailableMessage(
          context,
          '${language['native']} (${language['title']})',
        ),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
          child: Row(
            children: [
              Text(
                language['flag']!,
                style: const TextStyle(fontSize: 21),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language['title']!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      language['native']!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _textSecondary,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.lock_outline_rounded,
                size: 15,
                color: Color(0xFF9AA6B2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
