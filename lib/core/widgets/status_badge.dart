import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String labelKey;

    switch (status.toLowerCase()) {
      case 'confirmed':
        bg = const Color(0xFFECFDF5);
        fg = const Color(0xFF047857);
        labelKey = 'status_confirmed';
        break;
      case 'cooking':
      case 'cooking in progress':
        bg = const Color(0xFFFFFBEB);
        fg = const Color(0xFFB45309);
        labelKey = 'status_cooking';
        break;
      case 'purchasing':
      case 'purchasing in progress':
        bg = const Color(0xFFEFF6FF);
        fg = const Color(0xFF1D4ED8);
        labelKey = 'status_purchasing';
        break;
      case 'prep_pending':
      case 'preparation pending':
        bg = const Color(0xFFF5F3FF);
        fg = const Color(0xFF6D28D9);
        labelKey = 'status_prep_pending';
        break;
      case 'ready':
      case 'ready for service':
        bg = const Color(0xFFF0FDF4);
        fg = const Color(0xFF15803D);
        labelKey = 'status_ready';
        break;
      case 'completed':
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF475569);
        labelKey = 'status_completed';
        break;
      case 'cancelled':
        bg = const Color(0xFFFEF2F2);
        fg = const Color(0xFFB91C1C);
        labelKey = 'status_cancelled';
        break;
      case 'draft':
      default:
        bg = const Color(0xFFF8FAFC);
        fg = const Color(0xFF64748B);
        labelKey = 'status_draft';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fg.withAlpha(40), width: 1),
      ),
      child: Text(
        context.tr(labelKey),
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}
