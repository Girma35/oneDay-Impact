import 'package:flutter/material.dart';
import 'package:one_day/core/theme/app_theme.dart';
import 'package:one_day/features/main_page.dart';

class OneDayApp extends StatelessWidget {
  const OneDayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OneDay',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const MainPage(),
    );
  }
}
