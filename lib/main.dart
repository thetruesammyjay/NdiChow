import 'package:flutter/material.dart';
import 'core/navigation/app_shell.dart';
import 'core/theme/app_theme.dart';
import 'features/home/data/home_repository.dart';

void main() => runApp(const NdiChowApp());

class NdiChowApp extends StatelessWidget {
  const NdiChowApp({super.key, this.homeRepository});

  final HomeRepository? homeRepository;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'NdiChow',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    home: AppShell(homeRepository: homeRepository),
  );
}
