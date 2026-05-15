import 'package:flutter/material.dart';

class QuickActionBar extends StatelessWidget {
  final VoidCallback onInsertTime;
  final VoidCallback onInsertLocation;
  final VoidCallback onPickImage;
  final VoidCallback onComplete;

  const QuickActionBar({
    super.key,
    required this.onInsertTime,
    required this.onInsertLocation,
    required this.onPickImage,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          _ActionChip(
            icon: Icons.schedule,
            label: '时间',
            onTap: onInsertTime,
          ),
          const SizedBox(width: 8),
          _ActionChip(
            icon: Icons.location_on_outlined,
            label: '位置',
            onTap: onInsertLocation,
          ),
          const SizedBox(width: 8),
          _ActionChip(
            icon: Icons.photo_camera_outlined,
            label: '图片',
            onTap: onPickImage,
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: onComplete,
            icon: const Icon(Icons.check, size: 18),
            label: const Text('完成'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
    );
  }
}
