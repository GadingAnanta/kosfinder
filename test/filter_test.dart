import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/providers/auth_provider.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/repositories/auth_repository.dart';
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

class _NoAuthDataSource implements AuthDataSource {
  const _NoAuthDataSource();

  @override
  AuthSession? get currentSession => null;

  @override
  Future<AuthSession?> signUp({
    required String email,
    required String password,
  }) async {
    return null;
  }

  @override
  Future<AuthSession?> signInWithPassword({
    required String email,
    required String password,
  }) async {
    return null;
  }

  @override
  Future<void> signOut() async {}
}

List<Map<String, dynamic>> _rows() {
  return [
    {
      'id': 'k1',
      'owner_id': 'owner-1',
      'nama': 'Kos Murah',
      'area': 'Singaraja',
      'harga': 900000,
      'fasilitas': 'WiFi',
      'jumlah_kamar': 2,
      'created_at': '2026-11-21T00:00:00Z',
    },
    {
      'id': 'k2',
      'owner_id': 'owner-1',
      'nama': 'Kos Mahal',
      'area': 'Singaraja',
      'harga': 2500000,
      'fasilitas': 'AC',
      'jumlah_kamar': 1,
      'created_at': '2026-11-20T00:00:00Z',
    },
  ];
}

Finder _fieldWithLabel(String label) {
  return find.byWidgetPredicate(
    (widget) =>
        widget is TextField && widget.decoration?.labelText == label,
  );
}

void main() {
  test('filterByMaxHarga memakai perbandingan angka', () {
    final repository = KosRepository(source: const FakeKosDataSource([]));
    final items = const [
      Kos(
        id: 'k1',
        ownerId: 'owner-1',
        nama: 'Kos Murah',
        area: 'Singaraja',
        harga: 900000,
        fasilitas: 'WiFi',
        jumlahKamar: 2,
      ),
      Kos(
        id: 'k2',
        ownerId: 'owner-1',
        nama: 'Kos Mahal',
        area: 'Singaraja',
        harga: 2500000,
        fasilitas: 'AC',
        jumlahKamar: 1,
      ),
    ];

    final result = repository.filterByMaxHarga(items, 2000000);

    expect(result, hasLength(1));
    expect(result.single.nama, 'Kos Murah');
    expect(repository.filterByMaxHarga(items, null), hasLength(2));
  });

  test('provider menggabungkan filter area dan harga', () async {
    final provider = KosProvider(
      repository: KosRepository(source: FakeKosDataSource(_rows())),
    );

    await provider.loadKos();
    provider.setSearchQuery('singaraja');
    provider.setMaxPrice('2.000.000');

    expect(provider.maxHarga, 2000000);
    expect(provider.visibleItems, hasLength(1));
    expect(provider.visibleItems.single.nama, 'Kos Murah');

    provider.setMaxPrice('500000');
    expect(provider.visibleItems, isEmpty);
  });

  testWidgets('filter harga di UI menyembunyikan kos mahal', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<KosProvider>(
            create: (_) => KosProvider(
              repository: KosRepository(source: FakeKosDataSource(_rows())),
            ),
          ),
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => AuthProvider(
              repository: AuthRepository(source: const _NoAuthDataSource()),
            ),
          ),
        ],
        child: const MaterialApp(home: KosListPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kos Murah'), findsOneWidget);
    expect(find.text('Kos Mahal'), findsOneWidget);

    await tester.enterText(_fieldWithLabel('Harga maksimum'), '2000000');
    await tester.pumpAndSettle();

    expect(find.text('Kos Murah'), findsOneWidget);
    expect(find.text('Kos Mahal'), findsNothing);

    await tester.enterText(_fieldWithLabel('Harga maksimum'), '500000');
    await tester.pumpAndSettle();

    expect(find.text('Tidak ada kos dengan harga tersebut'), findsOneWidget);
  });
}
