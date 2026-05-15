import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'draft_indicator.dart';
import 'input_area.dart';
import 'quick_action_bar.dart';
import 'providers/entry_providers.dart';
import '../../parser/presentation/extracted_bills_sheet.dart';
import '../../parser/presentation/providers/parser_providers.dart';

class EntryPage extends ConsumerStatefulWidget {
  const EntryPage({super.key});

  @override
  ConsumerState<EntryPage> createState() => _EntryPageState();
}

class _EntryPageState extends ConsumerState<EntryPage> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // 自动聚焦输入框
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _insertTime() {
    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} ';
    ref.read(inputTextProvider.notifier).appendText(timeStr);
  }

  void _insertLocation() {
    // MVP: 暂不实现实际定位，仅插入占位符
    ref.read(inputTextProvider.notifier).appendText('[位置] ');
  }

  void _pickImage() {
    // MVP: 暂不实现图片选择
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('图片功能将在后续版本实现')),
    );
  }

  Future<void> _onComplete() async {
    final text = ref.read(inputTextProvider);
    if (text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先输入内容')),
      );
      return;
    }

    final result =
        await ref.read(draftManagerProvider.notifier).archiveEntry();
    ref.read(inputTextProvider.notifier).clear();

    if (result.bills.isNotEmpty) {
      if (!mounted) return;
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => ExtractedBillsSheet(
          entryId: result.entryId,
          bills: result.bills,
        ),
      );
    }

    if (!mounted) return;
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        // 返回时自动归档
        await _onComplete();
        if (context.mounted) {
          context.go('/');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('流水账'),
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_month_outlined),
              onPressed: () => context.push('/timeline'),
              tooltip: '时间轴',
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => context.push('/settings'),
              tooltip: '设置',
            ),
          ],
        ),
        body: Column(
          children: [
            DraftIndicator(),
            InputArea(focusNode: _focusNode),
            QuickActionBar(
              onInsertTime: _insertTime,
              onInsertLocation: _insertLocation,
              onPickImage: _pickImage,
              onComplete: _onComplete,
            ),
          ],
        ),
      ),
    );
  }
}
