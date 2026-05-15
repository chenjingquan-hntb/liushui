import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/empty_state.dart';
import 'providers/timeline_providers.dart';
import 'day_card.dart';
import 'calendar_picker.dart';

class TimelinePage extends ConsumerWidget {
  const TimelinePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dayGroupsAsync = ref.watch(timelineDayGroupsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('时间轴'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: () => _showCalendar(context, ref),
            tooltip: '日历跳转',
          ),
        ],
      ),
      body: dayGroupsAsync.when(
        data: (dayGroups) {
          if (dayGroups.isEmpty) {
            return const EmptyState(
              icon: Icons.edit_note,
              title: '还没有记录',
              subtitle: '返回首页开始写流水账吧',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 32),
            itemCount: dayGroups.length,
            itemBuilder: (context, index) {
              return DayCard(dayGroup: dayGroups[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('加载失败: $error')),
      ),
    );
  }

  void _showCalendar(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (_) => const CalendarPicker(),
    );
  }
}
