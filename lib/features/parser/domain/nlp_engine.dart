import 'bill_rule.dart';
import '../../../shared/models/extracted_data.dart';

class NlpEngine {
  final List<BillRule> _rules;

  NlpEngine() : _rules = _buildRuleSet();

  static List<BillRule> _buildRuleSet() {
    return [
      BillRule(
        name: 'explicit_expense_yuan',
        pattern: RegExp(
          r'(?:花了|用了|消费|支出|付了|转账|发了|'
          r'买了|吃了|喝了|打车|外卖|快递|红包)'
          r'(?P<amount>\d+(?:\.\d{1,2})?)\s*(?:元|块|块钱|元钱)',
        ),
        defaultCategory: '其他',
        baseConfidence: 0.95,
        useCategoryMapper: true,
      ),
      BillRule(
        name: 'food_keyword_yuan',
        pattern: RegExp(
          r'(?:午饭|午餐|晚饭|晚餐|早饭|早餐|咖啡|奶茶|外卖|'
          r'烧烤|火锅|零食|水果|买菜|食堂|餐厅|饭)'
          r'(?P<amount>\d+(?:\.\d{1,2})?)\s*(?:元|块|块钱|元钱)',
        ),
        defaultCategory: '餐饮',
        baseConfidence: 0.90,
      ),
      BillRule(
        name: 'transport_keyword_yuan',
        pattern: RegExp(
          r'(?:打车|地铁|公交|高铁|火车|机票|加油|停车|'
          r'共享单车|滴滴|出租车|拼车|骑行)'
          r'(?P<amount>\d+(?:\.\d{1,2})?)\s*(?:元|块|块钱|元钱)',
        ),
        defaultCategory: '交通',
        baseConfidence: 0.90,
      ),
      BillRule(
        name: 'shopping_keyword_yuan',
        pattern: RegExp(
          r'(?:下单|淘宝|京东|拼多多|网购|'
          r'衣服|鞋子|日用品|化妆品|护肤品)'
          r'(?P<amount>\d+(?:\.\d{1,2})?)\s*(?:元|块|块钱|元钱)',
        ),
        defaultCategory: '购物',
        baseConfidence: 0.90,
      ),
      BillRule(
        name: 'bare_amount_yuan',
        pattern: RegExp(
          r'(?<!\w)(?P<amount>\d+(?:\.\d{1,2})?)\s*(?:元|块|块钱|元钱)',
        ),
        defaultCategory: '其他',
        baseConfidence: 0.70,
        useCategoryMapper: true,
      ),
      BillRule(
        name: 'income_keyword_yuan',
        pattern: RegExp(
          r'(?:收入|到账|收到|报销|返还|退款|'
          r'工资|奖金|红包.*收到|转账.*收到|兼职|副业)'
          r'(?P<amount>\d+(?:\.\d{1,2})?)\s*(?:元|块|块钱|元钱)',
        ),
        defaultCategory: '收入',
        baseConfidence: 0.90,
      ),
    ];
  }

  List<ExtractedBillModel> parse(String text) {
    if (text.trim().isEmpty) return [];

    final allMatches = <BillMatch>[];

    for (final rule in _rules) {
      final ruleMatches = rule.apply(text);
      allMatches.addAll(ruleMatches);
    }

    _deduplicate(allMatches);

    return allMatches
        .map((m) => ExtractedBillModel(
              rawSegment: m.rawSegment.trim(),
              parsedValue: m.parsedValue,
              unit: m.unit,
              category: m.category,
              confidence: m.confidence,
            ))
        .toList();
  }

  void _deduplicate(List<BillMatch> matches) {
    matches.sort((a, b) {
      final startCmp = a.startIndex.compareTo(b.startIndex);
      if (startCmp != 0) return startCmp;
      final confCmp = b.confidence.compareTo(a.confidence);
      if (confCmp != 0) return confCmp;
      return (b.endIndex - b.startIndex)
          .compareTo(a.endIndex - a.startIndex);
    });

    final result = <BillMatch>[];
    for (final match in matches) {
      if (result.any((kept) =>
          match.startIndex < kept.endIndex &&
          match.endIndex > kept.startIndex)) {
        continue;
      }
      result.add(match);
    }
    matches
      ..clear()
      ..addAll(result);
  }
}
