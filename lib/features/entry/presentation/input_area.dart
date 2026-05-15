import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/entry_providers.dart';

class InputArea extends ConsumerWidget {
  final FocusNode focusNode;

  const InputArea({super.key, required this.focusNode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(inputTextProvider);
    final theme = Theme.of(context);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: TextField(
          focusNode: focusNode,
          controller: _TextEditingControllerAdapter(
            text: text,
            onChanged: (value) {
              ref.read(inputTextProvider.notifier).set(value);
            },
          ),
          maxLines: null,
          expands: true,
          textAlignVertical: TextAlignVertical.top,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.6,
          ),
          decoration: InputDecoration(
            hintText: '记一笔...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest,
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ),
    );
  }
}

/// Adapter to bridge TextEditingController with Riverpod state
class _TextEditingControllerAdapter extends TextEditingController {
  final ValueChanged<String> onChanged;

  _TextEditingControllerAdapter({
    required String text,
    required this.onChanged,
  }) : super(text: text);

  @override
  set value(TextEditingValue newValue) {
    super.value = newValue;
    onChanged(newValue.text);
  }
}
