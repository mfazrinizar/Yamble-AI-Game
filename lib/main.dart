import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_theme/json_theme.dart';
import 'package:yamble_yap_to_gamble_ai_game/firebase_options.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:yamble_yap_to_gamble_ai_game/pages/home_page.dart';

import 'dart:convert';

import 'package:yamble_yap_to_gamble_ai_game/pages/onboarding/onboarding_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeRaw = await rootBundle.loadString('assets/theme/theme.json');
  final themeJson = jsonDecode(themeRaw);
  final theme = ThemeDecoder.decodeThemeData(themeJson) ?? ThemeData();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp(
    theme: theme,
  ));
}

class MyApp extends StatelessWidget {
  final ThemeData theme;
  const MyApp({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Yamble: Yap to Gamble AI Game',
      theme: theme,
      home: FirebaseAuth.instance.currentUser != null
          ? const HomePage()
          : const OnboardingPage(),
      builder: FlutterSmartDialog.init(),
    );
  }
}
