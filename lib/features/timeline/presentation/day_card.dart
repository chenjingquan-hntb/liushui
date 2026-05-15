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
        dayGroup.entries.map((e) => e.rawText).join('\n');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 日期头部
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

            // 流水账文本
            FoldableText(
              text: allText,
              maxLines: 3,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),

            // 账单标签行
            if (dayGroup.confirmedBills.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: dayGroup.confirmedBills.map((bill) {
                  final color = AppColors.categoryColor(bill.category) ??
                      theme.colorScheme.primary;
                  final prefix = bill.category == '收入' ? '+' : '-';
                  return Chip(
                    avatar: Icon(
                      _categoryIcon(bill.category),
                      size: 16,
                      color: color,
                    ),
                    label: Text(
                      '$prefix${MoneyFormatter.format(bill.parsedValue)}',
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

            // 图片缩略图占位
            if (dayGroup.entries.any((e) => e.imagesJson != '[]')) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.image,
                      size: 16, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    '含图片附件',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
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
