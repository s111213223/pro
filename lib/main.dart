import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:project_ai/screens/login_demo_screen.dart';
import 'package:project_ai/widgets/auth_session_gate.dart';

/// 需要 `.env`：`SUPABASE_URL`、`SUPABASE_ANON_KEY`（或沿用 `Anon_Key`）。
/// 選用：`SUPABASE_EMAIL_REDIRECT`（與 Supabase Redirect URLs 一致）、`GOOGLE_WEB_CLIENT_ID`（Web OAuth 用戶端，供 Google idToken）。
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final url = (dotenv.env['SUPABASE_URL'] ?? '').trim();
  final key = (dotenv.env['SUPABASE_ANON_KEY'] ?? dotenv.env['Anon_Key'] ?? '').trim();

  if (url.isEmpty || key.isEmpty) {
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                '請在 .env 設定 SUPABASE_URL 與 SUPABASE_ANON_KEY（或 Anon_Key）。',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
    return;
  }

  await Supabase.initialize(
    url: url,
    anonKey: key,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  runApp(const ProjectAiApp());
}

class ProjectAiApp extends StatelessWidget {
  const ProjectAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'project_ai',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: AuthSessionGate(
        onSignedOut: const LoginDemoScreen(),
        onSignedInVerified: const _SignedInHome(),
      ),
    );
  }
}

class _SignedInHome extends StatelessWidget {
  const _SignedInHome();

  @override
  Widget build(BuildContext context) {
    final email = Supabase.instance.client.auth.currentUser?.email ?? '';
    return Scaffold(
      appBar: AppBar(title: const Text('已登入')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('你好，$email'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Supabase.instance.client.auth.signOut(),
              child: const Text('登出'),
            ),
          ],
        ),
      ),
    );
  }
}
