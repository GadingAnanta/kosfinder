import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/repositories/kos_repository.dart';
import 'package:kosfinder/screens/kos_list_page.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class FakeKosDataSource implements KosDataSource {
  const FakeKosDataSource(this.rows);

  final List<Map<String, dynamic>> rows;

  @override
  Future<List<Map<String, dynamic>>> fetchRows() async => rows;
}

List<Map<String, dynamic>> _rows() {
  return [
    {
      'id': 'k1',
      'owner_id': 'owner-1',
      'nama': 'Kos Melati',
      'area': 'Singaraja',
      'harga': 900000,
      'fasilitas': 'WiFi',
      'jumlah_kamar': 2,
      'created_at': '2026-11-21T00:00:00Z',
    },
    {
      'id': 'k2',
      'owner_id': 'owner-1',
      'nama': 'Kos Mawar',
      'area': 'Tabanan',
      'harga': 2500000,
      'fasilitas': 'AC',
      'jumlah_kamar': 0,
      'created_at': '2026-11-20T00:00:00Z',
    },
  ];
}

List<Kos> _items() {
  return const [
    Kos(
      id: 'k1',
      ownerId: 'owner-1',
      nama: 'Kos Melati',
      area: 'Singaraja',
      harga: 900000,
      fasilitas: 'WiFi',
      jumlahKamar: 2,
    ),
    Kos(
      id: 'k2',
      ownerId: 'owner-1',
      nama: 'Kos Mawar',
      area: 'Tabanan',
      harga: 2500000,
      fasilitas: 'AC',
      jumlahKamar: 0,
    ),
  ];
}

void main() {
  test('filterByArea case-insensitive', () {
    final repository = KosRepository(source: const FakeKosDataSource([]));

    final lower = repository.filterByArea(_items(), 'singaraja');
    final upper = repository.filterByArea(_items(), 'Singaraja');

    expect(lower, hasLength(1));
    expect(lower.single.nama, 'Kos Melati');
    expect(upper.map((kos) => kos.nama), lower.map((kos) => kos.nama));
    expect(repository.filterByArea(_items(), '   '), hasLength(2));
  });

  test('provider visibleItems mengikuti query pencarian', () async {
    final provider = KosProvider(
      repository: KosRepository(source: FakeKosDataSource(_rows())),
    );

    await provider.loadKos();
    expect(provider.visibleItems, hasLength(2));

    provider.setSearchQuery('SINGARAJA');
    expect(provider.visibleItems.single.nama, 'Kos Melati');

    provider.clearSearch();
    expect(provider.visibleItems, hasLength(2));
  });

  testWidgets('carian area di UI memfilter daftar', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<KosProvider>(
        create: (_) => KosProvider(
          repository: KosRepository(source: FakeKosDataSource(_rows())),
        ),
        child: const MaterialApp(home: KosListPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kos Melati'), findsOneWidget);
    expect(find.text('Kos Mawar'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'singaraja');
    await tester.pumpAndSettle();

    expect(find.text('Kos Melati'), findsOneWidget);
    expect(find.text('Kos Mawar'), findsNothing);

    await tester.enterText(find.byType(TextField), 'Singaraja');
    await tester.pumpAndSettle();

    expect(find.text('Kos Melati'), findsOneWidget);
  });
}
