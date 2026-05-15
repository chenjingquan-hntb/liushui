import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../shared/models/extracted_data.dart';
import 'providers/parser_providers.dart';

class BillConfirmTile extends ConsumerWidget {
  final String entryId;
  final ExtractedBillModel bill;
  final int index;

  const BillConfirmTile({
    super.key,
    required this.entryId,
    required this.bill,
    required this.index,
  });

  IconData _categoryIcon(String category) {
    const icons = {
      '餐饮': Icons.restaurant,
      '交通': Icons.directions_car,
      '购物': Icons.shopping_bag,
      '居住': Icons.home,
      '娱乐': Icons.movie,
      '医疗': Icons.local_hospital,
      '收入': Icons.trending_up,
      '其他': Icons.more_horiz,
    };
    return icons[category] ?? Icons.more_horiz;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final color = AppColors.categoryColor(bill.category) ??
        theme.colorScheme.primary;
    final isIncome = bill.isIncome;
    final amountColor = isIncome ? AppColors.income : AppColors.expense;
    final prefix = isIncome ? '+' : '-';

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(_categoryIcon(bill.category), color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bill.rawSegment,
                    style: theme.textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _CategoryDropdown(
                        category: bill.category,
                        onChanged: (cat) {
                          ref
                              .read(pendingBillsProvider.notifier)
                              .updateCategory(index, cat);
                        },
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        avatar: Icon(
                          Icons.auto_awesome,
                          size: 12,
                          color: color,
                        ),
                        label: Text(
                          '${(bill.confidence * 100).round()}%',
                          style: TextStyle(fontSize: 11, color: color),
                        ),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        backgroundColor: color.withOpacity(0.08),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              '$prefix${MoneyFormatter.format(bill.parsedValue)}',
              style: theme.textTheme.titleSmall?.copyWith(
                color: amountColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.check_circle_outline,
                      color: AppColors.confirmed),
                  onPressed: () {
                    ref
                        .read(pendingBillsProvider.notifier)
                        .confirmBill(entryId, index);
                  },
                  tooltip: '确认',
                  iconSize: 22,
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: const Icon(Icons.close,
                      color: AppColors.rejected),
                  onPressed: () {
                    ref
                        .read(pendingBillsProvider.notifier)
                        .rejectBill(entryId, index);
                  },
                  tooltip: '驳回',
                  iconSize: 20,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  final String category;
  final ValueChanged<String> onChanged;

  const _CategoryDropdown({
    required this.category,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      initialValue: category,
      onSelected: onChanged,
      offset: const Offset(0, 30),
      child: Chip(
        label: Text(category, style: const TextStyle(fontSize: 11)),
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        deleteIcon: const Icon(Icons.arrow_drop_down, size: 16),
        onDeleted: () {},
      ),
      itemBuilder: (context) {
        return AppConstants.billCategories.map((cat) {
          return PopupMenuItem<String>(
            value: cat,
            child: Text(cat),
          );
        }).toList();
      },
    );
  }
}
