import 'package:flutter_test/flutter_test.dart';
import 'package:flowlog/app.dart';

void main() {
  testWidgets('App renders entry page', (WidgetTester tester) async {
    await tester.pumpWidget(const FlowLogApp());
    expect(find.text('流水账'), findsOneWidget);
    expect(find.text('记一笔...'), findsOneWidget);
    expect(find.text('完成'), findsOneWidget);
  });
}
