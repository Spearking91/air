import 'package:air/Pages/dash_board_page.dart';
import 'package:air/Pages/onboarding_page.dart';
import 'package:air/firebase_options.dart';
import 'package:air/widgets/notifier.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
  // precacheImage(, context);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkNotififier,
      builder: (context, isDarkMode, child) {
        return MaterialApp(
          title: 'Flutter Demo',
          debugShowCheckedModeBanner: false,
          themeMode: isDarkMode == null
              ? ThemeMode.system
              : isDarkMode
                  ? ThemeMode.dark
                  : ThemeMode.light,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Color.fromARGB(255, 32, 69, 33),
              brightness: Brightness.light,
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Color(0xFF204521),
              brightness: Brightness.dark,
            ),
          ),
          // home: DashBoardPage(),
          home: OnboardingPage(),
        );
      },
    );
  }
}
