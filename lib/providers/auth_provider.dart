import 'package:flutter/foundation.dart';
import 'package:kosfinder/repositories/auth_repository.dart';

/// State sesi pemilik. Pencari tidak perlu login untuk melihat kos.
class AuthProvider extends ChangeNotifier {
  AuthProvider({required this.repository})
    : _session = repository.currentSession;

  final AuthRepository repository;

  AuthSession? _session;
  bool _isBusy = false;
  String? _errorMessage;

  AuthSession? get session => _session;
  bool get isSignedIn => _session != null;
  bool get isBusy => _isBusy;
  String? get errorMessage => _errorMessage;

  Future<bool> signUp({
    required String email,
    required String password,
  }) async {
    final validation = _validate(email, password);
    if (validation != null) return _fail(validation);

    _start();
    try {
      final session = await repository.signUp(
        email: email,
        password: password,
      );
      if (session == null) {
        _session = null;
        _errorMessage = 'Registrasi berhasil. Silakan masuk.';
        return false;
      }
      _session = session;
      _errorMessage = null;
      return true;
    } on AuthRepositoryException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (error) {
      _errorMessage = 'Gagal mendaftar: $error';
      return false;
    } finally {
      _finish();
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    final validation = _validate(email, password);
    if (validation != null) return _fail(validation);

    _start();
    try {
      final session = await repository.signIn(
        email: email,
        password: password,
      );
      if (session == null) {
        _errorMessage = 'Gagal masuk: sesi tidak tersedia.';
        return false;
      }
      _session = session;
      _errorMessage = null;
      return true;
    } on AuthRepositoryException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (error) {
      _errorMessage = 'Gagal masuk: $error';
      return false;
    } finally {
      _finish();
    }
  }

  Future<void> signOut() async {
    _start();
    try {
      await repository.signOut();
      _session = null;
      _errorMessage = null;
    } on AuthRepositoryException catch (error) {
      _errorMessage = error.message;
    } catch (error) {
      _errorMessage = 'Gagal keluar: $error';
    } finally {
      _finish();
    }
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  String? _validate(String email, String password) {
    if (email.trim().isEmpty || password.isEmpty) {
      return 'Email dan password wajib diisi.';
    }
    if (!email.contains('@')) return 'Email tidak valid.';
    if (password.length < 6) return 'Password minimal 6 karakter.';
    return null;
  }

  bool _fail(String message) {
    _errorMessage = message;
    notifyListeners();
    return false;
  }

  void _start() {
    _isBusy = true;
    _errorMessage = null;
    notifyListeners();
  }

  void _finish() {
    _isBusy = false;
    notifyListeners();
  }
}
