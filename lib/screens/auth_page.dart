import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isRegister = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isRegister ? 'Daftar Pemilik' : 'Masuk Pemilik'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: auth.isSignedIn
              ? _signedInView(auth)
              : _formView(auth),
        ),
      ),
    );
  }

  Widget _signedInView(AuthProvider auth) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle_outline, size: 48),
        const SizedBox(height: 12),
        Text('Sedang login sebagai ${auth.session?.email}'),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: auth.isBusy ? null : auth.signOut,
          child: const Text('Keluar'),
        ),
        if (auth.errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(auth.errorMessage!, textAlign: TextAlign.center),
        ],
      ],
    );
  }

  Widget _formView(AuthProvider auth) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(),
          ),
        ),
        if (auth.errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(auth.errorMessage!, textAlign: TextAlign.center),
        ],
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: auth.isBusy ? null : _submit,
            child: Text(_isRegister ? 'Daftar' : 'Masuk'),
          ),
        ),
        TextButton(
          onPressed: () {
            auth.clearError();
            setState(() => _isRegister = !_isRegister);
          },
          child: Text(
            _isRegister
                ? 'Sudah punya akun? Masuk'
                : 'Belum punya akun? Daftar',
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final success = _isRegister
        ? await auth.signUp(email: email, password: password)
        : await auth.signIn(email: email, password: password);

    if (!mounted) return;
    if (success) {
      Navigator.of(context).maybePop();
    } else if (auth.errorMessage?.contains('Registrasi berhasil') ?? false) {
      setState(() => _isRegister = false);
    }
  }
}
