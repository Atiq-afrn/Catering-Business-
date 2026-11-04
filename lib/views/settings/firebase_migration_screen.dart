import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../app/theme.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/language_selector.dart';
import '../../viewmodels/auth_company_viewmodel.dart';
import '../../viewmodels/costing_viewmodel.dart';
import '../../data/firebase/firebase_migration_service.dart';
import '../auth/auth_company_screen.dart';

class FirebaseMigrationScreen extends StatefulWidget {
  const FirebaseMigrationScreen({super.key});

  @override
  State<FirebaseMigrationScreen> createState() => _FirebaseMigrationScreenState();
}

class _FirebaseMigrationScreenState extends State<FirebaseMigrationScreen> {
  String? _jsonBundle;
  bool _isExporting = false;

  void _showFirestoreRulesDialog(BuildContext context) {
    final rules = FirebaseMigrationService.getFirestoreSecurityRules();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Firestore Security Rules', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: SizedBox(
          width: 520,
          height: 380,
          child: SingleChildScrollView(
            child: SelectableText(
              rules,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11.5, color: Color(0xFF0F172A)),
            ),
          ),
        ),
        actions: [
          CustomButton(
            text: 'Copy Rules',
            icon: Icons.copy,
            isDense: true,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: rules));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Security rules copied to clipboard!')),
              );
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthCompanyViewModel>();
    final activeCompany = authVM.activeCompany;
    final costingVM = context.watch<CostingViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.surfaceBackground,
      appBar: AppBar(
        title: Text(context.tr('db_title')),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 14),
            child: LanguageSelector(darkBackground: false),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company Profile Banner
            if (activeCompany != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          activeCompany.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFBFDBFE)),
                          ),
                          child: Text(
                            activeCompany.id,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF1D4ED8)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildRow(context.tr('owner_name'), activeCompany.ownerName),
                    _buildRow(context.tr('email'), activeCompany.email),
                    _buildRow(context.tr('phone'), activeCompany.phone),
                    _buildRow(context.tr('address'), activeCompany.address),
                    if (activeCompany.gstin != null && activeCompany.gstin!.isNotEmpty)
                      _buildRow(context.tr('gstin'), activeCompany.gstin!),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        CustomButton(
                          text: context.tr('switch_company'),
                          variant: ButtonVariant.outline,
                          icon: Icons.swap_horiz,
                          isDense: true,
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const AuthCompanyScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Firebase Migration Readiness Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.accentEmerald.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.cloud_sync_rounded, color: AppTheme.accentEmerald, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr('firebase_ready_title'),
                              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              context.tr('ready_to_migrate'),
                              style: const TextStyle(fontSize: 11.5, color: AppTheme.accentEmerald, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.tr('firebase_desc'),
                    style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary, height: 1.4),
                  ),
                  const SizedBox(height: 14),

                  // Firestore Hierarchy Representation
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Firestore Multi-Tenant Subcollections Schema:',
                          style: TextStyle(color: Color(0xFF93C5FD), fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        _buildHierarchyRow('📂 /companies/${activeCompany?.id ?? "comp_id"}'),
                        _buildHierarchyRow('   ├── 📄 company_metadata (owner, name, email, phone)'),
                        _buildHierarchyRow('   ├── 📂 recipes/ (isolated company dish formulas)'),
                        _buildHierarchyRow('   ├── 📂 ingredients/ (catalog & stock balance)'),
                        _buildHierarchyRow('   ├── 📂 functions/ (events, pax, menu, quotation)'),
                        _buildHierarchyRow('   ├── 📂 staff/ (maharaaj, helper, waiter wages)'),
                        _buildHierarchyRow('   └── 📂 expenses/ (ingredient, fuel, labour costs)'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      CustomButton(
                        text: context.tr('export_json'),
                        icon: Icons.download_rounded,
                        variant: ButtonVariant.primary,
                        isDense: true,
                        isLoading: _isExporting,
                        onPressed: () async {
                          if (activeCompany != null) {
                            setState(() => _isExporting = true);
                            final json = await costingVM.exportCompanyFirestoreBundle(activeCompany.id);
                            setState(() {
                              _jsonBundle = json;
                              _isExporting = false;
                            });
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      CustomButton(
                        text: 'Security Rules',
                        icon: Icons.security_rounded,
                        variant: ButtonVariant.outline,
                        isDense: true,
                        onPressed: () => _showFirestoreRulesDialog(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Live JSON Bundle Viewer
            if (_jsonBundle != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Generated Firestore JSON Document Payload:',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18),
                          tooltip: 'Copy JSON',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _jsonBundle!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Firebase JSON copied to clipboard!')),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 260,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.borderLight),
                      ),
                      child: SingleChildScrollView(
                        child: SelectableText(
                          _jsonBundle!,
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Color(0xFF1E293B)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _buildHierarchyRow(String text) {
    return Text(
      text,
      style: const TextStyle(color: Color(0xFFE2E8F0), fontFamily: 'monospace', fontSize: 11),
    );
  }
}
