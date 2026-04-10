import 'package:flutter/material.dart';
import 'package:one_day/core/theme/app_theme.dart';
import 'package:one_day/features/onboarding/presentation/pages/onboarding_page.dart';

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
      home: const OnboardingPage(),
      // Future: Add localization support here
      /*
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('om', ''), // Afaan Oromoo
        Locale('am', ''), // Amharic
      ],
      */
    );
  }
}
