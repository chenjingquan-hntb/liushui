import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../shared/widgets/foldable_text.dart';
import '../domain/timeline_service.dart';

class DayCard extends StatelessWidget {
  final DayGroup dayGroup;

  const DayCard({super.key, required this.dayGroup});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allText =
        dayGroup.entries.map((e) => e['raw_text'] as String).join('\n');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  TimelineService.formatDateDisplay(dayGroup.date),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (dayGroup.totalExpense > 0)
                  Text(
                    '支出 ${MoneyFormatter.format(dayGroup.totalExpense)}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.expense,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (dayGroup.totalIncome > 0) ...[
                  const SizedBox(width: 12),
                  Text(
                    '收入 ${MoneyFormatter.format(dayGroup.totalIncome)}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.income,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            FoldableText(
              text: allText,
              maxLines: 3,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
            if (dayGroup.confirmedBills.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: dayGroup.confirmedBills.map((bill) {
                  final category = bill['category'] as String;
                  final value = (bill['parsed_value'] as num).toDouble();
                  final color = AppColors.categoryColor(category) ??
                      theme.colorScheme.primary;
                  final prefix = category == '收入' ? '+' : '-';
                  return Chip(
                    avatar: Icon(
                      _categoryIcon(category),
                      size: 16,
                      color: color,
                    ),
                    label: Text(
                      '$prefix${MoneyFormatter.format(value)}',
                      style: TextStyle(fontSize: 12, color: color),
                    ),
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    backgroundColor: color.withOpacity(0.08),
                    side: BorderSide.none,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

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
}
