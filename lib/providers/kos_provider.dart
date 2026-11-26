import 'package:flutter/foundation.dart';
import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/repositories/kos_repository.dart';

/// State daftar kos untuk Slice 1.
///
/// Provider ini sengaja hanya menangkap error dari repository:
/// UI tidak perlu tahu detail Supabase atau PostgREST.
class KosProvider extends ChangeNotifier {
  KosProvider({required this.repository});

  final KosRepository repository;

  List<Kos> _items = <Kos>[];
  bool _isLoading = false;
  String? _errorMessage;

  List<Kos> get items => List<Kos>.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  Future<void> loadKos() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await repository.getKosList();
    } on KosRepositoryException catch (error) {
      _items = <Kos>[];
      _errorMessage = error.message;
    } catch (error) {
      _items = <Kos>[];
      _errorMessage = 'Gagal memuat daftar kos: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }
}
