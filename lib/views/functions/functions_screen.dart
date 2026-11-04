import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/theme.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/company_header_card.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../viewmodels/auth_company_viewmodel.dart';
import '../../viewmodels/functions_viewmodel.dart';
import 'function_detail_screen.dart';
import 'create_function_screen.dart';
import '../auth/auth_company_screen.dart';

class FunctionsScreen extends StatefulWidget {
  const FunctionsScreen({super.key});

  @override
  State<FunctionsScreen> createState() => _FunctionsScreenState();
}

class _FunctionsScreenState extends State<FunctionsScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
    });
  }

  void _load() {
    final comp = context.read<AuthCompanyViewModel>().activeCompany;
    if (comp != null) {
      context.read<FunctionsViewModel>().loadFunctions(comp.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fnVM = context.watch<FunctionsViewModel>();
    final functions = fnVM.filteredFunctions;

    final filterOptions = [
      {'key': 'all', 'label': context.tr('all')},
      {'key': 'confirmed', 'label': context.tr('status_confirmed')},
      {'key': 'prep_pending', 'label': context.tr('status_prep_pending')},
      {'key': 'cooking', 'label': context.tr('status_cooking')},
      {'key': 'completed', 'label': context.tr('status_completed')},
    ];

    return Scaffold(
      backgroundColor: AppTheme.surfaceBackground,
      appBar: AppBar(
        title: Text(context.tr('function_list')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CreateFunctionScreen()),
              ).then((_) => _load());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Company Scope Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: CompanyHeaderCard(
              onSwitchCompany: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AuthCompanyScreen()),
                ).then((_) => _load());
              },
            ),
          ),

          // Search and Filters
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => fnVM.setSearchQuery(v),
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: context.tr('search'),
                    prefixIcon: const Icon(Icons.search, size: 18),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 16),
                            onPressed: () {
                              _searchCtrl.clear();
                              fnVM.setSearchQuery('');
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: filterOptions.map((opt) {
                      final isSelected = fnVM.selectedStatusFilter == opt['key'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(opt['label']!, style: TextStyle(fontSize: 11.5, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
                          selected: isSelected,
                          selectedColor: AppTheme.primaryNavy,
                          labelStyle: TextStyle(color: isSelected ? Colors.white : AppTheme.textPrimary),
                          backgroundColor: const Color(0xFFF1F5F9),
                          side: BorderSide.none,
                          onSelected: (_) => fnVM.setStatusFilter(opt['key']!),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Functions List
          Expanded(
            child: fnVM.isLoading
                ? const Center(child: CircularProgressIndicator())
                : functions.isEmpty
                    ? EmptyStateView(
                        icon: Icons.event_note_outlined,
                        title: context.tr('no_data'),
                        actionText: context.tr('create_function'),
                        onAction: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const CreateFunctionScreen()),
                          ).then((_) => _load());
                        },
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: functions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final fn = functions[index];

                          return InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => FunctionDetailScreen(function: fn),
                                ),
                              ).then((_) => _load());
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
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
                                      Expanded(
                                        child: Text(
                                          fn.eventName,
                                          style: const TextStyle(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.textPrimary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      StatusBadge(status: fn.status),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.person_outline, size: 14, color: AppTheme.textSecondary),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${fn.customerName} (${fn.customerPhone})',
                                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today_outlined, size: 14, color: AppTheme.textSecondary),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${fn.eventDate} • ${fn.guestCount} ${context.tr('guests')}',
                                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                      ),
                                      const Spacer(),
                                      Text(
                                        '₹${fn.quotationAmount.toStringAsFixed(0)}',
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primaryDark),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${fn.dishes.length} ${context.tr('menu_items')}',
                                        style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            context.tr('view_details'),
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryNavy),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: AppTheme.primaryNavy),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
