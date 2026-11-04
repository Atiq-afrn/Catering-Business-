import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/theme.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../data/models/function_model.dart';
import '../../services/pdf_generator_service.dart';
import '../../viewmodels/auth_company_viewmodel.dart';
import '../../viewmodels/functions_viewmodel.dart';
import 'function_detail_screen.dart';

class PreviousBookingsScreen extends StatefulWidget {
  const PreviousBookingsScreen({super.key});

  @override
  State<PreviousBookingsScreen> createState() => _PreviousBookingsScreenState();
}

class _PreviousBookingsScreenState extends State<PreviousBookingsScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
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
    final pastList = fnVM.previousFunctions;

    final totalCompletedRevenue = pastList.fold<double>(0.0, (sum, f) => sum + f.quotationAmount);

    return Scaffold(
      backgroundColor: AppTheme.surfaceBackground,
      appBar: AppBar(
        title: Text(
          context.tr('nav_previous'),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppTheme.textPrimary,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search & Metrics Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.borderLight, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => fnVM.setSearchQuery(v),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: context.tr('search'),
                      prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppTheme.primaryNavy),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 16),
                              onPressed: () {
                                _searchCtrl.clear();
                                fnVM.setSearchQuery('');
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                      filled: true,
                      fillColor: Colors.transparent,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${pastList.length} Archived Past Orders',
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Past Revenue: ₹${totalCompletedRevenue.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Previous Bookings List
          Expanded(
            child: pastList.isEmpty
                ? const EmptyStateView(
                    title: 'No Previous Bookings',
                    subtitle: 'Completed bookings and events past their date will appear here automatically.',
                    icon: Icons.history_rounded,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(14),
                    itemCount: pastList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) {
                      final fn = pastList[i];
                      return _PreviousBookingCard(
                        function: fn,
                        onRefresh: _load,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _PreviousBookingCard extends StatelessWidget {
  final FunctionModel function;
  final VoidCallback onRefresh;

  const _PreviousBookingCard({
    required this.function,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          // 3D Ambient soft drop shadow with offset
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
          // 3D tactile floor shadow with offset
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
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => FunctionDetailScreen(function: function)),
            ).then((_) => onRefresh());
          },
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded, size: 12, color: Color(0xFF64748B)),
                              const SizedBox(width: 5),
                              Text(
                                function.eventDate,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '#${function.id}',
                          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.accentEmerald.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.accentEmerald.withValues(alpha: 0.3), width: 0.8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded, size: 12, color: AppTheme.accentEmerald),
                          SizedBox(width: 4),
                          Text('Completed', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppTheme.accentEmerald)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            function.eventName,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary, letterSpacing: -0.2),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${function.customerName} • ${function.venue.isNotEmpty ? function.venue : 'Venue'}',
                            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (function.customerPhone.isNotEmpty) ...[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppTheme.primaryNavy.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.primaryNavy.withValues(alpha: 0.18), width: 1),
                            ),
                            child: IconButton(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.all(6),
                              constraints: const BoxConstraints(),
                              icon: const Icon(Icons.phone_rounded, color: AppTheme.primaryNavy, size: 16),
                              tooltip: 'Call ${function.customerName}',
                              onPressed: () => PdfGeneratorService.launchPhoneCall(phone: function.customerPhone),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            decoration: BoxDecoration(
                              color: AppTheme.primaryNavy.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.primaryNavy.withValues(alpha: 0.18), width: 1),
                            ),
                            child: IconButton(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.all(6),
                              constraints: const BoxConstraints(),
                              icon: const Icon(Icons.chat_bubble_rounded, color: AppTheme.primaryNavy, size: 16),
                              tooltip: 'Message ${function.customerName}',
                              onPressed: () => PdfGeneratorService.launchWhatsAppChat(phone: function.customerPhone),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),

                if (function.dishes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryNavy.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: AppTheme.primaryNavy.withValues(alpha: 0.18), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.restaurant_rounded, size: 13, color: AppTheme.primaryNavy),
                        const SizedBox(width: 6),
                        Text(
                          '${function.dishes.length} ${function.dishes.length == 1 ? "Item" : "Items"} to Cook',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryNavy,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                // Pax and Financials
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceBackground,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppTheme.borderLight, width: 0.8),
                      ),
                      child: Text(
                        context.tr('cook_for_people', params: {'count': '${function.guestCount}'}),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy),
                      ),
                    ),
                    Text(
                      '₹${function.quotationAmount.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
