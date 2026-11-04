import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../app/theme.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../data/models/staff_model.dart';
import '../../data/models/staff_payment_model.dart';
import '../../services/pdf_generator_service.dart';
import '../../viewmodels/staff_viewmodel.dart';

class StaffDetailScreen extends StatefulWidget {
  final StaffModel staff;

  const StaffDetailScreen({super.key, required this.staff});

  @override
  State<StaffDetailScreen> createState() => _StaffDetailScreenState();
}

class _StaffDetailScreenState extends State<StaffDetailScreen> {
  late StaffModel _staff;
  List<StaffPaymentModel> _payments = [];
  bool _isLoadingPayments = true;

  @override
  void initState() {
    super.initState();
    _staff = widget.staff;
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() => _isLoadingPayments = true);
    final staffVM = context.read<StaffViewModel>();
    final payments = await staffVM.getStaffPayments(_staff.companyId, _staff.id);
    if (mounted) {
      setState(() {
        _payments = payments;
        _isLoadingPayments = false;
      });
    }
  }

  void _openAddPaymentDialog() {
    final amountCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String paymentMode = 'upi';
    String paymentDate = DateTime.now().toIso8601String().substring(0, 10);
    String? selectedImagePath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (bottomCtx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(bottomCtx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.tr('add_payment'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(bottomCtx)),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 8),

                    CustomTextField(
                      label: context.tr('payment_amount'),
                      hint: 'e.g. 5000',
                      controller: amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: Icons.currency_rupee,
                    ),
                    const SizedBox(height: 12),

                    // Payment Mode Dropdown
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(context.tr('payment_mode'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                              const SizedBox(height: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppTheme.borderLight),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: paymentMode,
                                    isExpanded: true,
                                    items: const [
                                      DropdownMenuItem(value: 'upi', child: Text('UPI / GooglePay')),
                                      DropdownMenuItem(value: 'cash', child: Text('Cash')),
                                      DropdownMenuItem(value: 'bank_transfer', child: Text('Bank Transfer')),
                                    ],
                                    onChanged: (v) {
                                      if (v != null) setModalState(() => paymentMode = v);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(context.tr('payment_date'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                              const SizedBox(height: 5),
                              InkWell(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2030),
                                  );
                                  if (picked != null) {
                                    setModalState(() {
                                      paymentDate = picked.toIso8601String().substring(0, 10);
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppTheme.borderLight),
                                  ),
                                  child: Text(paymentDate, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      label: 'Note / Purpose',
                      hint: 'e.g. Advance for Shah Wedding',
                      controller: notesCtrl,
                      prefixIcon: Icons.notes_rounded,
                    ),
                    const SizedBox(height: 14),

                    // Screenshot Upload Area
                    Text(
                      context.tr('upload_screenshot'),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    if (selectedImagePath != null)
                      Stack(
                        children: [
                          Container(
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppTheme.borderLight),
                              image: DecorationImage(
                                image: FileImage(File(selectedImagePath!)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 6,
                            right: 6,
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: AppTheme.primaryDark,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.close, color: Colors.white, size: 16),
                                onPressed: () => setModalState(() => selectedImagePath = null),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                              icon: const Icon(Icons.photo_library_outlined, size: 18),
                              label: const Text('Pick Gallery'),
                              onPressed: () async {
                                final picker = ImagePicker();
                                final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                                if (image != null) {
                                  final appDir = await getApplicationDocumentsDirectory();
                                  final savedPath = '${appDir.path}/receipt_${DateTime.now().millisecondsSinceEpoch}.jpg';
                                  await File(image.path).copy(savedPath);
                                  setModalState(() => selectedImagePath = savedPath);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                              icon: const Icon(Icons.camera_alt_outlined, size: 18),
                              label: const Text('Take Photo'),
                              onPressed: () async {
                                final picker = ImagePicker();
                                final image = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                                if (image != null) {
                                  final appDir = await getApplicationDocumentsDirectory();
                                  final savedPath = '${appDir.path}/receipt_${DateTime.now().millisecondsSinceEpoch}.jpg';
                                  await File(image.path).copy(savedPath);
                                  setModalState(() => selectedImagePath = savedPath);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 18),

                    CustomButton(
                      text: context.tr('save'),
                      icon: Icons.check_circle_outline,
                      onPressed: () async {
                        final amt = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                        if (amt <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a valid amount')),
                          );
                          return;
                        }

                        final staffVM = context.read<StaffViewModel>();
                        await staffVM.addStaffPayment(
                          companyId: _staff.companyId,
                          staffId: _staff.id,
                          amount: amt,
                          paymentDate: paymentDate,
                          paymentMode: paymentMode,
                          receiptImagePath: selectedImagePath,
                          notes: notesCtrl.text,
                        );

                        if (bottomCtx.mounted) Navigator.pop(bottomCtx);
                        _loadPayments();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _viewReceiptPhoto(String imagePath) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(File(imagePath), fit: BoxFit.contain),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: CircleAvatar(
                backgroundColor: AppTheme.primaryDark,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final staffVM = context.watch<StaffViewModel>();
    final monthlyEvents = staffVM.monthlyEventsCount;
    final totalPaid = _payments.fold<double>(0.0, (sum, p) => sum + p.amount);

    return Scaffold(
      backgroundColor: AppTheme.surfaceBackground,
      appBar: AppBar(
        title: const Text(
          'Staff Details',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            tooltip: context.tr('delete_staff'),
            onPressed: () {
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
                    'Are you sure you want to delete ${_staff.name}? This will also delete their payment records.',
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
                        final staffVM = context.read<StaffViewModel>();
                        await staffVM.deleteStaff(_staff.companyId, _staff.id);
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${_staff.name} deleted successfully')),
                          );
                        }
                      },
                      child: Text(context.tr('delete'), style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Staff Profile Header Card (3D Tactile Card)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderLight, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.07),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 1.5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: AppTheme.primaryNavy.withValues(alpha: 0.08),
                        child: Text(
                          _staff.name.isNotEmpty ? _staff.name[0].toUpperCase() : 'S',
                          style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: AppTheme.primaryNavy),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _staff.name,
                              style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryNavy.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppTheme.primaryNavy.withValues(alpha: 0.18), width: 0.8),
                              ),
                              child: Text(
                                context.tr('role_${_staff.role}'),
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _staff.phone,
                              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryNavy,
                              backgroundColor: AppTheme.primaryNavy.withValues(alpha: 0.04),
                              side: const BorderSide(color: AppTheme.borderLight, width: 1.2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            icon: const Icon(Icons.phone_rounded, size: 14, color: AppTheme.primaryNavy),
                            label: const Text('Call', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                            onPressed: () => PdfGeneratorService.launchPhoneCall(phone: _staff.phone),
                          ),
                          const SizedBox(width: 6),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryNavy,
                              backgroundColor: AppTheme.primaryNavy.withValues(alpha: 0.04),
                              side: const BorderSide(color: AppTheme.borderLight, width: 1.2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            icon: const Icon(Icons.chat_bubble_rounded, size: 14, color: AppTheme.primaryNavy),
                            label: const Text('Message', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                            onPressed: () => PdfGeneratorService.launchWhatsAppChat(phone: _staff.phone),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: AppTheme.borderLight),
                  const SizedBox(height: 10),
                  // Joining Date Badge
                  Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded, size: 15, color: AppTheme.primaryNavy),
                      const SizedBox(width: 6),
                      Text(
                        '${context.tr('joining_date')}: ',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                      ),
                      Text(
                        _staff.joiningDate,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 2. Monthly Events & Wage Metrics (3D Stat Card)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderLight, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.07),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 1.5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatPill(
                      context.tr('events_this_month'),
                      '$monthlyEvents Events',
                      Icons.event_note_rounded,
                      AppTheme.primaryNavy,
                    ),
                  ),
                  Container(height: 34, width: 1, color: AppTheme.borderLight),
                  Expanded(
                    child: _buildStatPill(
                      _staff.paymentType == 'monthly' ? 'Monthly Pay' : context.tr('daily_wage'),
                      _staff.paymentType == 'monthly'
                          ? '₹${_staff.monthlyPay.toStringAsFixed(0)}'
                          : '₹${_staff.dailyWage.toStringAsFixed(0)}',
                      Icons.payments_outlined,
                      AppTheme.primaryNavy,
                    ),
                  ),
                  Container(height: 34, width: 1, color: AppTheme.borderLight),
                  Expanded(
                    child: _buildStatPill(
                      context.tr('total_paid'),
                      '₹${totalPaid.toStringAsFixed(0)}',
                      Icons.account_balance_wallet_outlined,
                      AppTheme.primaryNavy,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Payment History Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.tr('payment_history'),
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryNavy,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const Icon(Icons.add_rounded, size: 15),
                  label: Text(context.tr('add_payment'), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                  onPressed: _openAddPaymentDialog,
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (_isLoadingPayments)
              const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
            else if (_payments.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderLight, width: 1.1),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 36, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text(
                        context.tr('no_payments_yet'),
                        style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _payments.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx, i) {
                  final pay = _payments[i];
                  final hasImage = pay.receiptImagePath != null && File(pay.receiptImagePath!).existsSync();

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.borderLight, width: 1.1),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryNavy.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.primaryNavy.withValues(alpha: 0.18), width: 0.8),
                          ),
                          child: const Icon(Icons.arrow_upward_rounded, color: AppTheme.primaryNavy, size: 16),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '₹${pay.amount.toStringAsFixed(0)} • ${pay.paymentMode.toUpperCase()}',
                                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${pay.paymentDate} ${pay.notes.isNotEmpty ? "• ${pay.notes}" : ""}',
                                style: const TextStyle(fontSize: 11.5, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        if (hasImage)
                          InkWell(
                            onTap: () => _viewReceiptPhoto(pay.receiptImagePath!),
                            child: Container(
                              height: 44,
                              width: 44,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppTheme.borderLight),
                                image: DecorationImage(
                                  image: FileImage(File(pay.receiptImagePath!)),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatPill(String title, String val, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                title,
                style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(val, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: color)),
        ),
      ],
    );
  }
}
