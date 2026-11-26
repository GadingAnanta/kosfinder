import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'config/supabase_config.dart';
import 'providers/auth_provider.dart';
import 'providers/kos_provider.dart';
import 'repositories/auth_repository.dart';
import 'repositories/kos_repository.dart';
import 'screens/kos_list_page.dart';

class KosFinderApp extends StatelessWidget {
  const KosFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KosFinder',
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<KosProvider>(
            create: (_) => KosProvider(repository: _createRepository()),
          ),
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => AuthProvider(repository: _createAuthRepository()),
          ),
        ],
        child: const KosListPage(),
      ),
    );
  }

  /// Tanpa --dart-define, pakai sumber kosong agar aplikasi tetap terbuka.
  static KosRepository _createRepository() {
    final source = SupabaseConfig.isConfigured
        ? null
        : const _EmptyKosDataSource();
    return KosRepository(source: source);
  }

  static AuthRepository _createAuthRepository() {
    final source = SupabaseConfig.isConfigured
        ? null
        : const _EmptyAuthDataSource();
    return AuthRepository(source: source);
  }
}

class _EmptyKosDataSource implements KosDataSource {
  const _EmptyKosDataSource();

  @override
  Future<List<Map<String, dynamic>>> fetchRows() async {
    return const <Map<String, dynamic>>[];
  }
}

class _EmptyAuthDataSource implements AuthDataSource {
  const _EmptyAuthDataSource();

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
