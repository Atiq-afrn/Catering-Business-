import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/metric_card.dart';
import '../../viewmodels/auth_company_viewmodel.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../../viewmodels/functions_viewmodel.dart';
import '../functions/create_function_screen.dart';
import '../functions/function_detail_screen.dart';
import '../materials/make_material_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  final void Function(int tabIndex)? onNavigateTab;
  final VoidCallback? onOpenCreateFunction;
  final VoidCallback? onOpenDrawer;

  const DashboardScreen({
    super.key,
    this.onNavigateTab,
    this.onOpenCreateFunction,
    this.onOpenDrawer,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const _navy = Color(0xFF203A5F);
  static const _pageBackground = Color(0xFFF5F7FA);
  static const _ink = Color(0xFF182230);
  static const _muted = Color(0xFF64748B);
  static const _line = Color(0xFFE2E8F0);

  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      if (RegExp(r'^[a-zA-Z]').hasMatch(word)) {
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      }
      return word;
    }).join(' ');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  void _refresh() {
    final authVM = context.read<AuthCompanyViewModel>();
    final activeComp = authVM.activeCompany;
    if (activeComp != null) {
      context.read<DashboardViewModel>().loadDashboard(activeComp.id);
      context.read<FunctionsViewModel>().loadFunctions(activeComp.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthCompanyViewModel>();
    final dashVM = context.watch<DashboardViewModel>();
    final fnVM = context.watch<FunctionsViewModel>();
    final activeComp = authVM.activeCompany;

    final upcoming = fnVM.upcomingFunctions;
    final previous = fnVM.previousFunctions;

    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: _navy, size: 26),
          tooltip: 'Menu Drawer',
          onPressed: () {
            if (widget.onOpenDrawer != null) {
              widget.onOpenDrawer!();
            } else {
              Scaffold.of(context).openDrawer();
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _toTitleCase(activeComp?.name ?? context.tr('app_name')),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17.5,
                color: _ink,
                letterSpacing: -0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (activeComp?.ownerName.isNotEmpty == true)
              Text(
                'Owner: ${_toTitleCase(activeComp!.ownerName)}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: _muted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: _navy, size: 22),
            tooltip: 'Refresh',
            onPressed: _refresh,
          ),
          const SizedBox(width: 4),
        ],
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
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Metric Cards Grid (3D tactile dual-shadow cards)
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final isTablet = width > 600;
                  final crossAxisCount = isTablet ? 4 : 2;
                  final aspectRatio = width < 360 ? 1.2 : (width < 420 ? 1.35 : 1.48);

                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: aspectRatio,
                    children: [
                      MetricCard(
                        title: _toTitleCase(context.tr('upcoming_events')),
                        value: '${upcoming.length}',
                        subtitle: upcoming.length == 1 ? '1 Active Booking' : '${upcoming.length} Active Bookings',
                        icon: Icons.event_available_rounded,
                        iconColor: _navy,
                        onTap: () => widget.onNavigateTab?.call(1),
                      ),
                      MetricCard(
                        title: _toTitleCase(context.tr('previous_events')),
                        value: '${previous.length}',
                        subtitle: 'Archived Past Orders',
                        icon: Icons.history_rounded,
                        iconColor: _navy,
                        onTap: () => widget.onNavigateTab?.call(2),
                      ),
                      MetricCard(
                        title: _toTitleCase(context.tr('advance_received')),
                        value: '₹${dashVM.totalAdvanceReceived.toStringAsFixed(0)}',
                        subtitle: 'Collected Advance',
                        icon: Icons.account_balance_wallet_rounded,
                        iconColor: _navy,
                      ),
                      MetricCard(
                        title: _toTitleCase(context.tr('balance_payable')),
                        value: '₹${dashVM.totalBalancePending.toStringAsFixed(0)}',
                        subtitle: dashVM.totalBalancePending > 0 ? 'Pending Collection' : 'All Settled',
                        icon: Icons.pending_actions_rounded,
                        iconColor: _navy,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 18),

              // 2. Quick Action Buttons Row (3D Tactile Card)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _line, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.07),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: _navy.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: const Icon(Icons.flash_on_rounded, color: _navy, size: 15),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _toTitleCase(context.tr('quick_actions')),
                          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: _ink),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _navy,
                              foregroundColor: Colors.white,
                              elevation: 3,
                              shadowColor: _navy.withValues(alpha: 0.35),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: Text(
                              _toTitleCase(context.tr('new_function')),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                            onPressed: () {
                              if (widget.onOpenCreateFunction != null) {
                                widget.onOpenCreateFunction!();
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const CreateFunctionScreen()),
                                ).then((_) => _refresh());
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: _navy,
                              elevation: 2,
                              shadowColor: const Color(0xFF0F172A).withValues(alpha: 0.12),
                              side: const BorderSide(color: _line, width: 1.2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.playlist_add_rounded, size: 18, color: _navy),
                            label: Text(
                              _toTitleCase(context.tr('make_list')),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const MakeMaterialListScreen()),
                              ).then((_) => _refresh());
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 3. Quick Navigation Summary Card for Upcoming Bookings (3D Tactile Card)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _line, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color: _navy.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _navy.withValues(alpha: 0.18), width: 1),
                                boxShadow: [
                                  BoxShadow(
                                    color: _navy.withValues(alpha: 0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1.5),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.event_available_rounded, color: _navy, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${upcoming.length} Upcoming ${upcoming.length == 1 ? "Booking" : "Bookings"}',
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _ink),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  upcoming.isNotEmpty
                                      ? 'Live Catering Schedule'
                                      : 'No Upcoming Events Pending',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _muted),
                                ),
                              ],
                            ),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: () => widget.onNavigateTab?.call(1),
                          style: TextButton.styleFrom(
                            foregroundColor: _navy,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                          label: const Text('View All', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          icon: const Icon(Icons.arrow_forward_rounded, size: 15),
                        ),
                      ],
                    ),
                    if (upcoming.isNotEmpty) ...[
                      const Divider(height: 22, color: _line),
                      // Next event card with 3D elevation, Pax, Date and PDF Ready status
                      Builder(builder: (context) {
                        final nextEvent = upcoming.first;
                        final hasMat = fnVM.hasCachedMaterials(nextEvent.id);
                        return Container(
                          decoration: BoxDecoration(
                            color: _pageBackground,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: _line, width: 1.1),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                              BoxShadow(
                                color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => FunctionDetailScreen(function: nextEvent)),
                                ).then((_) => _refresh());
                              },
                              borderRadius: BorderRadius.circular(14),
                              child: Padding(
                                padding: const EdgeInsets.all(13),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            _toTitleCase(nextEvent.eventName),
                                            style: const TextStyle(
                                              fontSize: 14.5,
                                              fontWeight: FontWeight.w800,
                                              color: _ink,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (hasMat)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: _navy.withValues(alpha: 0.08),
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: _navy.withValues(alpha: 0.2)),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.picture_as_pdf_rounded, size: 12, color: _navy),
                                                SizedBox(width: 4),
                                                Text(
                                                  'PDF Ready',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w800,
                                                    color: _navy,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: _line),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.calendar_today_rounded, size: 12, color: _muted),
                                              const SizedBox(width: 5),
                                              Text(
                                                nextEvent.eventDate,
                                                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: _muted),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: _line),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.people_alt_rounded, size: 12, color: _navy),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${nextEvent.guestCount} Guests',
                                                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: _navy),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Spacer(),
                                        const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: _muted),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
