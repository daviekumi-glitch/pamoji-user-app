// Login + registration with email verification (real backend flows).
import 'package:flutter/material.dart';
import '../../core/api.dart';
import '../../core/theme.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  Future<void> _login() async {
    if (_busy) return;
    setState(() { _busy = true; _error = null; });
    try {
      await PamojiApi.login(_email.text.trim(), _password.text);
      // HomeShell shows automatically once hasToken is true.
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.storefront, color: PamojiColors.green, size: 54),
                  const SizedBox(height: 8),
                  const Text('PAMOJI',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  const Text('Buy and sell across Malawi',
                      style: TextStyle(color: PamojiColors.dim)),
                  const SizedBox(height: 34),
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(hintText: 'Email'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    onSubmitted: (_) => _login(),
                    decoration: const InputDecoration(hintText: 'Password'),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: PamojiColors.danger)),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _busy ? null : _login,
                      child: Padding(
                        padding: const EdgeInsets.all(13),
                        child: _busy
                            ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Sign in', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RegisterScreen())),
                    child: const Text('New here? Create an account'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
