import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/entry_providers.dart';

class DraftIndicator extends ConsumerWidget {
  const DraftIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draftState = ref.watch(draftManagerProvider);
    final theme = Theme.of(context);

    if (draftState.lastSavedAt == null) return const SizedBox.shrink();

    final secondsAgo =
        DateTime.now().difference(draftState.lastSavedAt!).inSeconds;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            draftState.isSaving
                ? Icons.sync
                : Icons.cloud_done_outlined,
            size: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            draftState.isSaving ? '保存中...' : '草稿已保存 ${secondsAgo}s 前',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
