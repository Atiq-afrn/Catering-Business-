import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/theme.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../viewmodels/auth_company_viewmodel.dart';
import 'language_selection_screen.dart';
import '../auth/logout_dialog.dart';

class ShopProfileScreen extends StatefulWidget {
  const ShopProfileScreen({super.key});

  @override
  State<ShopProfileScreen> createState() => _ShopProfileScreenState();
}

class _ShopProfileScreenState extends State<ShopProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _shopNameCtrl;
  late TextEditingController _shopPhoneCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _ownerNameCtrl;
  late TextEditingController _ownerPhoneCtrl;
  bool _isSaving = false;


  @override
  void initState() {
    super.initState();
    final company = context.read<AuthCompanyViewModel>().activeCompany;
    _shopNameCtrl = TextEditingController(text: company?.name ?? '');
    _shopPhoneCtrl = TextEditingController(text: company?.phone ?? '');
    _addressCtrl = TextEditingController(text: company?.address ?? '');
    _ownerNameCtrl = TextEditingController(text: company?.ownerName ?? '');
    _ownerPhoneCtrl = TextEditingController(text: company?.ownerPhone ?? company?.phone ?? '');
  }

  @override
  void dispose() {
    _shopNameCtrl.dispose();
    _shopPhoneCtrl.dispose();
    _addressCtrl.dispose();
    _ownerNameCtrl.dispose();
    _ownerPhoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final authVM = context.read<AuthCompanyViewModel>();

    try {
      await authVM.updateCompanyProfile(
        name: _shopNameCtrl.text,
        ownerName: _ownerNameCtrl.text,
        phone: _shopPhoneCtrl.text,
        ownerPhone: _ownerPhoneCtrl.text,
        address: _addressCtrl.text,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('profile_updated')),
          backgroundColor: AppTheme.accentEmerald,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthCompanyViewModel>();
    final currentLang = authVM.currentLanguage;

    return Scaffold(
      backgroundColor: AppTheme.surfaceBackground,
      appBar: AppBar(
        title: Text(context.tr('shop_profile')),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppTheme.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Language Switcher Section - Links to Dedicated Screen
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceBackground,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.language_rounded, size: 20, color: AppTheme.primaryNavy),
                  ),
                  title: Text(
                    context.tr('language'),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    {
                      'en': 'English (Active)',
                      'hi': 'हिन्दी - Hindi (Active)',
                      'mr': 'मराठी - Marathi (Active)',
                      'gu': 'ગુજરાતી - Gujarati (Active)',
                    }[currentLang] ?? 'English',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                  trailing: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Change', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy)),
                      SizedBox(width: 4),
                      Icon(Icons.chevron_right_rounded, size: 20, color: AppTheme.primaryNavy),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LanguageSelectionScreen()));
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Shop Details Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('shop_name'),
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy),
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: context.tr('shop_name'),
                      hint: 'Firm Name',
                      controller: _shopNameCtrl,
                      prefixIcon: Icons.storefront_rounded,
                      validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: context.tr('shop_phone'),
                      hint: 'Shop Phone',
                      controller: _shopPhoneCtrl,
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_rounded,
                      validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: context.tr('address'),
                      hint: 'Shop Location & Address',
                      controller: _addressCtrl,
                      maxLines: 2,
                      prefixIcon: Icons.location_on_outlined,
                      validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Owner Details Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('owner_name'),
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy),
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: context.tr('owner_name'),
                      hint: 'Owner Name',
                      controller: _ownerNameCtrl,
                      prefixIcon: Icons.person_outline,
                      validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: context.tr('owner_phone'),
                      hint: 'Owner Mobile',
                      controller: _ownerPhoneCtrl,
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_android_rounded,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              CustomButton(
                text: context.tr('update_profile'),
                icon: Icons.save_rounded,
                isLoading: _isSaving,
                onPressed: _handleSave,
              ),
              const SizedBox(height: 14),

              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFDC2626),
                  side: const BorderSide(color: Color(0xFFFCA5A5)),
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: Text(
                  context.tr('logout'),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                onPressed: () => showLogoutConfirmationDialog(context),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
