import 'package:material_ui/material_ui.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const String identity = '2415051066 - Agus Adrian Satria Ananta';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tentang')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'KosFinder',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Aplikasi pencarian kos berbasis Supabase.'),
              const SizedBox(height: 24),
              const Text(identity, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
