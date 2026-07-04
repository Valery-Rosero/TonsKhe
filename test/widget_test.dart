import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tons_khe/main.dart';

void main() {
  testWidgets('TonsKheApp builds without throwing', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: TonsKheApp()));
    await tester.pumpAndSettle();
  });
}
