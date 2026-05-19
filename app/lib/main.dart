import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nuveli/core/theme/app_theme.dart';
import 'package:nuveli/features/auth/screens/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    debug: dotenv.env['APP_ENV'] != 'production',
  );
  runApp(const ProviderScope(child: NuveliApp()));
}

class NuveliApp extends StatelessWidget {
  const NuveliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nuveli',
      theme: AppTheme.dark(),
      home: const AuthGate(),
    );
  }
}
