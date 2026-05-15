import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const MaterialColor seed = Colors.teal;

  // 语义色
  static const Color expense = Color(0xFFE53935);
  static const Color income = Color(0xFF43A047);
  static const Color warning = Color(0xFFFFA726);
  static const Color confirmed = Color(0xFF66BB6A);
  static const Color rejected = Color(0xFFEF5350);

  // 分类色
  static const Map<String, Color> categoryColors = {
    '餐饮': Color(0xFFFF7043),
    '交通': Color(0xFF42A5F5),
    '购物': Color(0xFFAB47BC),
    '居住': Color(0xFF8D6E63),
    '娱乐': Color(0xFFFFCA28),
    '医疗': Color(0xFFEF5350),
    '收入': Color(0xFF66BB6A),
    '其他': Color(0xFF90A4AE),
  };

  static Color? categoryColor(String category) => categoryColors[category];
}
