import 'package:flutter/material.dart';
import 'package:yuk_main/splashscreen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'YukMain',
      theme: ThemeData(
        useMaterial3: false,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff1CC500)
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          isDense: true,
          border: OutlineInputBorder()
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor:  Color(0xff1CC500),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor:  Color(0xff1CC500),
          selectedItemColor: Colors.white,
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Color(0xff1CC500),
        ),
        listTileTheme: const ListTileThemeData(
          dense: true
        )
      ),
      home: const SplashScreen(),
    );
  }
}
