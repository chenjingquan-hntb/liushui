import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ConfirmChip extends StatelessWidget {
  final double confidence;
  final bool isConfirmed;
  final bool? isRejected;

  const ConfirmChip({
    super.key,
    required this.confidence,
    this.isConfirmed = false,
    this.isRejected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isRejected == true) {
      return Chip(
        avatar: const Icon(Icons.close, size: 16, color: AppColors.rejected),
        label: const Text('已驳回',
            style: TextStyle(fontSize: 12, color: AppColors.rejected)),
        visualDensity: VisualDensity.compact,
        backgroundColor: AppColors.rejected.withOpacity(0.1),
      );
    }

    if (isConfirmed) {
      return Chip(
        avatar:
            const Icon(Icons.check, size: 16, color: AppColors.confirmed),
        label: const Text('已确认',
            style: TextStyle(fontSize: 12, color: AppColors.confirmed)),
        visualDensity: VisualDensity.compact,
        backgroundColor: AppColors.confirmed.withOpacity(0.1),
      );
    }

    final confPercent = (confidence * 100).round();
    final color = confPercent >= 90
        ? AppColors.confirmed
        : confPercent >= 70
            ? AppColors.warning
            : AppColors.expense;

    return Chip(
      avatar: Icon(Icons.auto_awesome, size: 14, color: color),
      label: Text('$confPercent%',
          style: TextStyle(fontSize: 12, color: color)),
      visualDensity: VisualDensity.compact,
      backgroundColor: color.withOpacity(0.1),
    );
  }
}
