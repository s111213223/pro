import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/email_verification_policy.dart';
import '../services/supabase_auth_service.dart';

/// 依登入狀態切換畫面；Email 註冊且未驗證者會被挡在 [onSignedInVerified] 之外。
class AuthSessionGate extends StatelessWidget {
  const AuthSessionGate({
    super.key,
    required this.onSignedOut,
    required this.onSignedInVerified,
  });

  final Widget onSignedOut;
  final Widget onSignedInVerified;

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;
    return StreamBuilder<AuthState>(
      stream: client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session ?? client.auth.currentSession;
        final user = session?.user;
        if (user == null) {
          return onSignedOut;
        }
        if (requiresEmailVerification(user)) {
          return _EmailVerificationWall(user: user);
        }
        return onSignedInVerified;
      },
    );
  }
}

class _EmailVerificationWall extends StatefulWidget {
  const _EmailVerificationWall({required this.user});

  final User user;

  @override
  State<_EmailVerificationWall> createState() => _EmailVerificationWallState();
}

class _EmailVerificationWallState extends State<_EmailVerificationWall> {
  bool _busy = false;
  String? _message;

  Future<void> _resend() async {
    final email = widget.user.email;
    if (email == null || email.isEmpty) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await SupabaseAuthService().resendSignupVerificationEmail(email);
      if (mounted) {
        setState(() => _message = '已寄出驗證信，請檢查收件匣與垃圾信。');
      }
    } on AuthException catch (e) {
      if (mounted) setState(() => _message = e.message);
    } catch (e) {
      if (mounted) setState(() => _message = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = widget.user.email ?? '';
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '請驗證電子信箱',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Text('已寄驗證連結至：$email'),
              const SizedBox(height: 8),
              const Text(
                'Google 登入不需此步驟；若你以 Email 註冊，請點信內連結後再回來重新整理登入狀態。',
                style: TextStyle(color: Colors.black54),
              ),
              if (_message != null) ...[
                const SizedBox(height: 16),
                Text(_message!, style: const TextStyle(color: Colors.teal)),
              ],
              const Spacer(),
              FilledButton(
                onPressed: _busy ? null : _resend,
                child: _busy
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('重寄驗證信'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _busy ? null : () => Supabase.instance.client.auth.signOut(),
                child: const Text('登出'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
