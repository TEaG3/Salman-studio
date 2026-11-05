import 'package:flutter_test/flutter_test.dart';
import 'package:tea_g3_studio/main.dart';

void main() {
  testWidgets('TEa.G3-studio app builds', (tester) async {
    await tester.pumpWidget(const TeaG3StudioApp());
    expect(find.text('TEa.G3-studio'), findsOneWidget);
  });
}
