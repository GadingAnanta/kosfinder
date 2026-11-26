import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/providers/auth_provider.dart';
import 'package:kosfinder/repositories/auth_repository.dart';
import 'package:kosfinder/screens/auth_page.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class FakeAuthDataSource implements AuthDataSource {
  AuthSession? _session;
  bool shouldThrow = false;

  @override
  AuthSession? get currentSession => _session;

  @override
  Future<AuthSession?> signUp({
    required String email,
    required String password,
  }) async {
    if (shouldThrow) throw Exception('network down');
    if (email != 'owner@example.com') return null;
    _session = AuthSession(userId: 'user-1', email: email);
    return _session;
  }

  @override
  Future<AuthSession?> signInWithPassword({
    required String email,
    required String password,
  }) async {
    if (shouldThrow) throw Exception('network down');
    if (email != 'owner@example.com' || password != 'password123') {
      throw Exception('invalid credentials');
    }
    _session = AuthSession(userId: 'user-1', email: email);
    return _session;
  }

  @override
  Future<void> signOut() async {
    _session = null;
  }
}

AuthProvider _makeProvider(FakeAuthDataSource source) {
  return AuthProvider(repository: AuthRepository(source: source));
}

Widget _makePage(FakeAuthDataSource source) {
  return ChangeNotifierProvider<AuthProvider>(
    create: (_) => _makeProvider(source),
    child: const MaterialApp(home: AuthPage()),
  );
}

void main() {
  test('daftar pemilik berhasil membuat sesi', () async {
    final provider = _makeProvider(FakeAuthDataSource());

    final ok = await provider.signUp(
      email: 'owner@example.com',
      password: 'password123',
    );

    expect(ok, isTrue);
    expect(provider.isSignedIn, isTrue);
    expect(provider.session?.email, 'owner@example.com');
  });

  test('daftar tanpa sesi meminta login', () async {
    final provider = _makeProvider(FakeAuthDataSource());

    final ok = await provider.signUp(
      email: 'other@example.com',
      password: 'password123',
    );

    expect(ok, isFalse);
    expect(provider.isSignedIn, isFalse);
    expect(provider.errorMessage, contains('Silakan masuk'));
  });

  test('login lalu logout mengakhiri sesi', () async {
    final provider = _makeProvider(FakeAuthDataSource());

    expect(
      await provider.signIn(
        email: 'owner@example.com',
        password: 'password123',
      ),
      isTrue,
    );
    expect(provider.isSignedIn, isTrue);

    await provider.signOut();
    expect(provider.isSignedIn, isFalse);
  });

  test('validasi input dan error jaringan tidak crash', () async {
    final provider = _makeProvider(FakeAuthDataSource());

    expect(
      await provider.signIn(email: 'bukan-email', password: '123'),
      isFalse,
    );
    expect(provider.errorMessage, isNotNull);

    final offline = FakeAuthDataSource()..shouldThrow = true;
    final offlineProvider = _makeProvider(offline);
    expect(
      await offlineProvider.signIn(
        email: 'owner@example.com',
        password: 'password123',
      ),
      isFalse,
    );
    expect(offlineProvider.errorMessage, contains('Gagal masuk'));
  });

  testWidgets('form login dan logout bekerja', (WidgetTester tester) async {
    final source = FakeAuthDataSource();
    await tester.pumpWidget(_makePage(source));

    await tester.enterText(
      find.widgetWithText(TextField, 'Email'),
      'owner@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Password'),
      'password123',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
    await tester.pumpAndSettle();

    expect(find.text('Sedang login sebagai owner@example.com'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Keluar'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Masuk'), findsOneWidget);
  });
}
