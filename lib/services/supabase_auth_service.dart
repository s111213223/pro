import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase Auth：Email 註冊（可選驗證信 redirect）、Google、重寄驗證信。
class SupabaseAuthService {
  SupabaseAuthService([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// 與 Supabase Dashboard → URL configuration → Redirect URLs 一致（Deep link 或 https）。
  String? get _emailRedirectTo {
    final v = dotenv.env['SUPABASE_EMAIL_REDIRECT']?.trim();
    return v == null || v.isEmpty ? null : v;
  }

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? emailRedirectTo,
  }) {
    return _client.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: emailRedirectTo ?? _emailRedirectTo,
    );
  }

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> resendSignupVerificationEmail(String email) async {
    await _client.auth.resend(
      type: OtpType.signup,
      email: email,
    );
  }

  /// 需要 Google Cloud OAuth **Web client** ID（與 Supabase Google provider 設定的 Client IDs 一致），
  /// 否則 Android 上常拿不到 `idToken`。
  Future<AuthResponse> signInWithGoogle() async {
    final serverClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID']?.trim();
    final google = GoogleSignIn(
      scopes: const ['email', 'profile'],
      serverClientId:
          serverClientId == null || serverClientId.isEmpty ? null : serverClientId,
    );
    final account = await google.signIn();
    if (account == null) {
      throw const AuthException('Google 登入已取消', statusCode: 'cancelled');
    }
    final auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw AuthException(
        'Google 未回傳 idToken。請在 .env 設定 GOOGLE_WEB_CLIENT_ID（OAuth Web 用戶端 ID）。',
        statusCode: 'missing_id_token',
      );
    }
    return _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: auth.accessToken,
    );
  }

  Future<void> signOut() => _client.auth.signOut();
}
