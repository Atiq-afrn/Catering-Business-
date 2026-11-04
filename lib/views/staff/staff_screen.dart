import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/theme.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../data/models/staff_model.dart';
import '../../services/pdf_generator_service.dart';
import '../../viewmodels/auth_company_viewmodel.dart';
import '../../viewmodels/staff_viewmodel.dart';
import 'staff_detail_screen.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _load() {
    final comp = context.read<AuthCompanyViewModel>().activeCompany;
    if (comp != null) {
      context.read<StaffViewModel>().loadStaff(comp.id);
    }
  }

  void _openAddStaffDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final wageCtrl = TextEditingController(text: '800');
    final hourlyCtrl = TextEditingController(text: '100');
    final monthlyCtrl = TextEditingController(text: '15000');
    String joiningDate = DateTime.now().toIso8601String().substring(0, 10);
    String role = 'helper';
    String paymentType = 'daily';

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(context.tr('add_staff'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    label: context.tr('staff_name'),
                    hint: 'Full Name',
                    controller: nameCtrl,
                    prefixIcon: Icons.person_outline,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    label: context.tr('phone'),
                    hint: '+91 98980 00000',
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                  ),
                  const SizedBox(height: 10),
                  // Joining Date Picker
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.tr('joining_date'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                      const SizedBox(height: 5),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2015),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setDialogState(() {
                              joiningDate = picked.toIso8601String().substring(0, 10);
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.borderLight),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(joiningDate, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              const Icon(Icons.calendar_today_rounded, size: 16, color: AppTheme.primaryNavy),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Role Dropdown
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.tr('role'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
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
                            value: role,
                            isExpanded: true,
                            items: [
                              DropdownMenuItem(value: 'head_chef', child: Text(context.tr('role_head_chef'), style: const TextStyle(fontSize: 13))),
                              DropdownMenuItem(value: 'asst_chef', child: Text(context.tr('role_asst_chef'), style: const TextStyle(fontSize: 13))),
                              DropdownMenuItem(value: 'helper', child: Text(context.tr('role_helper'), style: const TextStyle(fontSize: 13))),
                              DropdownMenuItem(value: 'server', child: Text(context.tr('role_server'), style: const TextStyle(fontSize: 13))),
                              DropdownMenuItem(value: 'cleaner', child: Text(context.tr('role_cleaner'), style: const TextStyle(fontSize: 13))),
                              DropdownMenuItem(value: 'supervisor', child: Text(context.tr('role_supervisor'), style: const TextStyle(fontSize: 13))),
                            ],
                            onChanged: (v) {
                              if (v != null) setDialogState(() => role = v);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Payment Type Dropdown (Daily Worker vs Monthly Payment)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.tr('payment_type'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
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
                            value: paymentType,
                            isExpanded: true,
                            items: [
                              DropdownMenuItem(
                                value: 'daily',
                                child: Text(context.tr('daily_worker'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              ),
                              DropdownMenuItem(
                                value: 'monthly',
                                child: Text(context.tr('monthly_payment'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              ),
                            ],
                            onChanged: (v) {
                              if (v != null) setDialogState(() => paymentType = v);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (paymentType == 'monthly')
                    CustomTextField(
                      label: context.tr('monthly_pay'),
                      hint: 'e.g. 15000',
                      controller: monthlyCtrl,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.currency_rupee,
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: context.tr('daily_wage'),
                            controller: wageCtrl,
                            keyboardType: TextInputType.number,
                            prefixIcon: Icons.currency_rupee,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: CustomTextField(
                            label: context.tr('hourly_wage'),
                            controller: hourlyCtrl,
                            keyboardType: TextInputType.number,
                            prefixIcon: Icons.access_time,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                      side: const BorderSide(color: AppTheme.borderLight, width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    onPressed: () => Navigator.pop(dialogCtx),
                    child: Text(
                      context.tr('cancel'),
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryNavy,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: AppTheme.primaryNavy.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    onPressed: () async {
                      if (nameCtrl.text.isNotEmpty) {
                        final activeComp = context.read<AuthCompanyViewModel>().activeCompany;
                        if (activeComp != null) {
                          await context.read<StaffViewModel>().addStaff(
                                companyId: activeComp.id,
                                name: nameCtrl.text,
                                phone: phoneCtrl.text,
                                role: role,
                                joiningDate: joiningDate,
                                paymentType: paymentType,
                                dailyWage: double.tryParse(wageCtrl.text) ?? 800.0,
                                monthlyPay: double.tryParse(monthlyCtrl.text) ?? 0.0,
                                hourlyRate: double.tryParse(hourlyCtrl.text) ?? 100.0,
                              );
                        }
                        if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                      }
                    },
                    child: Text(
                      context.tr('save'),
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteStaff(BuildContext context, StaffModel staff) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24),
            const SizedBox(width: 8),
            Text(context.tr('delete_staff'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ],
        ),
        content: Text(
          'Are you sure you want to delete ${staff.name}? This will also delete their payment records.',
          style: const TextStyle(fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr('cancel'), style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final activeComp = context.read<AuthCompanyViewModel>().activeCompany;
              if (activeComp != null) {
                await context.read<StaffViewModel>().deleteStaff(activeComp.id, staff.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${staff.name} deleted successfully')),
                  );
                }
              }
            },
            child: Text(context.tr('delete'), style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final staffVM = context.watch<StaffViewModel>();
    final staffList = staffVM.filteredStaff;
    final monthlyEvents = staffVM.monthlyEventsCount;

    return Scaffold(
      backgroundColor: AppTheme.surfaceBackground,
      appBar: AppBar(
        title: Text(context.tr('staff_title')),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppTheme.textPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded, color: AppTheme.primaryNavy),
            tooltip: context.tr('add_staff'),
            onPressed: () => _openAddStaffDialog(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(context.tr('add_staff')),
        onPressed: () => _openAddStaffDialog(context),
      ),
      body: Column(
        children: [
          // 1. Search Bar for Staff and Wage Management
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => staffVM.setSearchQuery(v),
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: context.tr('search_staff'),
                prefixIcon: const Icon(Icons.search, size: 18),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () {
                          _searchCtrl.clear();
                          staffVM.setSearchQuery('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                filled: true,
                fillColor: AppTheme.surfaceBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.borderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.borderLight),
                ),
              ),
            ),
          ),

          // 2. Role Filter Chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  'all',
                  'head_chef',
                  'asst_chef',
                  'helper',
                  'server',
                  'cleaner',
                  'supervisor',
                ].map((roleKey) {
                  final isSelected = staffVM.selectedRoleFilter == roleKey;
                  final label = roleKey == 'all' ? 'All Roles' : context.tr('role_$roleKey');
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: isSelected,
                      selectedColor: AppTheme.primaryNavy,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.textPrimary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 11,
                      ),
                      backgroundColor: AppTheme.surfaceBackground,
                      onSelected: (val) {
                        if (val) staffVM.setRoleFilter(roleKey);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // 3. Monthly Events Stat Header Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryNavy.withValues(alpha: 0.08),
                    AppTheme.primaryNavy.withValues(alpha: 0.03),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.primaryNavy.withValues(alpha: 0.2), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryNavy.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.event_available_rounded, color: AppTheme.primaryNavy, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('events_this_month'),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                        ),
                        Text(
                          '$monthlyEvents Catering Functions Scheduled',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.primaryNavy),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryNavy,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${staffList.length} Active Staff',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. Staff Cards List
          Expanded(
            child: staffList.isEmpty
                ? (staffVM.searchQuery.isNotEmpty || staffVM.selectedRoleFilter != 'all'
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            const Text(
                              'No staff found matching search',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Try searching another name, phone number, or role.',
                              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                            ),
                            const SizedBox(height: 12),
                            TextButton.icon(
                              onPressed: () {
                                _searchCtrl.clear();
                                staffVM.setSearchQuery('');
                                staffVM.setRoleFilter('all');
                              },
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Reset Filters'),
                            ),
                          ],
                        ),
                      )
                    : EmptyStateView(
                        title: 'No Staff Registered',
                        subtitle: 'Add chefs, karigars, helpers, and servers to manage wages and payments.',
                        icon: Icons.group_off_outlined,
                        actionText: context.tr('add_staff'),
                        onAction: () => _openAddStaffDialog(context),
                      ))
                : ListView.separated(
                    padding: const EdgeInsets.all(14),
                    itemCount: staffList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, i) {
                      final staff = staffList[i];
                      return _StaffCard(
                        staff: staff,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => StaffDetailScreen(staff: staff)),
                          ).then((_) => _load());
                        },
                        onDelete: () => _confirmDeleteStaff(context, staff),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _StaffCard extends StatelessWidget {
  final StaffModel staff;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _StaffCard({
    required this.staff,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          // 3D Ambient soft drop shadow
          BoxShadow(
            color: const Color(0xFF1E293B).withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
          // 3D tactile offset ground shadow
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                // 3D Elevated Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryNavy.withValues(alpha: 0.16),
                        AppTheme.primaryNavy.withValues(alpha: 0.06),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: AppTheme.primaryNavy.withValues(alpha: 0.22),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryNavy.withValues(alpha: 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    staff.name.isNotEmpty ? staff.name[0].toUpperCase() : 'S',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        staff.name,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceBackground,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: AppTheme.borderLight, width: 0.8),
                            ),
                            child: Text(
                              context.tr('role_${staff.role}'),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryNavy,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Joined: ${staff.joiningDate}',
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: AppTheme.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        staff.paymentType == 'monthly'
                            ? 'Monthly Pay: ₹${staff.monthlyPay.toStringAsFixed(0)} / mo'
                            : 'Daily: ₹${staff.dailyWage.toStringAsFixed(0)} • Hourly: ₹${staff.hourlyRate.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: staff.paymentType == 'monthly' ? const Color(0xFF0D9488) : AppTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                // Direct Phone Call Action
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.all(5),
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.phone_rounded, color: AppTheme.primaryNavy, size: 20),
                  tooltip: 'Call ${staff.name}',
                  onPressed: () => PdfGeneratorService.launchPhoneCall(phone: staff.phone),
                ),
                const SizedBox(width: 4),
                // WhatsApp Message Action
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.all(5),
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.chat_bubble_rounded, color: AppTheme.primaryNavy, size: 20),
                  tooltip: context.tr('send_whatsapp'),
                  onPressed: () => PdfGeneratorService.launchWhatsAppChat(phone: staff.phone),
                ),
                if (onDelete != null) ...[
                  const SizedBox(width: 4),
                  // Delete Staff Button
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(5),
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                    tooltip: context.tr('delete_staff'),
                    onPressed: onDelete,
                  ),
                ],
                const SizedBox(width: 2),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 19),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

