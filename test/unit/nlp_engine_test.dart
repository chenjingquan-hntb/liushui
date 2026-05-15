import 'package:flutter_test/flutter_test.dart';
import 'package:flowlog/features/parser/domain/nlp_engine.dart';

void main() {
  late NlpEngine engine;

  setUp(() {
    engine = NlpEngine();
  });

  group('NlpEngine — 账单识别', () {
    test('明确支出关键词 + 元', () {
      final results = engine.parse('中午花了25块买咖啡');
      expect(results.length, 1);
      expect(results.first.parsedValue, 25.0);
      expect(results.first.category, '餐饮');
      expect(results.first.confidence, 0.95);
    });

    test('交通关键词 + 元', () {
      final results = engine.parse('晚上打车回家12.5元');
      expect(results.length, 1);
      expect(results.first.parsedValue, 12.5);
      expect(results.first.category, '交通');
    });

    test('餐饮关键词 + 元', () {
      final results = engine.parse('午饭18元，晚饭30块');
      expect(results.length, 2);
      expect(results[0].parsedValue, 18.0);
      expect(results[1].parsedValue, 30.0);
    });

    test('多笔混合支出', () {
      final results = engine.parse('中午花了25块买咖啡，晚上打车回家12.5元');
      expect(results.length, 2);
      expect(results[0].parsedValue, 25.0);
      expect(results[1].parsedValue, 12.5);
    });

    test('纯数字 + 元 (无上下文)', () {
      final results = engine.parse('今天花了50元');
      expect(results.length, 1);
      expect(results.first.parsedValue, 50.0);
      expect(results.first.confidence, greaterThanOrEqualTo(0.70));
    });

    test('收入关键词识别', () {
      final results = engine.parse('收到工资8000元');
      expect(results.length, 1);
      expect(results.first.parsedValue, 8000.0);
      expect(results.first.category, '收入');
    });

    test('报销识别为收入', () {
      final results = engine.parse('报销差旅费200块');
      expect(results.length, 1);
      expect(results.first.parsedValue, 200.0);
      expect(results.first.category, '收入');
    });

    test('购物关键词', () {
      final results = engine.parse('买衣服199元');
      expect(results.length, 1);
      expect(results.first.category, anyOf('购物', '其他'));
    });

    test('重叠匹配去重 — 优先保留高置信度', () {
      // "外卖25元" 会同时匹配 food_keyword (0.90) 和 bare_amount (0.70)
      final results = engine.parse('外卖25元');
      expect(results.length, 1);
      final bill = results.first;
      // 应该保留高置信度的匹配
      expect(bill.confidence, greaterThanOrEqualTo(0.90));
    });

    test('多笔同类型支出', () {
      final results = engine.parse(
          '午饭25元，晚饭30块，咖啡15元，奶茶12块');
      expect(results.length, 4);
    });

    test('带小数的金额', () {
      final results = engine.parse('加油199.99元');
      expect(results.length, 1);
      expect(results.first.parsedValue, 199.99);
    });

    test('无金额文本不匹配', () {
      final results = engine.parse('今天天气真好');
      expect(results.length, 0);
    });

    test('空文本返回空', () {
      final results = engine.parse('');
      expect(results.length, 0);
    });

    test('仅空白字符返回空', () {
      final results = engine.parse('   \n  ');
      expect(results.length, 0);
    });

    test('房租关键词映射到居住', () {
      final results = engine.parse('交房租2500元');
      expect(results.length, 1);
      expect(results.first.parsedValue, 2500.0);
      expect(results.first.category, anyOf('居住', '其他'));
    });

    test('医疗关键词', () {
      final results = engine.parse('医院挂号50元，买药80块');
      expect(results.length, 2);
    });

    test('外卖快递等综合', () {
      final results = engine.parse('点外卖35元，取快递12块');
      expect(results.length, 2);
    });

    test('购物电商关键词', () {
      final results = engine.parse('京东下单299元买个日用品');
      expect(results.length, 1);
      expect(results.first.category, '购物');
    });

    test('退款计入收入', () {
      final results = engine.parse('退款50元');
      expect(results.length, 1);
      expect(results.first.category, '收入');
    });

    test('到账计入收入', () {
      final results = engine.parse('兼职到账500块');
      expect(results.length, 1);
      expect(results.first.category, '收入');
      expect(results.first.parsedValue, 500.0);
    });

    test('复杂流水账综合', () {
      final text = '今天早上坐地铁6块，中午花了35元吃外卖，'
          '下午买了一杯奶茶18元，晚上给车加油200块。'
          '收到好友转账2000块。';
      final results = engine.parse(text);
      expect(results.length, 5);
      final expenseBills = results.where((b) => b.isExpense).toList();
      final incomeBills = results.where((b) => b.isIncome).toList();
      expect(expenseBills.length, 4);
      expect(incomeBills.length, 1);
      expect(incomeBills.first.parsedValue, 2000.0);
    });
  });
}
