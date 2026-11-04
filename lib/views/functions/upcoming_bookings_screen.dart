import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../data/models/function_model.dart';
import '../../services/pdf_generator_service.dart';
import '../../viewmodels/auth_company_viewmodel.dart';
import '../../viewmodels/functions_viewmodel.dart';
import 'create_function_screen.dart';
import 'function_detail_screen.dart';

class UpcomingBookingsScreen extends StatefulWidget {
  const UpcomingBookingsScreen({super.key});

  @override
  State<UpcomingBookingsScreen> createState() =>
      _UpcomingBookingsScreenState();
}

class _UpcomingBookingsScreenState extends State<UpcomingBookingsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  static const _pageBackground = Color(0xFFF5F7FA);
  static const _ink = Color(0xFF182230);
  static const _muted = Color(0xFF667085);
  static const _line = Color(0xFFE7EBF0);
  static const _navy = Color(0xFF203A5F);

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
    final company = context.read<AuthCompanyViewModel>().activeCompany;
    if (company != null) {
      context.read<FunctionsViewModel>().loadFunctions(company.id);
    }
  }

  Future<void> _openCreateFunction() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateFunctionScreen()),
    );
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    final fnVM = context.watch<FunctionsViewModel>();
    final bookings = fnVM.upcomingFunctions;

    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        title: Text(
          context.tr('nav_upcoming'),
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.35,
            color: _ink,
          ),
        ),
        actions: [
          IconButton(
            tooltip: context.tr('new_function'),
            onPressed: _openCreateFunction,
            icon: const Icon(Icons.add_rounded, color: _navy, size: 27),
          ),
          const SizedBox(width: 6),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateFunction,
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        elevation: 3,
        icon: const Icon(Icons.add_rounded, size: 20),
        label: Text(
          context.tr('new_function'),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _navy.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _navy.withValues(alpha: 0.18), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.event_available_rounded,
                            size: 15,
                            color: _navy,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${bookings.length} ${bookings.length == 1 ? "Upcoming Booking" : "Upcoming Bookings"}',
                            style: const TextStyle(
                              color: _navy,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _line),
                      ),
                      child: const Text(
                        'LIVE SCHEDULE',
                        style: TextStyle(
                          color: _muted,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _line, width: 1.2),
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
                    onChanged: (value) {
                      fnVM.setSearchQuery(value);
                      setState(() {});
                    },
                    textInputAction: TextInputAction.search,
                    style: const TextStyle(
                      fontSize: 13,
                      color: _ink,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: context.tr('search'),
                      hintStyle: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF98A2B3),
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: _navy,
                      ),
                      suffixIcon: _searchCtrl.text.isEmpty
                          ? null
                          : IconButton(
                        tooltip: 'Clear search',
                        onPressed: () {
                          _searchCtrl.clear();
                          fnVM.setSearchQuery('');
                          setState(() {});
                        },
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: _muted,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 13,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: bookings.isEmpty
                ? EmptyStateView(
              title: 'No Upcoming Bookings',
              subtitle:
              'New bookings will appear here. Past events move to Previous automatically.',
              icon: Icons.event_note_rounded,
              actionText: context.tr('new_function'),
              onAction: _openCreateFunction,
            )
                : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: bookings.length,
              separatorBuilder: (_, __) =>
              const SizedBox(height: 12),
              itemBuilder: (context, index) => _UpcomingBookingCard(
                function: bookings[index],
                onRefresh: _load,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingBookingCard extends StatelessWidget {
  const _UpcomingBookingCard({
    required this.function,
    required this.onRefresh,
  });

  final FunctionModel function;
  final VoidCallback onRefresh;

  static const _ink = Color(0xFF182230);
  static const _line = Color(0xFFE7EBF0);
  static const _navy = Color(0xFF203A5F);

  String _datePart(String value, String pattern, {String fallback = ''}) {
    try {
      return DateFormat(pattern).format(DateTime.parse(value));
    } catch (_) {
      return fallback;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fnVM = context.watch<FunctionsViewModel>();
    final hasMaterials = fnVM.hasCachedMaterials(function.id);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 7),
            spreadRadius: 0,
          ),
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
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FunctionDetailScreen(function: function),
              ),
            );
            onRefresh();
          },
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BookingDateTile(
                      month: _datePart(function.eventDate, 'MMM', fallback: 'DATE'),
                      day: _datePart(function.eventDate, 'dd', fallback: '--'),
                      weekday: _datePart(function.eventDate, 'EEE'),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            function.eventName.trim().isEmpty
                                ? 'Untitled event'
                                : function.eventName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _ink,
                              fontSize: 15,
                              height: 1.3,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _BookingInfoLine(
                            icon: Icons.person_outline_rounded,
                            text: function.customerName.trim().isNotEmpty
                                ? function.customerName
                                : 'Customer not specified',
                          ),
                          if (function.venue.trim().isNotEmpty) ...[
                            const SizedBox(height: 5),
                            _BookingInfoLine(
                              icon: Icons.location_on_outlined,
                              text: function.venue,
                            ),
                          ],
                          const SizedBox(height: 5),
                          _BookingInfoLine(
                            icon: Icons.schedule_rounded,
                            text: function.eventTime.trim().isNotEmpty
                                ? function.eventTime
                                : 'Full day',
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (function.customerPhone.isNotEmpty) ...[
                          Container(
                            decoration: BoxDecoration(
                              color: _navy.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _navy.withValues(alpha: 0.18), width: 1),
                            ),
                            child: IconButton(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.all(6),
                              constraints: const BoxConstraints(),
                              icon: const Icon(Icons.phone_rounded, color: _navy, size: 16),
                              tooltip: 'Call ${function.customerName}',
                              onPressed: () => PdfGeneratorService.launchPhoneCall(phone: function.customerPhone),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            decoration: BoxDecoration(
                              color: _navy.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _navy.withValues(alpha: 0.18), width: 1),
                            ),
                            child: IconButton(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.all(6),
                              constraints: const BoxConstraints(),
                              icon: const Icon(Icons.chat_bubble_rounded, color: _navy, size: 16),
                              tooltip: 'Message ${function.customerName}',
                              onPressed: () => PdfGeneratorService.launchWhatsAppChat(phone: function.customerPhone),
                            ),
                          ),
                        ],
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: Color(0xFF98A2B3),
                        ),
                      ],
                    ),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: _line),
                ),

                // ==========================================
                // BOTTOM SECTION: Unified Status Tags
                // ==========================================
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _GuestCountLabel(count: function.guestCount),
                    _MaterialStatusLabel(hasMaterials: hasMaterials),
                    if (function.dishes.isNotEmpty)
                      _DishesLabel(count: function.dishes.length),
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

