import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/theme.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/language_selector.dart';
import '../../viewmodels/auth_company_viewmodel.dart';
import '../main_layout.dart';

class AuthCompanyScreen extends StatefulWidget {
  const AuthCompanyScreen({super.key});

  @override
  State<AuthCompanyScreen> createState() => _AuthCompanyScreenState();
}

class _AuthCompanyScreenState extends State<AuthCompanyScreen> {
  void _openRegisterDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final ownerCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final gstinCtrl = TextEditingController();
    String selectedLang = 'en';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.accentEmerald.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add_business_rounded, color: AppTheme.accentEmerald, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        context.tr('register_company'),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(dialogCtx),
                  ),
                ],
              ),
              content: SizedBox(
                width: 480,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.accentBlueLight,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFBFDBFE)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.cloud_done_rounded, color: AppTheme.accentBlue, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  context.tr('unique_id_notice'),
                                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF1E3A8A)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        CustomTextField(
                          label: context.tr('company_name'),
                          hint: 'e.g. Mahavir Caterers & Hospitality',
                          controller: nameCtrl,
                          prefixIcon: Icons.storefront_rounded,
                          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                label: context.tr('owner_name'),
                                hint: 'e.g. Suresh Patel',
                                controller: ownerCtrl,
                                prefixIcon: Icons.person_outline_rounded,
                                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: CustomTextField(
                                label: context.tr('phone'),
                                hint: '+91 98980 12345',
                                controller: phoneCtrl,
                                keyboardType: TextInputType.phone,
                                prefixIcon: Icons.phone_outlined,
                                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: context.tr('email'),
                          hint: 'owner@cateringfirm.com (Unique account email)',
                          controller: emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.alternate_email_rounded,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Required';
                            if (!v.contains('@')) return 'Invalid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: context.tr('address'),
                          hint: 'Commercial Kitchen & Office address',
                          controller: addressCtrl,
                          prefixIcon: Icons.location_on_outlined,
                          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                label: context.tr('gstin'),
                                hint: '24AAAAA0000A1Z5',
                                controller: gstinCtrl,
                                prefixIcon: Icons.receipt_long_outlined,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.tr('language'),
                                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                                  ),
                                  const SizedBox(height: 5),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: AppTheme.borderLight),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: selectedLang,
                                        isExpanded: true,
                                        items: const [
                                          DropdownMenuItem(value: 'en', child: Text('English', style: TextStyle(fontSize: 13))),
                                          DropdownMenuItem(value: 'hi', child: Text('हिन्दी (Hindi)', style: TextStyle(fontSize: 13))),
                                          DropdownMenuItem(value: 'gu', child: Text('ગુજરાતી', style: TextStyle(fontSize: 13))),
                                        ],
                                        onChanged: (val) {
                                          if (val != null) {
                                            setDialogState(() => selectedLang = val);
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                CustomButton(
                  text: context.tr('cancel'),
                  variant: ButtonVariant.outline,
                  isDense: true,
                  onPressed: () => Navigator.pop(dialogCtx),
                ),
                CustomButton(
                  text: context.tr('save'),
                  variant: ButtonVariant.primary,
                  isDense: true,
                  onPressed: () async {
                    if (formKey.currentState?.validate() == true) {
                      final authVM = context.read<AuthCompanyViewModel>();
                      await authVM.registerNewCompany(
                        name: nameCtrl.text,
                        ownerName: ownerCtrl.text,
                        phone: phoneCtrl.text,
                        email: emailCtrl.text,
                        address: addressCtrl.text,
                        gstin: gstinCtrl.text,
                        defaultLanguage: selectedLang,
                      );
                      if (context.mounted) {
                        Navigator.pop(dialogCtx);
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const MainLayout()),
                        );
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthCompanyViewModel>();
    final companies = authVM.companies;

    return Scaffold(
      backgroundColor: AppTheme.surfaceBackground,
      appBar: AppBar(
        title: Text(context.tr('login_title')),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 14),
            child: LanguageSelector(darkBackground: false),
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 680),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Banner
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.primaryNavy,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.accentEmerald.withAlpha(40),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.business_center_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('app_name'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            context.tr('login_subtitle'),
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CustomButton(
                      text: context.tr('add'),
                      icon: Icons.add,
                      variant: ButtonVariant.secondary,
                      isDense: true,
                      onPressed: () => _openRegisterDialog(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.tr('companies'),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    '${companies.length} Registered',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Expanded(
                child: companies.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.store_outlined, size: 48, color: AppTheme.textMuted),
                            const SizedBox(height: 10),
                            Text(context.tr('no_data'), style: const TextStyle(color: AppTheme.textSecondary)),
                            const SizedBox(height: 14),
                            CustomButton(
                              text: context.tr('register_company'),
                              onPressed: () => _openRegisterDialog(context),
                              isDense: true,
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: companies.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (ctx, index) {
                          final company = companies[index];
                          final isCurrent = authVM.activeCompany?.id == company.id;

                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isCurrent ? AppTheme.accentEmerald : AppTheme.borderLight,
                                width: isCurrent ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: isCurrent ? AppTheme.accentEmerald : AppTheme.primaryNavy,
                                  child: Text(
                                    company.name.isNotEmpty ? company.name[0].toUpperCase() : 'C',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              company.name,
                                              style: const TextStyle(
                                                fontSize: 14.5,
                                                fontWeight: FontWeight.w700,
                                                color: AppTheme.textPrimary,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFEFF6FF),
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(color: const Color(0xFFBFDBFE)),
                                            ),
                                            child: Text(
                                              company.id,
                                              style: const TextStyle(
                                                color: Color(0xFF1D4ED8),
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        'Owner: ${company.ownerName} • ${company.email}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${company.phone} • ${company.address}',
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          color: AppTheme.textMuted,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                CustomButton(
                                  text: isCurrent ? 'Active' : 'Select',
                                  variant: isCurrent ? ButtonVariant.secondary : ButtonVariant.outline,
                                  icon: isCurrent ? Icons.check_circle_rounded : Icons.login_rounded,
                                  isDense: true,
                                  onPressed: () async {
                                    await authVM.switchCompany(company);
                                    if (context.mounted) {
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(builder: (_) => const MainLayout()),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
