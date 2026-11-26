import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/providers/auth_provider.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/repositories/auth_repository.dart';
import 'package:kosfinder/repositories/kos_repository.dart';
import 'package:kosfinder/screens/kos_form_page.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class UpdateKosDataSource
    implements KosDataSource, KosWriteDataSource, KosUpdateDataSource {
  UpdateKosDataSource()
    : rows = [
        {
          'id': 'k1',
          'owner_id': 'owner-1',
          'nama': 'Kos A',
          'area': 'Singaraja',
          'harga': 900000,
          'fasilitas': 'WiFi',
          'jumlah_kamar': 1,
          'created_at': '2026-11-21T00:00:00Z',
        },
        {
          'id': 'k2',
          'owner_id': 'owner-2',
          'nama': 'Kos B',
          'area': 'Tabanan',
          'harga': 1200000,
          'fasilitas': 'AC',
          'jumlah_kamar': 2,
          'created_at': '2026-11-20T00:00:00Z',
        },
      ];

  final List<Map<String, dynamic>> rows;
  String? updatedId;
  Map<String, dynamic>? updatedRow;

  @override
  Future<List<Map<String, dynamic>>> fetchRows() async => rows;

  @override
  Future<void> insertKos(Map<String, dynamic> row) async {
    rows.add({...row, 'id': 'k3', 'created_at': '2026-11-23T00:00:00Z'});
  }

  @override
  Future<void> updateKos(String id, Map<String, dynamic> row) async {
    updatedId = id;
    updatedRow = Map<String, dynamic>.from(row);
    final index = rows.indexWhere((item) => item['id'] == id);
    if (index != -1) {
      rows[index] = {...rows[index], ...row};
    }
  }
}

class UpdateAuthDataSource implements AuthDataSource {
  const UpdateAuthDataSource(this.userId);

  final String userId;

  @override
  AuthSession? get currentSession =>
      AuthSession(userId: userId, email: '$userId@example.com');

  @override
  Future<AuthSession?> signUp({
    required String email,
    required String password,
  }) async {
    return currentSession;
  }

  @override
  Future<AuthSession?> signInWithPassword({
    required String email,
    required String password,
  }) async {
    return currentSession;
  }

  @override
  Future<void> signOut() async {}
}

Kos _kosA() => const Kos(
  id: 'k1',
  ownerId: 'owner-1',
  nama: 'Kos A',
  area: 'Singaraja',
  harga: 900000,
  fasilitas: 'WiFi',
  jumlahKamar: 1,
);

Finder _field(String label) {
  return find.byWidgetPredicate(
    (widget) => widget is TextField && widget.decoration?.labelText == label,
  );
}

KosProvider _provider(UpdateKosDataSource source) {
  return KosProvider(
    repository: KosRepository(source: source, writeSource: source),
  );
}

Widget _makePage(KosProvider provider, String userId, {Kos? kos}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<KosProvider>.value(value: provider),
      ChangeNotifierProvider<AuthProvider>(
        create: (_) => AuthProvider(
          repository: AuthRepository(source: UpdateAuthDataSource(userId)),
        ),
      ),
    ],
    child: MaterialApp(home: KosFormPage(kos: kos)),
  );
}

int _kamar(UpdateKosDataSource source, String id) =>
    source.rows.firstWhere((row) => row['id'] == id)['jumlah_kamar'] as int;

void main() {
  test('repository updateKos menolak kos pemilik lain', () async {
    final source = UpdateKosDataSource();
    final repository = KosRepository(source: source, writeSource: source);

    await expectLater(
      repository.updateKos(
        id: 'k1',
        ownerId: 'owner-2',
        nama: 'Kos A',
        area: 'Singaraja',
        harga: 900000,
        fasilitas: 'WiFi',
        jumlahKamar: 3,
      ),
      throwsA(
        isA<KosRepositoryException>().having(
          (error) => error.message,
          'message',
          contains('bukan milik'),
        ),
      ),
    );

    expect(source.updatedId, isNull);
    expect(_kamar(source, 'k1'), 1);
  });

  test('provider updateKos menyimpan perubahan dan memuat ulang daftar',
      () async {
    final source = UpdateKosDataSource();
    final provider = _provider(source);
    await provider.loadKos();

    final ok = await provider.updateKos(
      kosId: 'k1',
      ownerId: 'owner-1',
      nama: 'Kos A',
      area: 'Singaraja',
      harga: 900000,
      fasilitas: 'WiFi',
      jumlahKamar: 3,
    );

    expect(ok, isTrue);
    expect(source.updatedId, 'k1');
    expect(source.updatedRow!['jumlah_kamar'], 3);
    expect(
      provider.items.firstWhere((item) => item.id == 'k1').jumlahKamar,
      3,
    );
    expect(provider.isSaving, isFalse);
  });

  testWidgets('form mengisi ulang kos lalu menyimpan jumlah kamar 3', (
    WidgetTester tester,
  ) async {
    final source = UpdateKosDataSource();
    final provider = _provider(source);
    await provider.loadKos();

    await tester.pumpWidget(_makePage(provider, 'owner-1', kos: _kosA()));

    expect(
      tester.widget<TextField>(_field('Nama')).controller!.text,
      'Kos A',
    );
    expect(
      tester.widget<TextField>(_field('Jumlah kamar')).controller!.text,
      '1',
    );

    await tester.enterText(_field('Jumlah kamar'), '3');
    await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
    await tester.pumpAndSettle();

    expect(source.updatedRow!['jumlah_kamar'], 3);
    expect(
      provider.items.firstWhere((item) => item.id == 'k1').jumlahKamar,
      3,
    );
  });

  testWidgets('pemilik lain gagal mengubah kos', (WidgetTester tester) async {
    final source = UpdateKosDataSource();
    final provider = _provider(source);
    await provider.loadKos();

    await tester.pumpWidget(_makePage(provider, 'owner-2', kos: _kosA()));

    await tester.enterText(_field('Jumlah kamar'), '3');
    await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
    await tester.pumpAndSettle();

    expect(find.text('Kos ini bukan milik Anda.'), findsOneWidget);
    expect(source.updatedId, isNull);
    expect(_kamar(source, 'k1'), 1);
  });

  testWidgets('form tanpa argumen bisa memilih kos sendiri untuk diubah', (
    WidgetTester tester,
  ) async {
    final source = UpdateKosDataSource();
    final provider = _provider(source);
    await provider.loadKos();

    await tester.pumpWidget(_makePage(provider, 'owner-1'));
    await tester.tap(find.byType(DropdownButton<String?>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kos A').last);
    await tester.pumpAndSettle();

    expect(
      tester.widget<TextField>(_field('Jumlah kamar')).controller!.text,
      '1',
    );

    await tester.enterText(_field('Jumlah kamar'), '3');
    await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
    await tester.pumpAndSettle();

    expect(source.updatedId, 'k1');
    expect(source.updatedRow!['jumlah_kamar'], 3);
  });
}
