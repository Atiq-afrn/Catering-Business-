import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../app/theme.dart';
import '../../core/localization/app_localizations.dart';
import '../../viewmodels/auth_company_viewmodel.dart';
import '../main_layout.dart';
import 'login_screen.dart';

class ShopRegistrationScreen extends StatefulWidget {
  const ShopRegistrationScreen({super.key});

  @override
  State<ShopRegistrationScreen> createState() => _ShopRegistrationScreenState();
}

class _ShopRegistrationScreenState extends State<ShopRegistrationScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers for all required fields
  final _shopNameCtrl = TextEditingController();
  final _ownerNameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  String _selectedLanguage = 'en';
  bool _isSaving = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  // Design tokens
  static const Color _navy = Color(0xFF203A5F);
  static const Color _ink = Color(0xFF0F172A);
  static const Color _muted = Color(0xFF64748B);
  static const Color _line = Color(0xFFE2E8F0);
  static const Color _green = Color(0xFF059669);

  // Field background color (soft, modern gray-blue)
  static const Color _fieldBg = Color(0xFFF4F6F8);

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'hi', 'name': 'हिन्दी (Hindi)'},
    {'code': 'mr', 'name': 'मराठी (Marathi)'},
    {'code': 'gu', 'name': 'ગુજરાતી (Gujarati)'},
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _shopNameCtrl.dispose();
    _ownerNameCtrl.dispose();
    _locationCtrl.dispose();
    _contactCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordCtrl.text.trim() != _confirmPasswordCtrl.text.trim()) {
      _showSnackBar(
        'Passwords do not match. Please re-enter.',
        isError: true,
      );
      return;
    }

    setState(() => _isSaving = true);
    final authVM = context.read<AuthCompanyViewModel>();

    final contact = _contactCtrl.text.trim();
    final isEmail = contact.contains('@');
    final phone = isEmail ? '' : contact;
    final email = isEmail ? contact : null;

    try {
      await authVM.registerNewCompany(
        name: _shopNameCtrl.text.trim(),
        ownerName: _ownerNameCtrl.text.trim(),
        phone: phone,
        email: email,
        address: _locationCtrl.text.trim(),
        defaultLanguage: _selectedLanguage,
      );

      if (!mounted) return;
      _showSnackBar('Restaurant registered successfully! Welcome aboard. 🎉',
          isError: false);

      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MainLayout(),
          transitionsBuilder: (_, a, __, c) =>
              FadeTransition(opacity: a, child: c),
          transitionDuration: const Duration(milliseconds: 350),
        ),
            (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Registration failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnackBar(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(msg,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        backgroundColor:
        isError ? const Color(0xFFB91C1C) : const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: Duration(seconds: isError ? 5 : 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: _buildAppBar(context),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Branding Header ──────────────────────────────────
                      _buildBrandingHeader(context),
                      const SizedBox(height: 24),

                      // ── Step 1: Restaurant Info ──────────────────────────
                      _buildSectionCard(
                        icon: Icons.storefront_rounded,
                        iconColor: _navy,
                        iconBg: _navy.withOpacity(0.08),
                        title: 'Business Details',
                        children: [
                          _buildFieldLabel('Restaurant Name', required: true),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _shopNameCtrl,
                            hint: 'Enter restaurant name',
                            icon: Icons.restaurant_rounded,
                            validator: (v) => v?.trim().isEmpty == true
                                ? 'Please enter restaurant name'
                                : null,
                          ),
                          const SizedBox(height: 18),

                          _buildFieldLabel('Owner Name', required: true),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _ownerNameCtrl,
                            hint: 'Enter owner name',
                            icon: Icons.person_outline_rounded,
                            validator: (v) => v?.trim().isEmpty == true
                                ? 'Please enter owner name'
                                : null,
                          ),
                          const SizedBox(height: 18),

                          _buildFieldLabel('Full Address', required: true),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _locationCtrl,
                            hint: 'Enter complete address',
                            icon: Icons.location_on_outlined,
                            maxLines: 2,
                            validator: (v) => v?.trim().isEmpty == true
                                ? 'Please enter location / address'
                                : null,
                          ),
                          const SizedBox(height: 18),

                          _buildFieldLabel('Email or Phone', required: true),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _contactCtrl,
                            hint: 'Enter email or 10-digit mobile',
                            icon: Icons.alternate_email_rounded,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Required field';
                              }
                              final text = v.trim();
                              if (text.contains('@')) {
                                if (!text.contains('.') || text.endsWith('.')) {
                                  return 'Invalid email address';
                                }
                              } else {
                                final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
                                if (digits.length < 10) {
                                  return 'Invalid mobile number';
                                }
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Step 2: Language ─────────────────────────────────
                      _buildSectionCard(
                        icon: Icons.language_rounded,
                        iconColor: AppTheme.accentBlue,
                        iconBg: AppTheme.accentBlueLight,
                        title: 'Language Preference',
                        children: [
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: _languages.map((l) {
                              final isSelected = _selectedLanguage == l['code'];
                              return GestureDetector(
                                onTap: () {
                                  setState(() => _selectedLanguage = l['code']!);
                                  context
                                      .read<AuthCompanyViewModel>()
                                      .changeLanguage(l['code']!);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected ? _navy : _fieldBg,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (isSelected)
                                        const Padding(
                                          padding: EdgeInsets.only(right: 8),
                                          child: Icon(
                                            Icons.check_circle_rounded,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      Text(
                                        l['name']!,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w600,
                                          color: isSelected
                                              ? Colors.white
                                              : _muted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // ── Info Notice ──────────────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.accentBlueLight,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline_rounded,
                                color: AppTheme.accentBlue, size: 20),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'After registration, you can sign in using your registered mobile number or email with your password.',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: Color(0xFF1E3A8A),
                                  height: 1.4,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Submit Button ─────────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _navy,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shadowColor: _navy.withValues(alpha: 0.35),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: _isSaving ? null : _handleRegister,
                          child: _isSaving
                              ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                              : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle_outline_rounded, size: 22),
                              const SizedBox(width: 10),
                              Text(
                                context.tr('register_restaurant'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Already have account ──────────────────────────────
                      Center(
                        child: TextButton.icon(
                          icon: const Icon(Icons.login_rounded,
                              size: 18, color: _navy),
                          label: Text(
                            context.tr('already_have_account'),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _navy,
                            ),
                          ),
                          onPressed: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            } else {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (_) => const LoginScreen()),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        context.tr('register_restaurant'),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: _navy,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      foregroundColor: _navy,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: _navy),
        onPressed: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          }
        },
      ),
    );
  }

  Widget _buildBrandingHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.storefront_rounded,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('register_shop_title'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr('register_shop_subtitle'),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: _ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Fields
          ...children,
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label, {bool required = false}) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
        if (required)
          const Text(
            ' *',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFFDC2626),
            ),
          ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _ink,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: _muted, fontWeight: FontWeight.w400),
        prefixIcon: maxLines == 1
            ? Padding(
          padding: const EdgeInsets.only(left: 12, right: 8),
          child: Icon(icon, color: _muted, size: 20),
        )
            : null,
        prefixIconConstraints: maxLines == 1 ? const BoxConstraints(minWidth: 40, minHeight: 40) : null,
        filled: true,
        fillColor: _fieldBg,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: maxLines > 1 ? 16 : 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none, // Removed the noisy border
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _navy, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDC2626)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
        ),
      ),
      validator: validator,
    );
  }
}