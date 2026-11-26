import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/app.dart';
import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/screens/about_page.dart';
import 'package:kosfinder/screens/kos_detail_page.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('daftar kos tampil tanpa Supabase aktif', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const KosFinderApp());
    await tester.pumpAndSettle();

    expect(find.text('Daftar Kos'), findsOneWidget);
    expect(find.text('Mode: Supabase belum dikonfigurasi'), findsOneWidget);
    expect(find.text('Belum ada kos yang tersedia'), findsOneWidget);
  });

  testWidgets('About menampilkan NIM dan Nama', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AboutPage()));

    expect(find.text(AboutPage.identity), findsOneWidget);
  });

  testWidgets('detail kos penuh menampilkan status Penuh', (
    WidgetTester tester,
  ) async {
    const kos = Kos(
      id: 'k1',
      ownerId: 'owner-1',
      nama: 'Kos Penuh',
      area: 'Singaraja',
      harga: 900000,
      fasilitas: 'WiFi',
      jumlahKamar: 0,
    );

    await tester.pumpWidget(
      const MaterialApp(home: KosDetailPage(kos: kos)),
    );

    expect(find.text('Penuh'), findsOneWidget);
    expect(find.text('Rp900000'), findsOneWidget);
  });
}
