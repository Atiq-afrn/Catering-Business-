
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/models/function_model.dart';
import '../../data/models/event_material_model.dart';
import '../../services/pdf_generator_service.dart';
import '../../viewmodels/auth_company_viewmodel.dart';
import '../../viewmodels/functions_viewmodel.dart';
import '../materials/make_material_list_screen.dart';
import 'customer_history_sheet.dart';

class FunctionDetailScreen extends StatefulWidget {
  final FunctionModel function;

  const FunctionDetailScreen({
    super.key,
    required this.function,
  });

  @override
  State<FunctionDetailScreen> createState() =>
      _FunctionDetailScreenState();
}

class _FunctionDetailScreenState extends State<FunctionDetailScreen> {
  late FunctionModel _currentFunction;

  List<EventMaterialModel> _materials = [];
  bool _isLoadingMaterials = true;
  bool _isUpdatingStatus = false;

  static const Color _accent = Color(0xFF203A5F);
  static const Color _background = Color(0xFFF7F8FA);
  static const Color _surface = Colors.white;
  static const Color _textPrimary = Color(0xFF182230);
  static const Color _textSecondary = Color(0xFF64748B);
  static const Color _border = Color(0xFFE2E8F0);
  static const Color _danger = Color(0xFFB54747);

  final List<String> _statuses = const [
    'draft',
    'confirmed',
    'prep_pending',
    'cooking',
    'completed',
    'cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _currentFunction = widget.function;
    _loadMaterials();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final fnVM = context.read<FunctionsViewModel>();
    final hasMaterials = fnVM.hasCachedMaterials(_currentFunction.id);

    if (hasMaterials &&
        _materials.isEmpty &&
        !_isLoadingMaterials) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadMaterials();
      });
    }
  }

  Future<void> _loadMaterials() async {
    if (!mounted) return;

    setState(() => _isLoadingMaterials = true);

    try {
      final fnVM = context.read<FunctionsViewModel>();

      final materials = await fnVM.getEventMaterials(
        _currentFunction.companyId,
        _currentFunction.id,
      );

      if (!mounted) return;

      setState(() {
        _materials = materials;
        _isLoadingMaterials = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() => _isLoadingMaterials = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to load materials. Please try again.'),
        ),
      );
    }
  }

  bool get _isUpcoming {
    final today = DateTime.now().toIso8601String().substring(0, 10);

    return _currentFunction.eventDate.compareTo(today) >= 0 &&
        _currentFunction.status != 'completed' &&
        _currentFunction.status != 'cancelled';
  }

  String get _customerInitial {
    final name = _currentFunction.customerName.trim();
    return name.isNotEmpty ? name[0].toUpperCase() : 'C';
  }

  String _formatMoney(num amount) {
    return '₹${amount.toStringAsFixed(0)}';
  }

  Future<void> _showCustomerHistory() async {
    final fnVM = context.read<FunctionsViewModel>();

    final history = await fnVM.getCustomerHistory(
      _currentFunction.companyId,
      _currentFunction.customerPhone,
    );

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CustomerHistorySheet(
        customerName: _currentFunction.customerName,
        customerPhone: _currentFunction.customerPhone,
        customerEvents: history,
      ),
    );
  }

  Future<void> _showStatusDialog() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: _surface,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: const Text(
                'Update event status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              content: SizedBox(
                width: 340,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _statuses.length,
                  separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: _border),
                  itemBuilder: (_, index) {
                    final status = _statuses[index];
                    final isCurrent =
                        _currentFunction.status == status;

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        context.tr('status_$status'),
                        style: TextStyle(
                          fontSize: 14,
                          color: _textPrimary,
                          fontWeight: isCurrent
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                      trailing: isCurrent
                          ? const Icon(
                        Icons.check_circle_rounded,
                        color: _accent,
                        size: 20,
                      )
                          : null,
                      onTap: _isUpdatingStatus
                          ? null
                          : () async {
                        if (isCurrent) {
                          Navigator.pop(dialogContext);
                          return;
                        }

                        setDialogState(() {
                          _isUpdatingStatus = true;
                        });

                        try {
                          await context
                              .read<FunctionsViewModel>()
                              .updateStatus(
                            _currentFunction.companyId,
                            _currentFunction.id,
                            status,
                          );

                          if (!mounted) return;

                          setState(() {
                            _currentFunction =
                                _currentFunction.copyWith(
                                  status: status,
                                );
                          });

                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }
                        } catch (_) {
                          if (dialogContext.mounted) {
                            setDialogState(() {
                              _isUpdatingStatus = false;
                            });
                          }

                          if (mounted && context.mounted) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Unable to update status. Please try again.',
                                ),
                              ),
                            );
                          }
                        }
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: _isUpdatingStatus
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _openMakeOrEditList() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MakeMaterialListScreen(
          initialEventId: _currentFunction.id,
        ),
      ),
    );

    if (result == true && mounted) {
      await _loadMaterials();
    }
  }

  void _viewPdf() {
    final authVM = context.read<AuthCompanyViewModel>();
    final company = authVM.activeCompany;

    if (company == null) return;

    PdfGeneratorService.printOrPreviewMaterialPdf(
      company: company,
      function: _currentFunction,
      materials: _materials,
      langCode: authVM.currentLanguage,
    );
  }

  void _shareOnWhatsApp() {
    final authVM = context.read<AuthCompanyViewModel>();
    final company = authVM.activeCompany;

    if (company == null) return;

    PdfGeneratorService.shareMaterialPdf(
      company: company,
      function: _currentFunction,
      materials: _materials,
      langCode: authVM.currentLanguage,
    );
  }

  void _openWhatsAppChat() {
    PdfGeneratorService.launchWhatsAppChat(
      phone: _currentFunction.customerPhone,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthCompanyViewModel>();
    final langCode = authVM.currentLanguage;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _surface,
        foregroundColor: _textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        title: const Text(
          'Event Details',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            color: _textPrimary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: context.tr('customer_history'),
            onPressed: _showCustomerHistory,
            icon: const Icon(Icons.history_rounded, color: _accent, size: 22),
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
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 36),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Event & Guests Overview Card (Unified 3D Card)
                  // _buildSectionHeading(
                  //   'Event & Guest Overview',
                  //   subtitle: 'Function schedule, venue, and guest requirements',
                  // ),
                  const SizedBox(height: 10),
                  _buildEventOverviewCard(),
                  const SizedBox(height: 16),

                  // Payment details are grouped directly after the event schedule.
                  // _buildSectionHeading(
                  //   'Payment Overview',
                  //   subtitle: 'Quotation, advance received, and remaining balance',
                  // ),
                  const SizedBox(height: 10),
                  _buildFinancialCard(),
                  const SizedBox(height: 16),

                  // 3. Customer Information
                  // _buildSectionHeading(
                  //   'Customer Information',
                  //   subtitle: 'Contact details and booking communication',
                  // ),
                  const SizedBox(height: 10),
                  _buildCustomerCard(),
                  const SizedBox(height: 16),

                  // 4. Dishes to Cook
                  if (_currentFunction.dishes.isNotEmpty) ...[
                    _buildSectionHeading(
                      context.tr('items_to_cook'),
                      subtitle: '${_currentFunction.dishes.length} dishes included in this menu',
                    ),
                    const SizedBox(height: 10),
                    _buildDishesCard(),
                    const SizedBox(height: 16),
                  ],

                  // 5. Material List & PDF
                  _buildSectionHeading(
                    context.tr('material_list_title'),
                    subtitle: '',
        // Material calculation, PDF preview, and list editing
                    trailing: _materials.isNotEmpty && !_isLoadingMaterials
                        ? _buildCountBadge(_materials.length)
                        : null,
                  ),
                  const SizedBox(height: 10),
                  _buildMaterialsCard(langCode),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventOverviewCard() {
    return _SectionCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  _currentFunction.eventName.trim().isEmpty ? 'Untitled Event' : _currentFunction.eventName,
                  style: const TextStyle(
                    fontSize: 20,
                    height: 1.25,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: _textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: _showStatusDialog,
                borderRadius: BorderRadius.circular(8),
                child: StatusBadge(status: _currentFunction.status),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: _border),
          const SizedBox(height: 14),
          _DetailRow(
            icon: Icons.calendar_today_rounded,
            label: 'Date & Time',
            value: '${_currentFunction.eventDate}  ·  ${_currentFunction.eventTime.trim().isNotEmpty ? _currentFunction.eventTime : "Full Day"}',
          ),
          const SizedBox(height: 10),
          _DetailRow(
            icon: Icons.location_on_rounded,
            label: 'Venue',
            value: _currentFunction.venue.trim().isEmpty ? 'Not specified' : _currentFunction.venue,
          ),
          const SizedBox(height: 14),

          // Clean Guest and Service Row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: _background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.people_alt_rounded, size: 18, color: _textSecondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_currentFunction.guestCount} Guests',
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: _accent,
                              ),
                            ),
                            Text(
                              'Cook for ${_currentFunction.guestCount}',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                                color: _textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _border, width: 0.8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.room_service_rounded, size: 18, color: _textSecondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentFunction.serviceStyle.trim().isNotEmpty
                                  ? _currentFunction.serviceStyle
                                  : 'Standard',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Text(
                              'Service Style',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                                color: _textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Change Status Pill Button
          InkWell(
            onTap: _showStatusDialog,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: _background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _border, width: 0.8),
              ),
              child: Row(
                children: [
                  Icon(
                    _isUpcoming ? Icons.event_available_rounded : Icons.event_note_rounded,
                    size: 15,
                    color: _accent,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    _isUpcoming ? 'Upcoming Event Schedule' : 'Previous Archived Event',
                    style: const TextStyle(fontSize: 12, color: _accent, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  const Icon(Icons.edit_note_rounded, size: 16, color: _textSecondary),
                  const SizedBox(width: 4),
                  const Text(
                    'Change Status',
                    style: TextStyle(fontSize: 11.5, color: _textSecondary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard() {
    return _SectionCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  _customerInitial,
                  style: const TextStyle(
                    color: _accent,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentFunction.customerName.trim().isNotEmpty
                          ? _currentFunction.customerName
                          : 'Customer Name Not Specified',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _currentFunction.customerPhone.trim().isNotEmpty
                          ? _currentFunction.customerPhone
                          : 'No Phone Provided',
                      style: const TextStyle(
                        fontSize: 13,
                        color: _textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (_currentFunction.customerPhone.isNotEmpty) ...[
                // Themed Call Button (Navy)
                Container(
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: _accent.withValues(alpha: 0.18), width: 1),
                  ),
                  child: IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(7),
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.phone_rounded, color: _accent, size: 17),
                    tooltip: 'Call ${_currentFunction.customerName}',
                    onPressed: () => PdfGeneratorService.launchPhoneCall(phone: _currentFunction.customerPhone),
                  ),
                ),
                const SizedBox(width: 6),
                // Themed Message Button (Navy - NO GREEN)
                Container(
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: _accent.withValues(alpha: 0.18), width: 1),
                  ),
                  child: IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(7),
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.chat_bubble_rounded, color: _accent, size: 17),
                    tooltip: 'Message ${_currentFunction.customerName}',
                    onPressed: _openWhatsAppChat,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: _border),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: _showCustomerHistory,
              style: TextButton.styleFrom(
                foregroundColor: _accent,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              ),
              icon: const Icon(Icons.history_rounded, size: 18),
              label: Text(
                context.tr('customer_history'),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialCard() {
    final quotation = _currentFunction.quotationAmount;
    final advance = _currentFunction.advancePaid;
    final balance = _currentFunction.balanceDue;

    return _SectionCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          _FinancialRow(
            label: context.tr('quotation_amount'),
            value: _formatMoney(quotation),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: _border),
          const SizedBox(height: 14),
          _FinancialRow(
            label: context.tr('advance_received'),
            value: _formatMoney(advance),
            valueColor: _accent,
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: _border),
          const SizedBox(height: 14),
          _FinancialRow(
            label: context.tr('balance_payable'),
            value: _formatMoney(balance),
            valueColor: balance > 0 ? _danger : _accent,
            emphasize: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDishesCard() {
    return _SectionCard(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _currentFunction.dishes.map((dish) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
            decoration: BoxDecoration(
              color: _background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _border, width: 0.8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.restaurant_rounded, size: 14, color: _accent),
                const SizedBox(width: 7),
                Text(
                  dish.dishName,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: _textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // Material List & PDF Actions Card (NO huge raw ingredients list)
  Widget _buildMaterialsCard(String langCode) {
    if (_isLoadingMaterials) {
      return const _SectionCard(
        padding: EdgeInsets.all(32),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: _accent),
          ),
        ),
      );
    }

    if (_materials.isEmpty) {
      return _SectionCard(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _accent.withValues(alpha: 0.18), width: 1),
              ),
              child: const Icon(Icons.inventory_2_outlined, size: 24, color: _accent),
            ),
            const SizedBox(height: 12),
            Text(
              context.tr('no_material_list_yet'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _textSecondary,
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(
                  context.tr('make_material_list_btn'),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                onPressed: _openMakeOrEditList,
              ),
            ),
          ],
        ),
      );
    }

    return _SectionCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(Icons.picture_as_pdf_rounded, color: _accent, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_materials.length} Materials Generated',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Recipe calculations and material quantities ready',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: _textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: _border),
          const SizedBox(height: 16),

          // Primary Actions: Watch PDF & Share PDF
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _viewPdf,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.picture_as_pdf_rounded, size: 17),
                  label: const Text('Watch PDF', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _shareOnWhatsApp,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _accent,
                    side: BorderSide(color: _accent.withValues(alpha: 0.3), width: 1.2),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.share_rounded, size: 17),
                  label: const Text('Share PDF', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Edit Material List button
          if (_isUpcoming)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _openMakeOrEditList,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _accent,
                  backgroundColor: _accent.withValues(alpha: 0.04),
                  side: const BorderSide(color: _border, width: 1.2),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.edit_note_rounded, size: 18),
                label: Text(
                  context.tr('edit_material_list'),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: _background,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: _border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_outline_rounded, size: 15, color: _textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.tr('only_upcoming_editable'),
                      style: const TextStyle(fontSize: 11.5, color: _textSecondary),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeading(
      String title, {
        String? subtitle,
        Widget? trailing,
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
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.15,
                  color: _textPrimary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11.5, color: _textSecondary),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing,
        ],
      ],
    );
  }

  Widget _buildCountBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F8),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        '$count Items',
        style: const TextStyle(color: _accent, fontSize: 11, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _SectionCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: _FunctionDetailScreenState._surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _FunctionDetailScreenState._border,
          width: 0.8,
        ),
      ),
      child: child,
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 17,
          color: _FunctionDetailScreenState._textSecondary,
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 88,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: _FunctionDetailScreenState._textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.4,
              fontWeight: FontWeight.w600,
              color: _FunctionDetailScreenState._textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _FinancialRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool emphasize;

  const _FinancialRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: emphasize
                  ? _FunctionDetailScreenState._textPrimary
                  : _FunctionDetailScreenState._textSecondary,
              fontWeight: emphasize
                  ? FontWeight.w700
                  : FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: emphasize ? 17 : 14,
              color: valueColor ??
                  _FunctionDetailScreenState._textPrimary,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ],
    );
  }
}