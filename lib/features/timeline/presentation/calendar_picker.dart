import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'providers/timeline_providers.dart';

class CalendarPicker extends ConsumerWidget {
  const CalendarPicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final focusedDay = ref.watch(_focusedDayProvider);
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            const SizedBox(height: 12),
            TableCalendar(
              firstDay: DateTime(2020),
              lastDay: DateTime.now().add(const Duration(days: 1)),
              focusedDay: focusedDay,
              selectedDayPredicate: (day) =>
                  isSameDay(selectedDate, day),
              onDaySelected: (selectedDay, focusedDay) {
                ref.read(selectedDateProvider.notifier).select(selectedDay);
                ref.read(_focusedDayProvider.notifier).state = focusedDay;
                Navigator.of(context).pop();
              },
              onPageChanged: (focusedDay) {
                ref.read(_focusedDayProvider.notifier).state = focusedDay;
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                ref.read(selectedDateProvider.notifier).goToToday();
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.today, size: 18),
              label: const Text('回到今天'),
            ),
          ],
        ),
      ),
    );
  }
}

final _focusedDayProvider =
    AutoDisposeNotifierProvider<_FocusedDayNotifier, DateTime>(
  _FocusedDayNotifier.new,
);

class _FocusedDayNotifier extends AutoDisposeNotifier<DateTime> {
  @override
  DateTime build() => DateTime.now();
}
