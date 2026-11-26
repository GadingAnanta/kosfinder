import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/app.dart';

void main() {
  testWidgets('fondasi aplikasi tampil tanpa Supabase aktif', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const KosFinderApp());

    expect(find.text('KosFinder'), findsWidgets);
    expect(
      find.text('Fondasi Supabase dan model Kos sudah siap.'),
      findsOneWidget,
    );
    expect(
      find.text('Mode: Supabase belum dikonfigurasi'),
      findsOneWidget,
    );
  });
}
