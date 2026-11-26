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
  bool _isSaving = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _maxPriceInput = '';

  List<Kos> get items => List<Kos>.unmodifiable(_items);
  List<Kos> get visibleItems {
    final byArea = repository.filterByArea(_items, _searchQuery);
    return repository.filterByMaxHarga(byArea, maxHarga);
  }

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  String get searchQuery => _searchQuery;
  String get maxPriceInput => _maxPriceInput;

  /// Menerima "2000000" maupun "2.000.000".
  int? get maxHarga {
    final cleaned = _maxPriceInput.replaceAll(RegExp(r'\D'), '');
    if (cleaned.isEmpty) return null;
    return int.tryParse(cleaned);
  }

  bool get hasInvalidMaxPrice =>
      _maxPriceInput.trim().isNotEmpty && maxHarga == null;

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

  Future<bool> createKos({
    required String ownerId,
    required String nama,
    required String area,
    required int harga,
    required String fasilitas,
    required int jumlahKamar,
  }) async {
    if (ownerId.isEmpty) return _failSave('Login pemilik diperlukan.');
    if (nama.trim().isEmpty || area.trim().isEmpty) {
      return _failSave('Nama dan area wajib diisi.');
    }
    if (harga < 0) return _failSave('Harga tidak boleh negatif.');
    if (jumlahKamar < 0) return _failSave('Jumlah kamar tidak boleh negatif.');

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.createKos(
        ownerId: ownerId,
        nama: nama.trim(),
        area: area.trim(),
        harga: harga,
        fasilitas: fasilitas.trim(),
        jumlahKamar: jumlahKamar,
      );
      await loadKos();
      return true;
    } on KosRepositoryException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (error) {
      _errorMessage = 'Gagal menyimpan kos: $error';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateKos({
    required String kosId,
    required String ownerId,
    required String nama,
    required String area,
    required int harga,
    required String fasilitas,
    required int jumlahKamar,
  }) async {
    if (kosId.trim().isEmpty) return _failSave('Kos tidak ditemukan.');
    if (ownerId.isEmpty) return _failSave('Login pemilik diperlukan.');
    if (nama.trim().isEmpty || area.trim().isEmpty) {
      return _failSave('Nama dan area wajib diisi.');
    }
    if (harga < 0) return _failSave('Harga tidak boleh negatif.');
    if (jumlahKamar < 0) return _failSave('Jumlah kamar tidak boleh negatif.');

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.updateKos(
        id: kosId,
        ownerId: ownerId,
        nama: nama,
        area: area,
        harga: harga,
        fasilitas: fasilitas,
        jumlahKamar: jumlahKamar,
      );
      await loadKos();
      return true;
    } on KosRepositoryException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (error) {
      _errorMessage = 'Gagal mengubah kos: $error';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  bool _failSave(String message) {
    _errorMessage = message;
    notifyListeners();
    return false;
  }

  void setSearchQuery(String value) {
    if (_searchQuery == value) return;
    _searchQuery = value;
    notifyListeners();
  }

  void clearSearch() => setSearchQuery('');

  void setMaxPrice(String value) {
    if (_maxPriceInput == value) return;
    _maxPriceInput = value;
    notifyListeners();
  }

  void clearMaxPrice() => setMaxPrice('');

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }
}
