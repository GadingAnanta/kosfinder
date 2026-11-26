import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/providers/auth_provider.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/repositories/auth_repository.dart';
import 'package:kosfinder/repositories/kos_repository.dart';
import 'package:kosfinder/screens/kos_list_page.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class DeleteKosDataSource implements KosDataSource, KosDeleteDataSource {
  DeleteKosDataSource()
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
  String? deletedId;
  String? deletedOwnerId;

  @override
  Future<List<Map<String, dynamic>>> fetchRows() async => rows;

  @override
  Future<void> deleteKos(String id, String ownerId) async {
    deletedId = id;
    deletedOwnerId = ownerId;
    rows.removeWhere(
      (row) => row['id'] == id && row['owner_id'] == ownerId,
    );
  }
}

class DeleteAuthDataSource implements AuthDataSource {
  const DeleteAuthDataSource(this.userId);

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

KosProvider _provider(DeleteKosDataSource source) {
  return KosProvider(
    repository: KosRepository(source: source),
  );
}

Widget _makePage(KosProvider provider, String userId) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<KosProvider>.value(value: provider),
      ChangeNotifierProvider<AuthProvider>(
        create: (_) => AuthProvider(
          repository: AuthRepository(source: DeleteAuthDataSource(userId)),
        ),
      ),
    ],
    child: const MaterialApp(home: KosListPage()),
  );
}

bool _hasRow(DeleteKosDataSource source, String id) =>
    source.rows.any((row) => row['id'] == id);

void main() {
  test('repository deleteKos menolak kos pemilik lain', () async {
    final source = DeleteKosDataSource();
    final repository = KosRepository(source: source);

    await expectLater(
      repository.deleteKos(id: 'k1', ownerId: 'owner-2'),
      throwsA(
        isA<KosRepositoryException>().having(
          (error) => error.message,
          'message',
          contains('bukan milik'),
        ),
      ),
    );

    expect(source.deletedId, isNull);
    expect(_hasRow(source, 'k1'), isTrue);
  });

  test('provider deleteKos menghapus kos sendiri dan memuat ulang daftar',
      () async {
    final source = DeleteKosDataSource();
    final provider = _provider(source);
    await provider.loadKos();

    final ok = await provider.deleteKos(kosId: 'k1', ownerId: 'owner-1');

    expect(ok, isTrue);
    expect(source.deletedId, 'k1');
    expect(source.deletedOwnerId, 'owner-1');
    expect(provider.items.any((item) => item.id == 'k1'), isFalse);
    expect(provider.isSaving, isFalse);
  });

  test('provider deleteKos menolak pemilik lain', () async {
    final source = DeleteKosDataSource();
    final provider = _provider(source);
    await provider.loadKos();

    final ok = await provider.deleteKos(kosId: 'k1', ownerId: 'owner-2');

    expect(ok, isFalse);
    expect(provider.errorMessage, 'Kos ini bukan milik Anda.');
    expect(source.deletedId, isNull);
    expect(_hasRow(source, 'k1'), isTrue);
  });

  testWidgets('pemilik menghapus kos sendiri setelah konfirmasi', (
    WidgetTester tester,
  ) async {
    final source = DeleteKosDataSource();
    final provider = _provider(source);
    await provider.loadKos();

    await tester.pumpWidget(_makePage(provider, 'owner-1'));
    await tester.pumpAndSettle();

    expect(find.text('Kos A'), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    expect(find.text('Hapus kos?'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Hapus'));
    await tester.pumpAndSettle();

    expect(source.deletedId, 'k1');
    expect(find.text('Kos A'), findsNothing);
    expect(find.text('Kos B'), findsOneWidget);
  });

  testWidgets('pemilik lain tidak melihat tombol hapus pada kos A', (
    WidgetTester tester,
  ) async {
    final source = DeleteKosDataSource();
    final provider = _provider(source);
    await provider.loadKos();

    await tester.pumpWidget(_makePage(provider, 'owner-2'));
    await tester.pumpAndSettle();

    final kosATile = find.ancestor(
      of: find.text('Kos A'),
      matching: find.byType(ListTile),
    );
    expect(find.text('Kos A'), findsOneWidget);
    expect(
      find.descendant(
        of: kosATile,
        matching: find.byIcon(Icons.delete_outline),
      ),
      findsNothing,
    );
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
  });
}