class _BookingDateTile extends StatelessWidget {
  const _BookingDateTile({
    required this.month,
    required this.day,
    required this.weekday,
  });

  final String month;
  final String day;
  final String weekday;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF203A5F).withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: const BoxDecoration(
              color: Color(0xFF203A5F),
              borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Text(
              month.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                Text(
                  day,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 21,
                    height: 1.05,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                  ),
                ),
                if (weekday.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    weekday,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingInfoLine extends StatelessWidget {
  const _BookingInfoLine({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF8792A2)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF667085),
              fontSize: 12,
              height: 1.35,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// UNIFIED STATUS TAGS (Matching Styles)
// ==========================================

class _GuestCountLabel extends StatelessWidget {
  const _GuestCountLabel({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F6F9),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.groups_2_outlined,
            size: 15,
            color: Color(0xFF52657A),
          ),
          const SizedBox(width: 6),
          Text(
            context.tr('cook_for_people', params: {'count': '$count'}),
            style: const TextStyle(
              color: Color(0xFF44566B),
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MaterialStatusLabel extends StatelessWidget {
  const _MaterialStatusLabel({required this.hasMaterials});

  final bool hasMaterials;

  @override
  Widget build(BuildContext context) {
    final foreground =
    hasMaterials ? const Color(0xFF357A70) : const Color(0xFF737D8C);
    final background =
    hasMaterials ? const Color(0xFFEEF6F3) : const Color(0xFFF3F5F7);
    final icon = hasMaterials
        ? Icons.picture_as_pdf_outlined
        : Icons.playlist_add_outlined;
    final label = hasMaterials ? 'PDF ready' : 'No material list';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: foreground),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// 👇 NEW: Dishes Label Widget
class _DishesLabel extends StatelessWidget {
  const _DishesLabel({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F6F9),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.restaurant_rounded,
            size: 15,
            color: Color(0xFF52657A),
          ),
          const SizedBox(width: 6),
          Text(
            '$count ${count == 1 ? "Item" : "Items"} to Cook',
            style: const TextStyle(
              color: Color(0xFF44566B),
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}