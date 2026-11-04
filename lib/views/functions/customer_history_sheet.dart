import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../core/localization/app_localizations.dart';
import '../../data/models/function_model.dart';
import '../../services/pdf_generator_service.dart';
import 'function_detail_screen.dart';

class CustomerHistorySheet extends StatelessWidget {
  final String customerName;
  final String customerPhone;
  final List<FunctionModel> customerEvents;

  const CustomerHistorySheet({
    super.key,
    required this.customerName,
    required this.customerPhone,
    required this.customerEvents,
  });

  @override
  Widget build(BuildContext context) {
    final totalSpent = customerEvents.fold<double>(0.0, (sum, e) => sum + e.quotationAmount);
    final totalPax = customerEvents.fold<int>(0, (sum, e) => sum + e.guestCount);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.accentEmerald.withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.history_edu_rounded, color: AppTheme.accentEmerald, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customerName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        customerPhone,
                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (customerPhone.isNotEmpty) ...[
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.phone_rounded, color: AppTheme.primaryNavy, size: 20),
                      tooltip: 'Call $customerName',
                      onPressed: () => PdfGeneratorService.launchPhoneCall(phone: customerPhone),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.chat_bubble_rounded, color: AppTheme.primaryNavy, size: 20),
                      tooltip: 'Message $customerName',
                      onPressed: () => PdfGeneratorService.launchWhatsAppChat(phone: customerPhone),
                    ),
                    const SizedBox(width: 4),
                  ],
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Summary Stats Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(context.tr('total_bookings'), '${customerEvents.length}', Icons.event_available_rounded),
                Container(height: 28, width: 1, color: AppTheme.borderLight),
                _buildStatItem('Total Pax', '$totalPax', Icons.people_outline_rounded),
                Container(height: 28, width: 1, color: AppTheme.borderLight),
                _buildStatItem(context.tr('total_spent'), '₹${totalSpent.toStringAsFixed(0)}', Icons.currency_rupee_rounded),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text(
            '${context.tr('past_bookings_for')} $customerName',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 8),

          // Events List
          Expanded(
            child: customerEvents.isEmpty
                ? Center(
                    child: Text(
                      context.tr('no_data'),
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: customerEvents.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final fn = customerEvents[i];
                      final isUpcoming = fn.eventDate.compareTo(DateTime.now().toIso8601String().substring(0, 10)) >= 0;

                      return InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => FunctionDetailScreen(function: fn)),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.borderLight),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isUpcoming ? AppTheme.accentEmerald.withAlpha(20) : AppTheme.surfaceBackground,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  isUpcoming ? Icons.upcoming_rounded : Icons.history_rounded,
                                  color: isUpcoming ? AppTheme.accentEmerald : AppTheme.textSecondary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      fn.eventName,
                                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${fn.eventDate} • ${fn.guestCount} Pax • ₹${fn.quotationAmount.toStringAsFixed(0)}',
                                      style: const TextStyle(fontSize: 11.5, color: AppTheme.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary, size: 20),
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

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: AppTheme.primaryNavy),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 10.5, color: AppTheme.textSecondary)),
          ],
        ),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppTheme.primaryNavy)),
      ],
    );
  }
}
