/// Konfigurasi Supabase dibaca dari --dart-define.
/// Jangan pernah menaruh URL/key asli di kode atau repository.
class SupabaseConfig {
  static const url = String.fromEnvironment('SUPABASE_URL');
  static const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
