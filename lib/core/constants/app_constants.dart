class AppConstants {
  AppConstants._();

  static const String appName = '流水账';
  static const String appVersion = '0.1.0';
  static const int debounceMs = 2000;
  static const int maxFoldLines = 3;
  static const int maxDraftLength = 5000;

  // 账单分类
  static const List<String> billCategories = [
    '餐饮',
    '交通',
    '购物',
    '居住',
    '娱乐',
    '医疗',
    '收入',
    '其他',
  ];

  // 习惯词库 (v0.2 启用)
  static const List<String> presetHabits = [
    '跑步',
    '冥想',
    '阅读',
    '背单词',
    '健身',
    '瑜伽',
    '写作',
  ];
}
