import 'package:supabase_flutter/supabase_flutter.dart';

/// Sesi pemilik yang disederhanakan agar provider tidak bergantung
/// langsung pada tipe Session dari Supabase.
class AuthSession {
  const AuthSession({required this.userId, required this.email});

  final String userId;
  final String email;
}

/// Abstraksi kecil supaya auth bisa diuji tanpa Supabase nyata.
abstract class AuthDataSource {
  AuthSession? get currentSession;

  Future<AuthSession?> signUp({
    required String email,
    required String password,
  });

  Future<AuthSession?> signInWithPassword({
    required String email,
    required String password,
  });

  Future<void> signOut();
}

class SupabaseAuthDataSource implements AuthDataSource {
  SupabaseAuthDataSource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  AuthSession? get currentSession => _toSession(_client.auth.currentSession);

  @override
  Future<AuthSession?> signUp({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );
    return _toSession(response.session);
  }

  @override
  Future<AuthSession?> signInWithPassword({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return _toSession(response.session);
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  static AuthSession? _toSession(Session? session) {
    if (session == null) return null;
    return AuthSession(
      userId: session.user.id,
      email: session.user.email ?? '',
    );
  }
}

class AuthRepository {
  AuthRepository({AuthDataSource? source})
    : _source = source ?? SupabaseAuthDataSource();

  final AuthDataSource _source;

  AuthSession? get currentSession => _source.currentSession;

  Future<AuthSession?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      return await _source.signUp(email: email, password: password);
    } catch (error) {
      throw AuthRepositoryException('Gagal mendaftar: $error');
    }
  }

  Future<AuthSession?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _source.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (error) {
      throw AuthRepositoryException('Gagal masuk: $error');
    }
  }

  Future<void> signOut() async {
    try {
      await _source.signOut();
    } catch (error) {
      throw AuthRepositoryException('Gagal keluar: $error');
    }
  }
}

class AuthRepositoryException implements Exception {
  const AuthRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
