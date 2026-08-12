import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/navigation/app_shell.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load();
  } catch (error) {
    if (kDebugMode) debugPrint('Environment file was not loaded: $error');
  }
  runApp(const NdiChowApp());
}

class NdiChowApp extends StatelessWidget {
  const NdiChowApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'NdiChow',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    home: const AppShell(),
  );
}
