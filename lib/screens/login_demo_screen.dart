import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:project_ai/services/supabase_auth_service.dart';

/// 可替換成你的正式登入頁；示範 Email 註冊／登入與 Google。
class LoginDemoScreen extends StatefulWidget {
  const LoginDemoScreen({super.key});

  @override
  State<LoginDemoScreen> createState() => _LoginDemoScreenState();
}

class _LoginDemoScreenState extends State<LoginDemoScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _auth = SupabaseAuthService();
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() fn) async {
    setState(() => _busy = true);
    try {
      await fn();
      if (!mounted) return;
    } on AuthException catch (e) {
      if (mounted) _toast(e.message);
    } catch (e) {
      if (mounted) _toast('$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toast(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  Future<void> _signUp() async {
    final email = _email.text.trim();
    final password = _password.text;
    if (!EmailValidator.validate(email)) {
      _toast('請輸入有效 Email');
      return;
    }
    if (password.length < 6) {
      _toast('密碼至少 6 字元');
      return;
    }
    await _run(() async {
      final res = await _auth.signUpWithEmail(email: email, password: password);
      if (!mounted) return;
      if (res.session != null) {
        _toast('註冊完成（若專案已開「Confirm email」請改為至信箱驗證）');
      } else {
        _toast('已寄出驗證信，請至信箱點連結後再登入。');
      }
    });
  }

  Future<void> _signIn() async {
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.isEmpty) {
      _toast('請填 Email 與密碼');
      return;
    }
    await _run(() async {
      await _auth.signInWithEmail(email: email, password: password);
    });
  }

  Future<void> _google() async {
    await _run(() async {
      await _auth.signInWithGoogle();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text('登入', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
            const SizedBox(height: 24),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '密碼',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _busy ? null : _signIn,
              child: const Text('Email 登入'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _busy ? null : _signUp,
              child: const Text('Email 註冊'),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _busy ? null : _google,
              icon: const Icon(Icons.g_mobiledata, size: 28),
              label: const Text('Google 登入'),
            ),
          ],
        ),
      ),
    );
  }
}
