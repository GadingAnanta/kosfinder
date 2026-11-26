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
  String _searchQuery = '';

  List<Kos> get items => List<Kos>.unmodifiable(_items);
  List<Kos> get visibleItems => repository.filterByArea(_items, _searchQuery);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  String get searchQuery => _searchQuery;

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

  void setSearchQuery(String value) {
    if (_searchQuery == value) return;
    _searchQuery = value;
    notifyListeners();
  }

  void clearSearch() => setSearchQuery('');

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }
}
