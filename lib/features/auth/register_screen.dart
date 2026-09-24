import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/api.dart';
import '../../core/theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _displayName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();
  String _location = 'Blantyre';
  bool _busy = false;
  String? _error;
  String? _devCode; // DEV fallback (no email provider configured — see README)
  final _code = TextEditingController();

  Future<void> _register() async {
    if (!_form.currentState!.validate() || _busy) return;
    setState(() { _busy = true; _error = null; });
    try {
      final res = await PamojiApi.register(
        email: _email.text.trim(),
        password: _password.text,
        fullName: _fullName.text.trim(),
        displayName: _displayName.text.trim(),
        location: _location,
        phone: _phone.text.trim(),
      );
      final code = res['devVerificationCode'] as String?;
      if (mounted) setState(() => _devCode = code);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verify() async {
    setState(() { _busy = true; _error = null; });
    try {
      await PamojiApi.verifyEmail(_code.text.trim());
      if (mounted) Navigator.of(context).pop(); // back to login → sign in
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_devCode != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Verify your email')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('We sent a 6-digit code to your email.',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 6),
              const Text(
                'No email provider is configured yet (documented gap) — your DEV code is shown below.',
                style: TextStyle(color: PamojiColors.dim, fontSize: 12.5),
              ),
              const SizedBox(height: 10),
              Text(_devCode!, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 6, color: PamojiColors.gold)),
              const SizedBox(height: 18),
              TextField(
                controller: _code,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 6,
                decoration: const InputDecoration(hintText: 'Enter the 6-digit code'),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(_error!, style: const TextStyle(color: PamojiColors.danger)),
                ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _busy ? null : _verify,
                  child: Padding(padding: const EdgeInsets.all(13), child: Text(_busy ? 'Verifying…' : 'Verify')),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(controller: _fullName, decoration: const InputDecoration(hintText: 'Full name'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null),
            const SizedBox(height: 12),
            TextFormField(controller: _displayName, decoration: const InputDecoration(hintText: 'Display name (shown to buyers)'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null),
            const SizedBox(height: 12),
            TextFormField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(hintText: 'Email'),
              validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null),
            const SizedBox(height: 12),
            TextFormField(controller: _password, obscureText: true, decoration: const InputDecoration(hintText: 'Password (min 8 characters)'),
              validator: (v) => (v == null || v.length < 8) ? 'At least 8 characters' : null),
            const SizedBox(height: 12),
            TextFormField(controller: _phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(hintText: 'Phone (optional)')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _location,
              decoration: const InputDecoration(hintText: 'Your marketplace location'),
              items: kLocations.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
              onChanged: (v) => setState(() => _location = v ?? 'Blantyre'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: PamojiColors.danger)),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _busy ? null : _register,
              child: Padding(padding: const EdgeInsets.all(14), child: Text(_busy ? 'Creating…' : 'Create account')),
            ),
          ],
        ),
      ),
    );
  }
}
