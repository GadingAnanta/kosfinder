import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/providers/auth_provider.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/repositories/auth_repository.dart';
import 'package:kosfinder/repositories/kos_repository.dart';
import 'package:kosfinder/screens/kos_form_page.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class FormKosDataSource implements KosDataSource, KosWriteDataSource {
  final List<Map<String, dynamic>> rows;
  Map<String, dynamic>? inserted;

  FormKosDataSource()
    : rows = [
        {
          'id': 'k1',
          'owner_id': 'owner-1',
          'nama': 'Kos Lama',
          'area': 'Singaraja',
          'harga': 900000,
          'fasilitas': 'WiFi',
          'jumlah_kamar': 1,
          'created_at': '2026-11-21T00:00:00Z',
        },
      ];

  @override
  Future<List<Map<String, dynamic>>> fetchRows() async => rows;

  @override
  Future<void> insertKos(Map<String, dynamic> row) async {
    inserted = row;
    rows.add({
      ...row,
      'id': 'k2',
      'created_at': '2026-11-22T00:00:00Z',
    });
  }
}

class FormAuthDataSource implements AuthDataSource {
  const FormAuthDataSource({this.signedIn = true});

  final bool signedIn;

  @override
  AuthSession? get currentSession => signedIn
      ? const AuthSession(userId: 'owner-1', email: 'owner@example.com')
      : null;

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

Finder _field(String label) {
  return find.byWidgetPredicate(
    (widget) => widget is TextField && widget.decoration?.labelText == label,
  );
}

Widget _makePage(FormKosDataSource source, {bool signedIn = true}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<KosProvider>(
        create: (_) => KosProvider(repository: KosRepository(source: source, writeSource: source)),
      ),
      ChangeNotifierProvider<AuthProvider>(
        create: (_) => AuthProvider(
          repository: AuthRepository(
            source: FormAuthDataSource(signedIn: signedIn),
          ),
        ),
      ),
    ],
    child: const MaterialApp(home: KosFormPage()),
  );
}

void main() {
  test('repository createKos mengirim owner_id dan harga angka', () async {
    final source = FormKosDataSource();
    final repository = KosRepository(source: source, writeSource: source);

    await repository.createKos(
      ownerId: 'owner-1',
      nama: 'Kos Baru',
      area: 'Singaraja',
      harga: 1200000,
      fasilitas: 'WiFi',
      jumlahKamar: 3,
    );

    expect(source.inserted, isNotNull);
    expect(source.inserted!['owner_id'], 'owner-1');
    expect(source.inserted!['harga'], 1200000);
  });

  test('provider createKos menyimpan lalu memuat ulang daftar', () async {
    final source = FormKosDataSource();
    final provider = KosProvider(repository: KosRepository(source: source, writeSource: source));

    final ok = await provider.createKos(
      ownerId: 'owner-1',
      nama: 'Kos Baru',
      area: 'Singaraja',
      harga: 1200000,
      fasilitas: 'WiFi',
      jumlahKamar: 3,
    );

    expect(ok, isTrue);
    expect(provider.items.any((kos) => kos.nama == 'Kos Baru'), isTrue);
    expect(provider.isSaving, isFalse);
  });

  testWidgets('harga bukan angka ditolak', (WidgetTester tester) async {
    final source = FormKosDataSource();
    await tester.pumpWidget(_makePage(source));

    await tester.enterText(_field('Nama'), 'Kos Salah');
    await tester.enterText(_field('Area'), 'Singaraja');
    await tester.enterText(_field('Harga'), 'abc');
    await tester.enterText(_field('Jumlah kamar'), '2');
    await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
    await tester.pumpAndSettle();

    expect(find.text('Harga harus angka.'), findsOneWidget);
    expect(source.inserted, isNull);
  });

  testWidgets('pemilik login bisa menyimpan kos baru', (
    WidgetTester tester,
  ) async {
    final source = FormKosDataSource();
    await tester.pumpWidget(_makePage(source));

    await tester.enterText(_field('Nama'), 'Kos Baru');
    await tester.enterText(_field('Area'), 'Singaraja');
    await tester.enterText(_field('Harga'), '2.000.000');
    await tester.enterText(_field('Fasilitas'), 'WiFi, AC');
    await tester.enterText(_field('Jumlah kamar'), '3');
    await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
    await tester.pumpAndSettle();

    expect(source.inserted, isNotNull);
    expect(source.inserted!['owner_id'], 'owner-1');
    expect(source.inserted!['harga'], 2000000);
    expect(source.inserted!['jumlah_kamar'], 3);
  });
}
