class DayGroup {
  final String date;
  final List<Map<String, dynamic>> entries;
  final double totalExpense;
  final double totalIncome;
  final List<Map<String, dynamic>> confirmedBills;

  const DayGroup({
    required this.date,
    required this.entries,
    required this.totalExpense,
    required this.totalIncome,
    required this.confirmedBills,
  });
}

class TimelineService {
  static List<DayGroup> groupByDate(
    List<Map<String, dynamic>> entries,
    Map<String, List<Map<String, dynamic>>> billsByEntryId,
  ) {
    final groups = <String, List<Map<String, dynamic>>>{};
    for (final entry in entries) {
      final date = entry['date'] as String;
      groups.putIfAbsent(date, () => []).add(entry);
    }

    final result = groups.entries.map((e) {
      final dateEntries = e.value;
      double expense = 0;
      double income = 0;
      final allBills = <Map<String, dynamic>>[];

      for (final entry in dateEntries) {
        final entryBills = billsByEntryId[entry['id'] as String] ?? [];
        for (final bill in entryBills) {
          if ((bill['is_confirmed'] as int) == 1) {
            allBills.add(bill);
            final category = bill['category'] as String;
            final value = (bill['parsed_value'] as num).toDouble();
            if (category == '收入') {
              income += value;
            } else {
              expense += value;
            }
          }
        }
      }

      return DayGroup(
        date: e.key,
        entries: dateEntries,
        totalExpense: expense,
        totalIncome: income,
        confirmedBills: allBills,
      );
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return result;
  }

  static String formatDateDisplay(String dateStr) {
    final parts = dateStr.split('-');
    if (parts.length != 3) return dateStr;
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);
    final dt = DateTime(year, month, day);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(year, month, day);
    final diff = today.difference(target).inDays;

    const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

    if (diff == 0) return '今天';
    if (diff == 1) return '昨天';
    if (diff == 2) return '前天';
    return '${month}月${day}日 ${weekdays[dt.weekday - 1]}';
  }
}
