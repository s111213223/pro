import 'package:supabase_flutter/supabase_flutter.dart';

/// 信箱是否已由 Supabase 標記為已驗證（`email_confirmed_at`）。
bool isEmailConfirmedOnServer(User user) {
  final v = user.emailConfirmedAt;
  return v != null && v.isNotEmpty;
}

bool _hasGoogleIdentity(User user) {
  for (final id in user.identities ?? const <UserIdentity>[]) {
    if (id.provider == 'google') return true;
  }
  return false;
}

/// Google 登入不需再跑信箱驗證；以 email／密碼註冊者需完成驗證（`email_confirmed_at`）。
///
/// 請在 Supabase Dashboard → Authentication → Providers → Email 開啟 **Confirm email**。
bool requiresEmailVerification(User user) {
  if (isEmailConfirmedOnServer(user)) return false;
  if (_hasGoogleIdentity(user)) return false;
  for (final id in user.identities ?? const <UserIdentity>[]) {
    if (id.provider == 'email') return true;
  }
  return false;
}
