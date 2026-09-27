import 'package:flutter_test/flutter_test.dart';
import 'package:lirik_lagu/main.dart';

void main() {
  testWidgets('halaman musik tampil', (WidgetTester tester) async {
    await tester.pumpWidget(const MusicApp());

    expect(find.text('My Music Space'), findsOneWidget);
    expect(find.text('Bertaut'), findsOneWidget);
    expect(find.text('Lirik Lagu'), findsOneWidget);
  });
}
