import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/extracted_data.dart';
import 'providers/parser_providers.dart';
import 'bill_confirm_tile.dart';

class ExtractedBillsSheet extends ConsumerWidget {
  final String entryId;
  final List<ExtractedBillModel> bills;

  const ExtractedBillsSheet({
    super.key,
    required this.entryId,
    required this.bills,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.receipt_long,
                    color: theme.colorScheme.primary, size: 24),
                const SizedBox(width: 8),
                Text(
                  '识别到 ${bills.length} 条账单',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    ref.read(pendingBillsProvider.notifier).clear();
                    Navigator.of(context).pop();
                  },
                  child: const Text('全部确认'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: bills.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  return BillConfirmTile(
                    entryId: entryId,
                    bill: bills[index],
                    index: index,
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
